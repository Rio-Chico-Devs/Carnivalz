https://github.com/godotengine/godot/tree/4.7-stable — letto con `git clone --sparse` il 23 settembre 2026 (tag 4.7-stable)

# Godot 4.7: come si scrive un file, e come si copia un dizionario

Estratti testuali dal sorgente del motore, cioè dalle schede delle classi (`doc/classes/*.xml`) e dal codice dei driver. Servono a `scripts/FileSicuro.gd` e alla correzione di `Intenzione.gd` (vedi `docs/caccia.md`).

## doc/classes/FileAccess.xml

**ModeFlags.WRITE** — Opens the file for write operations. If the file exists, it is truncated to zero length and its contents are cleared. Otherwise, it is created. [b]Note:[/b] When creating a file it must be in an already existing directory. To recursively create directories for a file path, see [method DirAccess.make_dir_recursive].

**store_string()** — Stores [param string] in the file without a newline character ([code]\n[/code]), encoding the text as UTF-8. This advances the file cursor by the length of the string in UTF-8 encoded bytes, which may be different from [method String.length] which counts the number of UTF-32 codepoints. Returns [code]true[/code] if the operation is successful. [b]Note:[/b] This method is intended to be used to write text files. The string is stored as a UTF-8 encoded buffer without string length or terminating zero, which means that it can't be loaded back easily. If you want to store a retrievable string in a binary file, consider using [method store_pascal_string] instead. For retrieving strings from a text file, you can use [code]get_buffer(length).get_string_from_utf8()[/code] (if you know the length) or [method get_as_text]. [b]Note:[/b] If an error occurs, the resulting value of the file position indicator is indeterminate.

**flush()** — Writes the file's buffer to disk. Flushing is automatically performed when the file is closed. This means you don't need to call [method flush] manually before closing a file. Still, calling [method flush] can be used to ensure the data is safe even if the project crashes instead of being closed gracefully. [b]Note:[/b] Only call [method flush] when you actually need it. Otherwise, it will decrease performance due to constant disk writes.

## doc/classes/OS.xml

**set_use_file_access_save_and_swap()** — If [param enabled] is [code]true[/code], when opening a file for writing, a temporary file is used in its place. When closed, it is automatically applied to the target file. This can useful when files may be opened by other applications, such as antiviruses, text editors, or even the Godot editor itself.

## doc/classes/DirAccess.xml

**rename()** — Renames (move) the [param from] file or directory to the [param to] destination. Both arguments should be paths to files or directories, either relative or absolute. If the destination file or directory exists and is not access-protected, it will be overwritten. Returns one of the [enum Error] code constants ([constant OK] on success).

## doc/classes/Dictionary.xml

**duplicate()** — Returns a new copy of the dictionary. By default, a [b]shallow[/b] copy is returned: all nested [Array], [Dictionary], and [Resource] keys and values are shared with the original dictionary. Modifying any of those in one dictionary will also affect them in the other. If [param deep] is [code]true[/code], a [b]deep[/b] copy is returned: all nested arrays and dictionaries are also duplicated (recursively). Any [Resource] is still shared with the original dictionary, though.

## drivers/unix/file_access_unix.cpp — con il salvataggio a scambio, si scrive su un file temporaneo accanto

```cpp
	if (is_backup_save_enabled() && (p_mode_flags == WRITE)) {
		// Set save path to the symlink target, not the link itself.
		String link;
		bool is_link = false;
		{
			CharString cs = path.utf8();
			struct stat lst = {};
			if (lstat(cs.get_data(), &lst) == 0) {
				is_link = S_ISLNK(lst.st_mode);
			}
			if (is_link) {
				char buf[PATH_MAX];
				memset(buf, 0, PATH_MAX);
				ssize_t len = readlink(cs.get_data(), buf, sizeof(buf));
				if (len > 0) {
					link.append_utf8(buf, len);
				}
				if (!link.is_absolute_path()) {
					link = path.get_base_dir().path_join(link);
				}
			}
		}
		save_path = is_link ? link : path;

		// Create a temporary file in the same directory as the target file.
		path = path + "-XXXXXX";
		CharString cs = path.utf8();
		int fd = mkstemp(cs.ptrw());
		if (fd == -1) {
			last_error = ERR_FILE_CANT_OPEN;
			return last_error;
		}

```

…e alla chiusura lo si rinomina sopra il vero (`rename(2)`):

```cpp
	fclose(f);
	f = nullptr;

	if (close_notification_func) {
		close_notification_func(path, flags);
	}

	if (!save_path.is_empty()) {
		int rename_error = rename(path.utf8().get_data(), save_path.utf8().get_data());

		if (rename_error && close_fail_notify) {
			close_fail_notify(save_path);
		}

		save_path = "";
		ERR_FAIL_COND(rename_error != 0);
	}
}
```

## drivers/windows/file_access_windows.cpp — su Windows, ReplaceFileW ritentato fino a mille volte

```cpp
void FileAccessWindows::_close() {
	if (!f) {
		return;
	}

	fclose(f);
	f = nullptr;

	if (!save_path.is_empty()) {
		// This workaround of trying multiple times is added to deal with paranoid Windows
		// antiviruses that love reading just written files even if they are not executable, thus
		// locking the file and preventing renaming from happening.

		bool rename_error = true;
		const Char16String &path_utf16 = path.utf16();
		const Char16String &save_path_utf16 = save_path.utf16();
		for (int i = 0; i < 1000; i++) {
			if (ReplaceFileW((LPCWSTR)(save_path_utf16.get_data()), (LPCWSTR)(path_utf16.get_data()), nullptr, REPLACEFILE_IGNORE_MERGE_ERRORS | REPLACEFILE_IGNORE_ACL_ERRORS, nullptr, nullptr)) {
				rename_error = false;
			} else {
				// Either the target exists and is locked (temporarily, hopefully)
				// or it doesn't exist; let's assume the latter before re-trying.
				rename_error = MoveFileW((LPCWSTR)(path_utf16.get_data()), (LPCWSTR)(save_path_utf16.get_data())) == 0;
			}

			if (!rename_error) {
				break;
			}

			OS::get_singleton()->delay_usec(1000);
		}

		if (rename_error) {
			if (close_fail_notify) {
				close_fail_notify(save_path);
			}
```

## drivers/windows/dir_access_windows.cpp — perché NON basta un rename fatto a mano

Se la destinazione esiste, `DirAccess.rename` su Windows prima la cancella e poi sposta: c'è un istante in cui il file non c'è. Lo scambio di `FileAccess` invece usa `ReplaceFileW`.

```cpp
	} else {
		if (file_exists(new_path)) {
			if (remove(new_path) != OK) {
				return FAILED;
			}
		}

		return MoveFileW((LPCWSTR)(path.utf16().get_data()), (LPCWSTR)(new_path.utf16().get_data())) != 0 ? OK : FAILED;
	}
}
```
