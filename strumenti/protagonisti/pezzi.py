# Il motore dei pezzi: ogni parte e' una griglia di lettere ('.' = vuoto) che
# si incolla sulla tela 32x48 in una posizione. I fotogrammi sono pile di parti.
W, H = 32, 48

def tela():
    return [['.'] * W for _ in range(H)]

def incolla(t, righe, x, y, solo_vuoto=False):
    for j, r in enumerate(righe):
        for i, ch in enumerate(r):
            if ch == '.':
                continue
            X, Y = x + i, y + j
            if 0 <= X < W and 0 <= Y < H and (not solo_vuoto or t[Y][X] == '.'):
                t[Y][X] = ch

def specchia(righe):
    return [r[::-1] for r in righe]

def righe(t):
    return [''.join(r) for r in t]

def scambia(righe_, mappa):
    return [''.join(mappa.get(c, c) for c in r) for r in righe_]
