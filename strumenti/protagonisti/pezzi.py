# Il motore dei pezzi: ogni parte e' una griglia di lettere ('.' = vuoto) che
# si incolla sulla tela 32x48 in una posizione. I fotogrammi sono pile di parti.
W, H = 32, 48


def tela():
    return [['.'] * W for _ in range(H)]


def incolla(t, righe, x, y):
    for j, riga in enumerate(righe):
        for i, ch in enumerate(riga):
            if ch == '.':
                continue
            X, Y = x + i, y + j
            if 0 <= X < W and 0 <= Y < H:
                t[Y][X] = ch


def righe(t):
    return [''.join(riga) for riga in t]


def r(righe_, largo=None):
    """Una griglia scritta a mano. Le righe con '|' sono scritte a meta'
    (16|16), per non sbagliare le colonne; tutte devono essere lunghe uguali."""
    out = []
    for i, x in enumerate(righe_):
        if '|' in x:
            a, b = x.split('|')
            assert len(a) == len(b), (i, len(a), len(b), x)
            x = a + b
        if largo is not None:
            assert len(x) == largo, (i, len(x), x)
        out.append(x)
    assert len({len(x) for x in out}) == 1, [len(x) for x in out]
    return out


def coppia(s, d):
    """Le due gambe una accanto all'altra (8 + 8 colonne), allineate in alto."""
    n = max(len(s), len(d))
    s = s + ["........"] * (n - len(s))
    d = d + ["........"] * (n - len(d))
    return [a + b for a, b in zip(s, d)]
