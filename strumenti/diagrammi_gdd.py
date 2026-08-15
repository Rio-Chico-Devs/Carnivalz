#!/usr/bin/env python3
# Sostituisce i blocchi mermaid con SVG scritti a mano: nessuna dipendenza, e
# stampano uguale a come si vedono. I colori escono dai token della pagina
# (currentColor e le variabili CSS), quindi seguono il tema.
import re

def box(x, y, w, h, titolo, sotto=None, cls="n"):
    o = ['<rect x="%d" y="%d" width="%d" height="%d" rx="3" class="%s"/>' % (x, y, w, h, cls)]
    if sotto:
        o.append('<text x="%d" y="%d" class="t b">%s</text>' % (x + w/2, y + h/2 - 3, titolo))
        o.append('<text x="%d" y="%d" class="t s">%s</text>' % (x + w/2, y + h/2 + 12, sotto))
    else:
        o.append('<text x="%d" y="%d" class="t b">%s</text>' % (x + w/2, y + h/2 + 4, titolo))
    return "".join(o)

def rombo(cx, cy, w, h, testo):
    p = "%d,%d %d,%d %d,%d %d,%d" % (cx, cy-h/2, cx+w/2, cy, cx, cy+h/2, cx-w/2, cy)
    return ('<polygon points="%s" class="d"/><text x="%d" y="%d" class="t b">%s</text>'
            % (p, cx, cy + 4, testo))

def freccia(x1, y1, x2, y2, eti=None, ex=None, ey=None):
    o = ['<line x1="%d" y1="%d" x2="%d" y2="%d" class="a" marker-end="url(#p)"/>' % (x1, y1, x2, y2)]
    if eti:
        o.append('<text x="%d" y="%d" class="t e">%s</text>' % (ex or (x1+x2)/2, ey or (y1+y2)/2 - 5, eti))
    return "".join(o)

def spezzata(punti, eti=None, ex=None, ey=None):
    d = " ".join("%d,%d" % p for p in punti)
    o = ['<polyline points="%s" class="a" marker-end="url(#p)" fill="none"/>' % d]
    if eti:
        o.append('<text x="%d" y="%d" class="t e">%s</text>' % (ex, ey, eti))
    return "".join(o)

TESTA = ('<svg viewBox="0 0 %d %d" class="dia" role="img" aria-label="%s">'
         '<defs><marker id="p" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" '
         'markerHeight="6" orient="auto-start-reverse">'
         '<path d="M0,0 L10,5 L0,10 z" class="pt"/></marker></defs>')

# ---------------------------------------------------------------- fig. 1
f1 = TESTA % (760, 480, "Ciclo principale di gioco")
f1 += box(300, 16, 160, 44, "SEDE", "salvi · compri · equipaggi", "k")
f1 += freccia(380, 60, 380, 82)
f1 += box(300, 82, 160, 44, "MAPPA", "scegli la frattura", "k")
f1 += freccia(380, 126, 380, 148)
f1 += box(300, 148, 160, 44, "VUOTO", "dungeon a nodi", "k")
f1 += freccia(380, 192, 380, 212)
f1 += rombo(380, 236, 100, 44, "nodo")
f1 += spezzata([(330, 236), (170, 236), (170, 268)], "scontro", 220, 230)
f1 += box(80, 268, 180, 44, "COMBATTIMENTO", None, "c")
f1 += spezzata([(430, 236), (580, 236), (580, 268)], "scelta", 530, 230)
f1 += box(500, 268, 160, 38, "evento narrativo", None, "n")
f1 += spezzata([(380, 258), (380, 268)], "bottino", 424, 264)
f1 += box(300, 268, 160, 38, "oggetto · Tazo", None, "n")
f1 += freccia(170, 312, 170, 344, "vittoria", 208, 332)
f1 += box(60, 344, 220, 48, "XP A TUTTO IL PARTY", "Tazo · drop garantito", "o")
f1 += freccia(280, 368, 330, 368)
f1 += rombo(380, 368, 100, 44, "livello?")
f1 += freccia(430, 368, 500, 368, "sì", 462, 361)
f1 += box(500, 344, 200, 48, "punti statistica", "+ punti abilità", "o")
# ritorno al Vuoto: corsia libera a destra
f1 += spezzata([(700, 368), (730, 368), (730, 170), (460, 170)])
# "no": corsia a sinistra della spina, non tocca niente
f1 += spezzata([(380, 390), (380, 440), (288, 440), (288, 170), (300, 170)], "no", 336, 434)
# sconfitta: angolo in alto a sinistra, tutto suo
f1 += spezzata([(80, 290), (30, 290), (30, 50), (300, 50)], "sconfitta", 52, 308)
# frattura chiusa: dal Vuoto alla Sede
f1 += spezzata([(300, 170), (70, 170), (70, 26), (300, 26)], "frattura chiusa", 150, 162)
f1 += "</svg>"

# ---------------------------------------------------------------- fig. 2
f2 = TESTA % (820, 600, "La battuta di un combattente")
f2 += box(250, 14, 200, 44, "RICARICA FINITA", "tocca a lui", "o")
f2 += freccia(350, 58, 350, 84)
f2 += box(250, 84, 200, 34, "scala ricariche mosse")
f2 += freccia(350, 118, 350, 140)
f2 += box(250, 140, 200, 34, "scadenza potenziamenti")
f2 += freccia(350, 174, 350, 196)
f2 += box(250, 196, 200, 34, "modalità · trasformazione")
f2 += freccia(350, 230, 350, 252)
f2 += box(250, 252, 200, 34, "combustione · tormento")
f2 += freccia(350, 286, 350, 312)
f2 += rombo(350, 336, 190, 50, "stato bloccante?")
f2 += spezzata([(445, 336), (600, 336)], "sì", 520, 330)
f2 += box(600, 314, 90, 44, "turno", "saltato", "c")
f2 += freccia(350, 361, 350, 388, "no", 366, 378)
f2 += rombo(350, 410, 130, 44, "chi è?")
f2 += spezzata([(285, 410), (120, 410), (120, 452)], "giocatore", 100, 404)
f2 += box(30, 452, 180, 44, "input o IA di squadra", None, "k")
f2 += spezzata([(415, 410), (520, 410), (520, 440)], "creatura", 556, 404)
f2 += rombo(520, 462, 190, 44, "vita sotto 30%?")
f2 += spezzata([(425, 462), (330, 462), (330, 496)], "no", 356, 456)
f2 += box(228, 496, 204, 36, "sorteggio pesato", None, "n")
f2 += spezzata([(615, 462), (690, 462), (690, 496)], "sì", 660, 456)
f2 += box(580, 496, 220, 36, "SCEGLIE · priorità", "+30% attacco", "o")
f2 += spezzata([(330, 532), (330, 560), (490, 560)])
f2 += spezzata([(690, 532), (690, 560), (630, 560)])
f2 += box(490, 546, 140, 30, "esegui mossa", None, "c")
f2 += spezzata([(120, 496), (120, 560), (490, 560)])
f2 += "</svg>"

# ---------------------------------------------------------------- fig. 3
f3 = TESTA % (760, 330, "I due binari della progressione")
f3 += '<rect x="14" y="14" width="356" height="240" rx="4" class="g"/>'
f3 += '<text x="30" y="36" class="t g1">BINARIO 1 · QUELLO CHE FAI</text>'
f3 += box(30, 50, 150, 30, "attacchi sferrati")
f3 += box(30, 88, 150, 30, "difese")
f3 += box(30, 126, 150, 30, "danni subiti")
f3 += box(30, 164, 150, 30, "studi · stanze · critici")
for y in (65, 103, 141, 179):
    f3 += freccia(180, y, 234, 122 if y != 122 else y)
f3 += box(234, 100, 120, 44, "contatori", None, "k")
f3 += freccia(294, 144, 294, 200, "a ogni livello", 294, 176)
f3 += box(204, 200, 150, 44, "punti statistica", None, "o")

f3 += '<rect x="394" y="14" width="352" height="240" rx="4" class="g"/>'
f3 += '<text x="410" y="36" class="t g1">BINARIO 2 · IL LIVELLO</text>'
f3 += box(410, 50, 160, 44, "XP dallo scontro", None, "k")
f3 += freccia(570, 72, 630, 72)
f3 += box(630, 50, 100, 44, "a TUTTI", "panchina inclusa", "o")
f3 += freccia(680, 94, 680, 126)
f3 += box(600, 126, 130, 34, "livello")
f3 += freccia(665, 160, 665, 190)
f3 += box(590, 190, 150, 34, "punti abilità")
f3 += freccia(590, 207, 530, 207)
f3 += box(400, 190, 130, 34, "albero · linee")
f3 += freccia(279, 244, 279, 282)
f3 += freccia(465, 224, 400, 282)
f3 += box(280, 282, 200, 38, "STATISTICHE EFFETTIVE", None, "c")
f3 += box(560, 282, 170, 34, "arma · accessori", None, "k")
f3 += freccia(560, 299, 484, 299)
f3 += "</svg>"

# ---------------------------------------------------------------- fig. 4
f4 = TESTA % (760, 400, "Architettura: scene, autoload e moduli")
f4 += '<rect x="14" y="14" width="200" height="230" rx="4" class="g"/>'
f4 += '<text x="30" y="36" class="t g1">AUTOLOAD</text>'
for i, (n, s) in enumerate([("GameState", "2216 righe · stato e curve"), ("AudioManager", None),
                            ("Stile", None), ("Impostazioni", None), ("Transizioni", None),
                            ("Pausa", None)]):
    f4 += box(30, 48 + i*31, 168, 26, n, None, "o" if i == 0 else "n")

f4 += '<rect x="238" y="14" width="508" height="230" rx="4" class="g"/>'
f4 += '<text x="254" y="36" class="t g1">SCENE</text>'
f4 += box(254, 48, 84, 28, "Splash")
f4 += freccia(338, 62, 366, 62)
f4 += box(366, 48, 84, 28, "Menu")
f4 += freccia(450, 62, 478, 62)
f4 += box(478, 48, 84, 28, "Intro")
f4 += freccia(520, 76, 520, 96)
f4 += box(452, 96, 136, 30, "Sede", None, "k")
f4 += freccia(452, 111, 380, 111)
f4 += box(254, 96, 126, 30, "Mappa", None, "k")
f4 += freccia(317, 126, 317, 148)
f4 += box(254, 148, 126, 30, "Vuoto", None, "k")
f4 += freccia(380, 163, 420, 163)
f4 += box(420, 148, 168, 30, "Main · motore dei nodi", None, "k")
f4 += freccia(504, 178, 504, 200)
f4 += box(420, 200, 168, 34, "COMBATTIMENTO", None, "c")
f4 += box(600, 96, 130, 28, "Negozio")
f4 += freccia(588, 111, 600, 111)
f4 += box(600, 148, 146, 28, "Bestiario · Album")
f4 += '<line x1="132" y1="234" x2="600" y2="162" class="a dash"/>'


f4 += '<rect x="14" y="262" width="732" height="112" rx="4" class="g"/>'
f4 += '<text x="30" y="284" class="t g1">MODULI DEL COMBATTIMENTO</text>'
for i, (n, s) in enumerate([("Regole", "matematica pura · 433"), ("Campo", "schede e posizioni"),
                            ("Voce", "coda degli effetti"), ("Menu", "azioni")]):
    f4 += box(30 + i*180, 296, 168, 46, n, s, "o" if i == 0 else "n")
f4 += spezzata([(504, 234), (504, 252), (114, 252), (114, 296)])
f4 += '<line x1="198" y1="60" x2="452" y2="111" class="a dash" marker-end="url(#p)"/>'
f4 += '<line x1="198" y1="60" x2="504" y2="200" class="a dash" marker-end="url(#p)"/>'
f4 += '<text x="300" y="86" class="t e">dati e stato</text>' 
f4 += "</svg>"

STILE = """
  .dia { width: 100%; height: auto; display: block; }
  .dia rect.n, .dia rect.k, .dia rect.o, .dia rect.c { stroke-width: 1; }
  .dia rect.n { fill: var(--paper); stroke: var(--line); }
  .dia rect.k { fill: var(--sunk); stroke: var(--ink3); }
  .dia rect.o { fill: none; stroke: var(--mark); stroke-width: 1.6; }
  .dia rect.c { fill: none; stroke: var(--sys); stroke-width: 1.6; }
  .dia rect.g { fill: none; stroke: var(--hair); stroke-dasharray: 3 3; }
  .dia polygon.d { fill: var(--paper); stroke: var(--sys); stroke-width: 1.2; }
  .dia .dash { stroke-dasharray: 4 3; }
  .dia line.a, .dia polyline.a { stroke: var(--ink3); stroke-width: 1.2; fill: none; }
  .dia path.pt { fill: var(--ink3); }
  .dia text { font-family: var(--sans); fill: var(--ink); }
  .dia text.t { text-anchor: middle; }
  .dia text.b { font-size: 11px; font-weight: 600; }
  .dia text.s { font-size: 9px; fill: var(--ink3); font-weight: 400; }
  .dia text.e { font-size: 9px; fill: var(--ink3); font-family: var(--mono); }
  .dia text.g1 { text-anchor: start; font-family: var(--mono); font-size: 8.5px;
                 letter-spacing: .1em; fill: var(--ink3); }
  figure.fig { margin: 1.3rem 0 1.6rem; border: 1px solid var(--line);
               background: var(--sunk); padding: 1rem .9rem .6rem; }
  figure.fig figcaption { font-family: var(--mono); font-size: .68rem; color: var(--ink3);
                          margin-top: .7rem; text-align: center; }
"""

s = open("docs/gdd.html").read()

# RIPETIBILE: la prima volta sostituisce i blocchi mermaid, dalla seconda in poi
# sostituisce le figure che ha generato lui. Cosi' si puo' ritoccare un diagramma
# e rilanciare, invece di dover ricostruire il documento da capo.
DIDASCALIE = [
  "Fig. 1 — Ciclo principale. Il ritorno alla Sede è l'unico punto di salvataggio.",
  "Fig. 2 — La battuta di un combattente. Implementato in <code>battuta_di()</code>.",
  "Fig. 3 — I due binari della crescita. Le statistiche non salgono col livello: salgono con quello che hai fatto.",
  "Fig. 4 — Scene, autoload e moduli. Le frecce tratteggiate sono letture di stato.",
]
if '<pre class="mermaid">' in s:
    schema = r'<pre class="mermaid">.*?</pre>\s*<p class="figura">.*?</p>'
else:
    schema = r'<figure class="fig">.*?</figure>'
didascalie = DIDASCALIE

# UNA SOLA PASSATA, con un iteratore. Sostituire una alla volta con count=1 non
# funziona: la figura appena scritta corrisponde allo stesso schema di quella
# vecchia, quindi la seconda sostituzione ricadeva sulla prima casella e alla
# fine tutte e quattro finivano li' dentro.
coppie = iter(zip([f1, f2, f3, f4], didascalie))
def rimpiazza(_m):
    svg, testo = next(coppie)
    return '<figure class="fig">%s<figcaption>%s</figcaption></figure>' % (svg, testo)
s = re.sub(schema, rimpiazza, s, count=4, flags=re.S)
if "figure.fig {" not in s:
    s = s.replace("  pre.mermaid {", STILE + "  pre.mermaid {")
open("docs/gdd.html", "w").write(s)
print("quattro diagrammi rigenerati")
