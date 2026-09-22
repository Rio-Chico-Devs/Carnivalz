#!/usr/bin/env python3
"""Tira fuori il testo da un PDF. Solo zlib: niente librerie, niente rete.

PERCHE' NON BASTA DECOMPRIMERE E LEGGERE.

Un PDF stampato da un browser incorpora font SOTTOINSIEME: i codici dei glifi
non sono ASCII, sono la numerazione interna di quel font, e ogni font ha la
sua. Dentro il PDF c'e' la tabella ToUnicode che dice quale carattere e' ogni
glifo - ma ce n'e' UNA PER FONT, e due font diversi danno allo stesso codice
significati diversi. Fondendole tutte in una sola, su un documento con molti
font, esce testo che sembra giusto e non lo e': "The defaut curs+r shape f+r
this c+ntr+". La "o" diventa "+" e la "l" sparisce, e non c'e' nessun errore da
nessuna parte - e' esattamente il genere di sbaglio che poi si cita come fonte.

Quindi si fa la cosa lunga: si indicizzano gli oggetti, si legge quali font usa
ogni pagina, si prende la tabella di OGNI font, e nel flusso si tiene dietro
all'operatore Tf per sapere quale tabella vale in quel punto.

L'altra trappola: alcuni PDF mettono una parola intera in un TJ e separano le
parole con un numero di crenatura; quelli stampati dal browser mettono UN GLIFO
PER Tj, ciascuno preceduto dal proprio "avanzamento 0 Td". Li' il Td non e' un
a capo, e' la larghezza della lettera precedente - trattarlo come un a capo
spezza ogni parola in lettere. Lo spazio vero c'e' gia', e' un glifo come gli
altri.

    python3 sfoglia.py documento.pdf > documento.txt
"""
import sys, zlib, re

SALTO_PAROLA = 120.0   # crenatura di un TJ oltre la quale ci sta uno spazio


def indicizza(dati):
    # "N G obj" ... il corpo arriva fino a endobj, o fino all'oggetto dopo
    oggetti = {}
    inizi = [(int(m.group(1)), m.end(), m.start())
             for m in re.finditer(rb'(?:^|[\r\n>\s])(\d+)\s+\d+\s+obj\b', dati)]
    for i, (numero, dopo, _) in enumerate(inizi):
        fine = inizi[i + 1][2] if i + 1 < len(inizi) else len(dati)
        oggetti[numero] = dati[dopo:fine]
    return oggetti


def riferimento(corpo, chiave):
    m = re.search(chiave.encode() + rb'\s+(\d+)\s+\d+\s+R', corpo)
    return int(m.group(1)) if m else None


def flusso_di(corpo):
    m = re.search(rb'stream\r?\n', corpo)
    if not m:
        return None
    fine = corpo.find(b'endstream', m.end())
    grezzo = corpo[m.end():fine if fine > 0 else len(corpo)]
    try:
        return zlib.decompress(grezzo)
    except zlib.error:
        try:
            return zlib.decompressobj().decompress(grezzo)
        except zlib.error:
            return None


def tabella(testo_cmap):
    mappa = {}
    if not testo_cmap:
        return mappa
    for blocco in re.findall(rb'beginbfchar(.*?)endbfchar', testo_cmap, re.S):
        for a, b in re.findall(rb'<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>', blocco):
            mappa[int(a, 16)] = bytes.fromhex(b.decode()).decode('utf-16-be', 'replace')
    # DUE FORME DI bfrange, e saltarne una fa sparire delle lettere.
    #
    #   <lo> <hi> <dst>              i codici da lo a hi valgono dst, dst+1...
    #   <lo> <hi> [<a> <b> <c> ...]  ogni codice ha il SUO carattere
    #
    # Leggendo solo la prima, le tabelle venivano fuori con quaranta voci per
    # una pagina intera e la "l" non c'era: "contros wi be abe to receive".
    for blocco in re.findall(rb'beginbfrange(.*?)endbfrange', testo_cmap, re.S):
        for m in re.finditer(rb'<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>\s*(?:<([0-9A-Fa-f]+)>|\[(.*?)\])',
                             blocco, re.S):
            lo, hi = int(m.group(1), 16), int(m.group(2), 16)
            if m.group(3) is not None:
                dst = int(m.group(3), 16)
                for k in range(lo, hi + 1):
                    mappa[k] = chr(dst + (k - lo))
            else:
                voci = re.findall(rb'<([0-9A-Fa-f]+)>', m.group(4))
                for i, v in enumerate(voci):
                    if lo + i > hi:
                        break
                    mappa[lo + i] = bytes.fromhex(v.decode()).decode('utf-16-be', 'replace')
    return mappa


def font_della_pagina(oggetti, corpo_pagina):
    # /Resources puo' stare dentro la pagina o essere un riferimento
    risorse = corpo_pagina
    n = riferimento(corpo_pagina, '/Resources')
    if n is not None and n in oggetti:
        risorse = oggetti[n]
    m = re.search(rb'/Font\s*<<(.*?)>>', risorse, re.S)
    dizionario = m.group(1) if m else b''
    if not m:
        n = riferimento(risorse, '/Font')
        if n is not None and n in oggetti:
            dizionario = oggetti[n]
    fuori = {}
    for nome, numero in re.findall(rb'/([A-Za-z0-9#+._-]+)\s+(\d+)\s+\d+\s+R', dizionario):
        corpo = oggetti.get(int(numero))
        if corpo is None:
            continue
        n_uni = riferimento(corpo, '/ToUnicode')
        if n_uni is None:
            # nei Type0 la tabella sta sul font padre, ma a volte la si trova
            # solo scendendo nei discendenti
            n_disc = riferimento(corpo, '/DescendantFonts')
            if n_disc is not None and n_disc in oggetti:
                n_uni = riferimento(oggetti[n_disc], '/ToUnicode')
        mappa = tabella(flusso_di(oggetti[n_uni])) if (n_uni is not None and n_uni in oggetti) else {}
        if not mappa:
            # NIENTE TABELLA: NON VUOL DIRE NIENTE TESTO.
            #
            # I PDF fatti da LaTeX o da Word usano font veri con codifica
            # standard (WinAnsi), e la tabella ToUnicode non serve perche' i
            # codici SONO gia' i caratteri. Arrendersi qui vuol dire consegnare
            # un file vuoto per un documento pieno di testo - e' successo con
            # le euristiche di giocabilita': dieci pagine, un byte in uscita.
            mappa = {i: chr(i) for i in range(32, 256)}
            mappa.update(differenze(oggetti, corpo))
        fuori[nome.decode('latin-1')] = mappa
    return fuori


def differenze(oggetti, corpo_font):
    # /Encoding puo' rimappare singoli codici: "/Differences [ 65 /Aacute ]".
    # Si tiene solo quello che si sa tradurre senza tabella dei nomi dei glifi.
    n = riferimento(corpo_font, '/Encoding')
    dentro = oggetti.get(n, b'') if n is not None else corpo_font
    m = re.search(rb'/Differences\s*\[(.*?)\]', dentro, re.S)
    if not m:
        return {}
    fuori, codice = {}, 0
    for pezzo in re.findall(rb'\d+|/[A-Za-z0-9.]+', m.group(1)):
        if pezzo.isdigit():
            codice = int(pezzo)
            continue
        nome = pezzo[1:].decode('latin-1')
        if len(nome) == 1:
            fuori[codice] = nome
        elif nome.startswith('uni') and len(nome) == 7:
            try:
                fuori[codice] = chr(int(nome[3:], 16))
            except ValueError:
                pass
        codice += 1
    return fuori


def traduci(grezzo, mappa, due_byte):
    fuori = []
    if due_byte:
        for i in range(0, len(grezzo) - 1, 2):
            fuori.append(mappa.get((grezzo[i] << 8) | grezzo[i + 1], ''))
    else:
        for b in grezzo:
            fuori.append(mappa.get(b, ''))
    return ''.join(fuori)


def sciogli(s):
    fuori, i = [], 0
    scorciatoie = {b'n': b'\n', b'r': b'\r', b't': b'\t', b'b': b'\b',
                   b'f': b'\f', b'(': b'(', b')': b')', b'\\': b'\\'}
    while i < len(s):
        c = s[i:i + 1]
        if c == b'\\' and i + 1 < len(s):
            d = s[i + 1:i + 2]
            if d in scorciatoie:
                fuori.append(scorciatoie[d]); i += 2; continue
            ott = re.match(rb'[0-7]{1,3}', s[i + 1:i + 4])
            if ott:
                fuori.append(bytes([int(ott.group(0), 8) & 255]))
                i += 1 + len(ott.group(0)); continue
            fuori.append(d); i += 2; continue
        fuori.append(c); i += 1
    return b''.join(fuori)


SCHEMA = (rb'/([A-Za-z0-9#+._-]+)\s+[\d.]+\s+Tf'
          rb'|\[(.*?)\]\s*TJ'
          rb'|\((?:[^()\\]|\\.)*\)\s*Tj'
          rb'|<[0-9A-Fa-f\s]+>\s*Tj'
          rb'|(-?[\d.]+)\s+(-?[\d.]+)\s+(?:Td|TD)'
          rb'|T\*')


def testo(contenuto, font):
    righe = []
    for blocco in re.findall(rb'BT(.*?)ET', contenuto, re.S):
        pezzi = []
        mappa = {}
        due_byte = False
        for m in re.finditer(SCHEMA, blocco, re.S):
            if m.group(1) is not None:                      # Tf: cambia font
                mappa = font.get(m.group(1).decode('latin-1'), {})
                due_byte = bool(mappa) and max(mappa) > 255
                continue
            if m.group(3) is not None:                      # Td/TD
                if abs(float(m.group(4))) > 0.01:
                    pezzi.append('\n')
                continue
            if m.group(0) == b'T*':
                pezzi.append('\n')
                continue
            dentro = m.group(2) if m.group(2) is not None else m.group(0)
            for p in re.finditer(rb'\((?:[^()\\]|\\.)*\)|<[0-9A-Fa-f\s]+>|-?[\d.]+', dentro, re.S):
                t = p.group(0)
                if t.startswith(b'('):
                    pezzi.append(traduci(sciogli(t[1:-1]), mappa, due_byte))
                elif t.startswith(b'<'):
                    esa = re.sub(rb'\s', b'', t[1:-1])
                    if len(esa) % 2:
                        esa += b'0'
                    pezzi.append(traduci(bytes.fromhex(esa.decode('ascii')), mappa, due_byte))
                elif m.group(2) is not None and abs(float(t)) >= SALTO_PAROLA:
                    pezzi.append(' ')
        riga = ''.join(pezzi)
        if riga.strip():
            righe.append(riga)
    return '\n'.join(righe)


# --- LE TABELLE BUCATE -------------------------------------------------------
#
# Certe ToUnicode non traducono affatto alcuni glifi: il generatore li butta
# nell'AREA A USO PRIVATO (U+E000-U+F8FF), che non e' un carattere, e' un
# buco. Il testo esce leggibile e sbagliato - "contros wi be abe to receive" -
# senza nessun errore da nessuna parte. E' il modo piu' facile di citare male
# una fonte.
#
# Questi sono ricavati dal contesto, non indovinati: le cifre perche'
# "(, )" e' "(100, 100)" e "
# degree angle" e' "90 degree angle" - e i due conti danno lo stesso
# allineamento, E071 = '0' fino a E07A = '9'. La punteggiatura dagli elenchi
# separati da virgola e dalle righe "Inherits:" e "Note:".
RIPARAZIONI = {0xE050: 'l', 0xE00C: 'I',
               0xE093: ',', 0xE094: '.', 0xE095: ':', 0xE096: ';',
               0xEE48: '(', 0xEE49: ')', 0xEE4C: '[', 0xEE4D: ']',
               0xEE54: '-', 0xEE56: '<', 0xEE5A: '='}
RIPARAZIONI.update({0xE071 + i: chr(ord('0') + i) for i in range(10)})
ICONE = {0xF015, 0xF0A8, 0xF0A9}   # frecce e separatori del tema: non sono testo


def ripara(t):
    fuori = []
    restati = {}
    for c in t:
        n = ord(c)
        if n in RIPARAZIONI:
            fuori.append(RIPARAZIONI[n])
        elif 0xE000 <= n <= 0xF8FF:
            if n not in ICONE:
                restati[n] = restati.get(n, 0) + 1
                fuori.append('�')
        else:
            fuori.append(c)
    if restati:
        sys.stderr.write("ATTENZIONE: %d glifi senza traduzione, segnati con �: %s\n"
                         % (sum(restati.values()),
                            ', '.join('U+%04X x%d' % (k, v)
                                      for k, v in sorted(restati.items(),
                                                         key=lambda x: -x[1])[:10])))
    return ''.join(fuori)


def main():
    dati = open(sys.argv[1], 'rb').read()
    oggetti = indicizza(dati)
    fuori = []
    pagine = 0
    for numero, corpo in sorted(oggetti.items()):
        if not re.search(rb'/Type\s*/Page\b', corpo):
            continue
        pagine += 1
        font = font_della_pagina(oggetti, corpo)
        contenuti = []
        n = riferimento(corpo, '/Contents')
        if n is not None:
            contenuti.append(n)
        else:
            m = re.search(rb'/Contents\s*\[(.*?)\]', corpo, re.S)
            if m:
                contenuti += [int(x) for x in re.findall(rb'(\d+)\s+\d+\s+R', m.group(1))]
        for c in contenuti:
            if c not in oggetti:
                continue
            flusso = flusso_di(oggetti[c])
            if flusso and b'BT' in flusso:
                t = testo(flusso, font)
                if t.strip():
                    fuori.append(t)
    if not pagine:
        sys.stderr.write("nessuna pagina trovata: il PDF usa object stream?\n")
        sys.exit(2)
    uscita = ripara('\n'.join(fuori))
    uscita = re.sub(r'[ \t]{2,}', ' ', uscita)
    uscita = re.sub(r'\n{3,}', '\n\n', uscita)
    sys.stderr.write("pagine: %d\n" % pagine)
    print(uscita)


main()
