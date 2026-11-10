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
