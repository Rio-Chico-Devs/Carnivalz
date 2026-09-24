#!/usr/bin/env python3
"""Tira fuori il riferimento ufficiale delle classi dall'eseguibile di Godot.

    python3 strumenti/riferimento_godot.py /percorso/Godot_v4.7-stable_linux.x86_64 Dictionary Array
    python3 strumenti/riferimento_godot.py /percorso/godot Array.sort_custom JSON.stringify

PERCHE' ESISTE. Il controllo a basso livello (docs/basso_livello.md) doveva
appoggiarsi a fonti attendibili, e la fonte piu' attendibile su come si
comporta Godot e' il suo riferimento delle classi. Il sito della
documentazione e il repository su GitHub, da dove lavoro, non si raggiungono;
ma l'editor si porta dentro lo stesso riferimento, compresso, per la sua
guida (Aiuto > Cerca nella guida). E' lo stesso testo del sito, ed e' della
versione esatta che fa girare il gioco: una fonte migliore di una pagina web
che potrebbe parlare di un'altra versione.

Il riferimento sta nell'eseguibile come un unico blocco zlib che comincia con
l'XML di @GlobalScope. Si cerca quel blocco, si decomprime, e si stampa la
descrizione della classe, del metodo o dell'operatore chiesto.
"""
import mmap
import re
import sys
import zlib

INIZI_ZLIB = (b"\x78\xda", b"\x78\x9c", b"\x78\x01", b"\x78\x5e")


def estrai(percorso_eseguibile):
    with open(percorso_eseguibile, "rb") as f:
        dati = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)
        for inizio in INIZI_ZLIB:
            i = dati.find(inizio)
            while i != -1:
                try:
                    prova = zlib.decompressobj().decompress(dati[i:i + 4096], 4096)
                    if b'<class name="@GlobalScope"' in prova:
                        return zlib.decompressobj().decompress(dati[i:i + 64_000_000]).decode("utf-8")
                except zlib.error:
                    pass
                i = dati.find(inizio, i + 1)
    return None


def pulisci(testo):
    return re.sub(r"\s+", " ", testo).strip()


def descrivi(riferimento, richiesta):
    classe, _, membro = richiesta.partition(".")
    blocco = re.search(r'<class name="%s".*?</class>' % re.escape(classe), riferimento, re.S)
    if blocco is None:
        return "%s: classe non trovata" % classe
    testo = blocco.group(0)
    if not membro:
        descrizione = re.search(r"<description>(.*?)</description>", testo, re.S)
        return "%s: %s" % (classe, pulisci(descrizione.group(1)) if descrizione else "(nessuna descrizione)")
    uscite = []
    for tipo in ("method", "member", "operator", "constant", "signal"):
        for voce in re.finditer(r'<%s name="%s"[^>]*>(.*?)</%s>' % (tipo, re.escape(membro), tipo), testo, re.S):
            descrizione = re.search(r"<description>(.*?)</description>", voce.group(0), re.S)
            uscite.append("%s.%s (%s): %s" % (classe, membro, tipo,
                    pulisci(descrizione.group(1) if descrizione else voce.group(1))))
    return "\n\n".join(uscite) if uscite else "%s: non trovato" % richiesta


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(2)
    riferimento = estrai(sys.argv[1])
    if riferimento is None:
        print("in questo eseguibile il riferimento non c'e' (e' un modello di esportazione, non l'editor?)")
        sys.exit(1)
    for richiesta in sys.argv[2:]:
        print(descrivi(riferimento, richiesta))
        print()


if __name__ == "__main__":
    main()
