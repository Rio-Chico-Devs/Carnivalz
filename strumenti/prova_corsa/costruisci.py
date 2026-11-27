"""Mette dentro la pagina della prova i fogli di Lei e una o piu' zone (il ruscello, il pasto del goblin): per ognuna
la mappa, la maschera dei passi, i pezzi che stanno in piedi, i fiori, e dove si esce per andare in un'altra (tutto in
data URI). L'acqua che si muove c'e' solo al ruscello; le altre zone possono avere pezzi a fotogrammi che si muovono
sempre (il goblin che mangia). Con piu' zone, la prima e' quella dove si comincia; le uscite portano solo alle zone
che sono nella pagina.

uso: costruisci.py modello.html uscita.html cartella_acqua [zona ...]     (zone: ruscello, se mancano; o pasto)
"""
import base64
import html
import json
import os
import sys

import numpy as np
from PIL import Image

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'strumenti', 'livelli'))
from prato import TINTE                                     # noqa: E402  (i colori del prato della mappa)
MODELLO, USCITA, ACQUA = sys.argv[1:4]
ZONE = sys.argv[4:] or ['ruscello']
ZONA = ZONE[0]                                              # quella dove si comincia
LEI = os.path.join(REPO, 'strumenti/protagonisti/lei_chibi')
LIV = os.path.join(REPO, 'art/livelli')


def uri(percorso):
    with open(percorso, 'rb') as f:
        return 'data:image/png;base64,' + base64.b64encode(f.read()).decode('ascii')


# dove si esce da una zona e dove si entra nell'altra. Le due strade di mattoni si attaccano: quella del pasto lascia
# la mappa in alto dove quella del ruscello entra in basso, alla stessa x (pasto_goblin.py, STRADA_X0), quindi Lei
# tiene la sua x ('entrata' con x null) e cambia solo la y. 'rett' e' dove sono i piedi quando si esce
COLLEGAMENTI = {
    'pasto': [{'rett': [570, 0, 650, 92], 'zona': 'ruscello', 'entrata': [None, 700], 'verso': [0, -1]}],
    'ruscello': [{'rett': [570, 709, 650, 720], 'zona': 'pasto', 'entrata': [None, 104], 'verso': [0, 1]}],
}


def zona(nome):
    """i dati di una zona per la pagina; e le immagini dei suoi pezzi (file -> data URI)"""
    with open(os.path.join(LIV, nome + '.json'), encoding='utf-8') as f:
        pianta = json.load(f)
    with open(os.path.join(LIV, pianta['pezzi']), encoding='utf-8') as f:
        pezzi = json.load(f)['pezzi']
    assert pianta.get('scala', 1) == 1 and pianta.get('pixel', 1) == 1
    with open(os.path.join(LIV, pianta['fiori']), encoding='utf-8') as f:
        fiori = json.load(f)['fiori']
    z = {
        'nome': pianta['nome'],
        'mappa': uri(os.path.join(LIV, pianta['mappa'])),
        'passi': uri(os.path.join(LIV, pianta['passi'])),
        'prato': uri(os.path.join(LIV, pianta['prato'])),
        'pezzi': [[p[0], int(p[1]), int(p[2]), int(p[3]), int(p[4])] for p in pezzi],
        'limiti': pianta['limiti'],
        'partenza': pianta['partenza'],
        'verso': pianta['verso'],
        'stanze': [{'nome': s['nome'], 'rett': s['rett']} for s in pianta['stanze']],
        'fiori': fiori,
        'acqua': None, 'pozza': None, 'animati': {},
        'uscite': [u for u in COLLEGAMENTI.get(nome, []) if u['zona'] in ZONE],
    }
    immagini = {f: uri(os.path.join(LIV, f)) for f in sorted(set(p[0] for p in pezzi))}
    # l'acqua (solo al ruscello): i dati per pixel, la tessera, il filo del ruscello; i pezzi con l'acqua a
    # fotogrammi e la pozza
    if nome == 'ruscello':
        with open(os.path.join(ACQUA, 'dati', 'acqua_info.json'), encoding='utf-8') as f:
            acqua = json.load(f)
        acqua.pop('conti', None)
        acqua['dati'] = uri(os.path.join(ACQUA, 'dati', 'acqua_dati.png'))
        acqua['frazioni'] = uri(os.path.join(ACQUA, 'dati', 'acqua_dati_frazioni.png'))
        acqua['tessera'] = uri(os.path.join(LIV, 'terreni', 'acqua_radenna_tavolozza.png'))   # coi colori nuovi
        z['acqua'] = acqua
        with open(os.path.join(ACQUA, 'pezzi', 'pezzi_anim.json'), encoding='utf-8') as f:
            anim = json.load(f)
        for k, v in anim.items():
            v = dict(v)
            v['img'] = uri(os.path.join(ACQUA, 'pezzi', v.pop('file')))
            if k == 'pozza':
                z['pozza'] = v
            else:
                assert k in immagini, k
                z['animati'][k] = v
    # i pezzi della zona a fotogrammi che si muovono sempre (non solo con l'acqua): il goblin che mangia, la preda
    for k, v in pianta.get('animati', {}).items():
        assert k in immagini, k
        z['animati'][k] = {'img': uri(os.path.join(LIV, v['file'])), 'n': v['n'], 'ms': v['ms'], 'sempre': True}
    return z, immagini


dati = {
    'fogli': {
        'fronte': uri(os.path.join(LEI, 'davanti_corsa.png')),
        'spalle': uri(os.path.join(LEI, 'dietro_corsa.png')),
        'spalleFerma': uri(os.path.join(LEI, 'dietro_ferma.png')),
        'lato': uri(os.path.join(LEI, 'lato_corsa.png')),
        'latoSx': uri(os.path.join(LEI, 'lato_sinistro_corsa.png')),
    },
    'zone': {}, 'inizio': ZONA, 'immagini': {},
}
for n in ZONE:
    dati['zone'][n], imm = zona(n)
    dati['immagini'].update(imm)
# Lei ferma: l'attesa appena si ferma (nelle quattro direzioni); se resta ferma a lungo, una delle animazioni da
# ferma scelta a caso (il salto della corda, il sonno in piedi, la posa JoJo).
# Il punto per terra sta due righe sopra le suole, come nelle corse (suole alla riga 80, punto alla 78)
with open(os.path.join(LEI, 'corsa.json'), encoding='utf-8') as f:
    durate = json.load(f)['durate_ms']


def ferma(foglio, nome, w):
    a = np.asarray(Image.open(os.path.join(LEI, nome + '.png')).convert('RGBA'))[..., 3] > 0
    n = a.shape[1] // w
    assert a.shape[1] == n * w and len(durate[nome]) == n, nome
    suole = int(np.nonzero(a.any(axis=1))[0].max())
    dati['fogli'][foglio] = uri(os.path.join(LEI, nome + '.png'))
    return {'foglio': foglio, 'n': n, 'w': w, 'h': int(a.shape[0]), 'px': w // 2, 'py': suole - 2,
            'durate': durate[nome]}


dati['ferme'] = {'attese': {'giu': ferma('attesa', 'davanti_attesa', 40), 'su': ferma('attesaSu', 'dietro_attesa', 40),
                            'destra': ferma('attesaDx', 'lato_attesa', 40),
                            'sinistra': ferma('attesaSx', 'lato_sinistro_attesa', 40)},
                 'corda': ferma('corda', 'davanti_corda', 64),
                 'dorme': ferma('dorme', 'davanti_dorme', 40),
                 'jojo': ferma('jojo', 'davanti_jojo', 48)}
# i testi della pagina per le zone che non sono il ruscello (quelli del ruscello sono gia' nella pagina): messi nella
# pagina qui, al posto di quelli del ruscello; e dove non c'e' acqua, i comandi dell'acqua nascosti
TESTI = {
    'pasto': {'titolo': 'Il pasto del goblin',
              'sotto': "Lei arriva dal prato, da sud. In mezzo alla radura il goblin, di spalle, divora a morsi "
                       "furiosi la preda che ha appena ucciso, un cinghiale, sui resti della piazza antica mangiati "
                       "dall'erba. Dietro di lui la strada di mattoni sale a nord verso la pianura aperta: in cima la "
                       "scena passa al ruscello di Radenna, e dalla strada in fondo al ruscello si torna qui. Come al "
                       "ruscello: le nuvole e le macchie di sole, i fiori al vento, l'erba che si muove ai passi (sui "
                       "mattoni e sulle lastre no); se Lei resta ferma si annoia.",
              'aria': "Il pasto del goblin: clicca e usa le frecce per far correre Lei",
              'carico': "Carico la radura del goblin…"},
}
# le ombre delle nuvole che passano: la tessera (strumenti/livelli/luci.py) e il vento, in pixel al secondo
dati['luci'] = {'ombra': uri(os.path.join(LIV, 'terreni', 'nuvole_ombra.png')), 'vento': [14, 5]}


# l'erba ai passi: quando un piede tocca terra nella corsa. E' il fotogramma in cui la suola arriva sull'ultima riga
# (la 80) e nel fotogramma prima li' non c'era niente (il piede era in aria) o c'era l'altro piede (nessuna colonna in
# comune). Per ognuno: il fotogramma, la colonna di mezzo della suola dal punto per terra (colonna 20) e la larghezza
def appoggi(nome, n, w=40):
    a = np.asarray(Image.open(os.path.join(LEI, nome + '.png')).convert('RGBA'))[..., 3] > 0
    assert a.shape == (81, n * w), nome
    suola = [a[80, i * w:(i + 1) * w] for i in range(n)]
    out = []
    for i in range(n):
        if suola[i].any() and not (suola[i] & suola[i - 1]).any():
            c = np.nonzero(suola[i])[0]
            out.append([i, int((c.min() + c.max()) // 2) - w // 2, int(c.max() - c.min() + 1)])
    assert len(out) == 2, (nome, out)          # un appoggio per piede a ogni giro
    return out


dati['appoggi'] = {'fronte': appoggi('davanti_corsa', 12), 'spalle': appoggi('dietro_corsa', 9),
                   'lato': appoggi('lato_corsa', 12), 'latoSx': appoggi('lato_sinistro_corsa', 12)}
# i fiori in piedi che si muovono col vento: le pose (strumenti/livelli/fiori.py) e dove stanno (ruscello_radenna.py)
with open(os.path.join(LIV, 'terreni', 'fiori.json'), encoding='utf-8') as f:
    _fj = json.load(f)
dati['fiori'] = {'img': uri(os.path.join(LIV, 'terreni', 'fiori.png')), 'w': _fj['w'], 'h': _fj['h'], 'px': _fj['px'],
                 'py': _fj['py'], 'pieghe': _fj['pieghe'], 'specie': _fj['specie']}      # dove stanno: in ogni zona
# i colori del prato della mappa (ruscello_radenna.PRATO): la rampa dal piu' scuro al piu' chiaro e i fiori
_P = TINTE['A']
dati['erba'] = {'rampa': [_P[k] for k in ('profondo', 'scuro', 'medio', 'base', 'luce')],
                'fiori': [_P['petalo'], _P['cuore']]}
print('appoggi', dati['appoggi'])
testo = json.dumps(dati, ensure_ascii=False, separators=(',', ':'))
assert '</' not in testo
with open(MODELLO, encoding='utf-8') as f:
    pagina = f.read()
assert pagina.count('/*DATI*/null') == 1
pagina = pagina.replace('/*DATI*/null', testo)


def cambia(pagina, vecchio, nuovo):
    assert pagina.count(vecchio) == 1, vecchio
    return pagina.replace(vecchio, nuovo)


if ZONA in TESTI:
    T = {k: html.escape(v, quote=True) for k, v in TESTI[ZONA].items()}
    pagina = cambia(pagina, '<title>Prova corsa Lei</title>', '<title>%s</title>' % T['titolo'])
    pagina = cambia(pagina, '<h1>Prova corsa</h1>', '<h1>%s</h1>' % T['titolo'])
    i = pagina.index('<p class="sotto">') + len('<p class="sotto">')
    pagina = pagina[:i] + T['sotto'] + pagina[pagina.index('<br>', i):]
    pagina = cambia(pagina, 'aria-label="Il ruscello di Radenna: clicca e usa le frecce per far correre Lei"',
                    'aria-label="%s"' % T['aria'])
    pagina = cambia(pagina, 'Carico il ruscello…', T['carico'])
if not any(z['acqua'] for z in dati['zone'].values()):
    pagina = cambia(pagina, '<label>Corrente del ruscello', '<label hidden>Corrente del ruscello')
    pagina = cambia(pagina, '<div class="fila" role="group" aria-label="Acqua">',
                    '<div class="fila" role="group" aria-label="Acqua" hidden>')
with open(USCITA, 'w', encoding='utf-8') as f:
    f.write(pagina)
print('zone', ', '.join('%s (%d pezzi, uscite %d)' % (n, len(z['pezzi']), len(z['uscite']))
                         for n, z in dati['zone'].items()),
      '- immagini', len(dati['immagini']), '- pagina %.0f KB' % (len(pagina) / 1024))
