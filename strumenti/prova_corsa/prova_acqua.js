// apre la pagina con l'acqua ferma a un tempo, dipinge tutta l'acqua e la salva (per confrontarla con Python);
// l'acqua la fa il processore; con "gl" in fondo la fa la scheda grafica (e la si legge da li')
// uso: node prova_acqua.js pagina.html tempo acqua.raw foto.png [gl]
const { chromium } = require('playwright');
const fs = require('fs');
(async () => {
  const [pagina, t, grezzo, foto, modo] = process.argv.slice(2);
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 1280, height: 900 }, deviceScaleFactor: 1 });
  const errori = [];
  p.on('pageerror', (e) => errori.push(String(e)));
  p.on('console', (m) => { if (m.type() === 'error') errori.push(m.text()); });
  await p.goto('file://' + pagina + '?prova=1&acqua_t=' + t + (modo === 'gl' ? '&gl=1' : ''));
  await p.waitForFunction(() => window.provaAcqua && window.provaAcqua.ACQ.ok && window.provaAcqua.ACQ.tick >= 0,
    null, { timeout: 60000 });
  await p.waitForTimeout(300);
  const b64 = await p.evaluate(() => {
    const { ACQ, dipingi } = window.provaAcqua;
    ACQ.chiave = '';
    const t0 = performance.now();
    dipingi(0, 0, ACQ.W, ACQ.H);
    window.__ms = performance.now() - t0;
    window.__gl = !!ACQ.G;
    let d = ACQ.cur.wi.data;
    if (ACQ.G) {
      // dalla scheda grafica: le righe vanno capovolte
      const gl = ACQ.G.gl, W = ACQ.W, H = ACQ.H, buf = new Uint8Array(W * H * 4);
      gl.readPixels(0, 0, W, H, gl.RGBA, gl.UNSIGNED_BYTE, buf);
      d = new Uint8Array(W * H * 4);
      for (let y = 0; y < H; y++) d.set(buf.subarray((H - 1 - y) * W * 4, (H - y) * W * 4), y * W * 4);
    }
    let s = '';
    for (let i = 0; i < d.length; i += 0x8000) s += String.fromCharCode.apply(null, d.subarray(i, i + 0x8000));
    return btoa(s);
  });
  fs.writeFileSync(grezzo, Buffer.from(b64, 'base64'));
  const ms = await p.evaluate(() => window.__ms), gl = await p.evaluate(() => window.__gl);
  await p.screenshot({ path: foto });
  console.log(gl ? 'scheda grafica:' : 'processore:', 'tutta l acqua dipinta in', ms.toFixed(1), 'ms; errori', JSON.stringify(errori));
  await b.close();
})();
