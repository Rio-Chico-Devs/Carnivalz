"""Mette dentro la pagina della prova i fogli di Lei, la mappa del ruscello,
la maschera dei passi, i pezzi che stanno in piedi e l'acqua che si muove (tutto in data URI).

uso: costruisci.py modello.html uscita.html cartella_acqua (quella di fai.sh)
"""
import base64
import json
import os
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
MODELLO, USCITA, ACQUA = sys.argv[1:4]
LEI = os.path.join(REPO, 'strumenti/protagonisti/lei_chibi')
LIV = os.path.join(REPO, 'art/livelli')


def uri(percorso):
    with open(percorso, 'rb') as f:
        return 'data:image/png;base64,' + base64.b64encode(f.read()).decode('ascii')


with open(os.path.join(LIV, 'ruscello.json'), encoding='utf-8') as f:
    pianta = json.load(f)
with open(os.path.join(LIV, pianta['pezzi']), encoding='utf-8') as f:
    pezzi = json.load(f)['pezzi']
assert pianta.get('scala', 1) == 1 and pianta.get('pixel', 1) == 1
dati = {
    'fogli': {
        'fronte': uri(os.path.join(LEI, 'davanti_corsa.png')),
        'spalle': uri(os.path.join(LEI, 'dietro_corsa.png')),
        'spalleFerma': uri(os.path.join(LEI, 'dietro_ferma.png')),
        'lato': uri(os.path.join(LEI, 'lato_corsa.png')),
        'latoSx': uri(os.path.join(LEI, 'lato_sinistro_corsa.png')),
    },
    'mappa': uri(os.path.join(LIV, pianta['mappa'])),
    'passi': uri(os.path.join(LIV, pianta['passi'])),
    'immagini': {f: uri(os.path.join(LIV, f)) for f in sorted(set(p[0] for p in pezzi))},
    'pezzi': [[p[0], int(p[1]), int(p[2]), int(p[3]), int(p[4])] for p in pezzi],
    'limiti': pianta['limiti'],
    'partenza': pianta['partenza'],
    'verso': pianta['verso'],
    'stanze': [{'nome': s['nome'], 'rett': s['rett']} for s in pianta['stanze']],
}
# l'acqua: i dati per pixel, la tessera, il filo del ruscello; i pezzi con l'acqua a fotogrammi e la pozza
with open(os.path.join(ACQUA, 'dati', 'acqua_info.json'), encoding='utf-8') as f:
    acqua = json.load(f)
acqua.pop('conti', None)
acqua['dati'] = uri(os.path.join(ACQUA, 'dati', 'acqua_dati.png'))
acqua['frazioni'] = uri(os.path.join(ACQUA, 'dati', 'acqua_dati_frazioni.png'))
acqua['tessera'] = uri(os.path.join(LIV, 'terreni', 'acqua_radenna.png'))
dati['acqua'] = acqua
with open(os.path.join(ACQUA, 'pezzi', 'pezzi_anim.json'), encoding='utf-8') as f:
    anim = json.load(f)
dati['animati'] = {}
for k, v in anim.items():
    v = dict(v)
    v['img'] = uri(os.path.join(ACQUA, 'pezzi', v.pop('file')))
    if k == 'pozza':
        dati['pozza'] = v
    else:
        assert k in dati['immagini'], k
        dati['animati'][k] = v
testo = json.dumps(dati, ensure_ascii=False, separators=(',', ':'))
assert '</' not in testo
with open(MODELLO, encoding='utf-8') as f:
    pagina = f.read()
assert pagina.count('/*DATI*/null') == 1
pagina = pagina.replace('/*DATI*/null', testo)
with open(USCITA, 'w', encoding='utf-8') as f:
    f.write(pagina)
print('pezzi', len(dati['pezzi']), 'immagini', len(dati['immagini']), 'pagina %.0f KB' % (len(pagina) / 1024))
