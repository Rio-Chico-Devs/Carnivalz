# un PNG senza librerie: righe di (r,g,b,a)
import zlib, struct
def scrivi(percorso, larghezza, altezza, pixel):
    grezzo = b''.join(b'\x00' + bytes(v for p in pixel[y*larghezza:(y+1)*larghezza] for v in p) for y in range(altezza))
    def blocco(t, d):
        return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    with open(percorso, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n')
        f.write(blocco(b'IHDR', struct.pack('>IIBBBBB', larghezza, altezza, 8, 6, 0, 0, 0)))
        f.write(blocco(b'IDAT', zlib.compress(grezzo, 9)))
        f.write(blocco(b'IEND', b''))


def leggi(percorso):
    """-> (larghezza, altezza, pixel (r, g, b, a)): solo PNG a 8 bit, RGB o
    RGBA, non interlacciati (quelli di questo strumento e di ImageMagick)"""
    dati = open(percorso, 'rb').read()
    assert dati[:8] == b'\x89PNG\r\n\x1a\n', percorso
    i, idat = 8, b''
    while i < len(dati):
        n, tipo = struct.unpack('>I4s', dati[i:i + 8])
        corpo = dati[i + 8:i + 8 + n]
        if tipo == b'IHDR':
            w, h, bit, colore, _, _, interl = struct.unpack('>IIBBBBB', corpo)
            assert bit == 8 and colore in (2, 6) and interl == 0, (bit, colore, interl)
        elif tipo == b'IDAT':
            idat += corpo
        i += 12 + n
    bpp = 3 if colore == 2 else 4
    grezzo = zlib.decompress(idat)
    riga_b = w * bpp
    prima = bytearray(riga_b)
    pixel = []
    for y in range(h):
        filtro = grezzo[y * (riga_b + 1)]
        riga = bytearray(grezzo[y * (riga_b + 1) + 1:(y + 1) * (riga_b + 1)])
        for x in range(riga_b):
            a = riga[x - bpp] if x >= bpp else 0
            b = prima[x]
            c = prima[x - bpp] if x >= bpp else 0
            if filtro == 1:
                riga[x] = (riga[x] + a) & 255
            elif filtro == 2:
                riga[x] = (riga[x] + b) & 255
            elif filtro == 3:
                riga[x] = (riga[x] + (a + b) // 2) & 255
            elif filtro == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                riga[x] = (riga[x] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        for x in range(w):
            q = riga[x * bpp:(x + 1) * bpp]
            pixel.append((q[0], q[1], q[2], q[3] if bpp == 4 else 255))
        prima = riga
    return w, h, pixel
