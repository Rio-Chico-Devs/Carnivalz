// apre la pagina con l'acqua ferma a un tempo, dipinge tutta l'acqua e la salva (per confrontarla con Python)
const { chromium } = require('playwright');
const fs = require('fs');
(async () => {
  const [pagina, t, grezzo, foto] = process.argv.slice(2);
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 1280, height: 900 }, deviceScaleFactor: 1 });
  const errori = [];
  p.on('pageerror', (e) => errori.push(String(e)));
  p.on('console', (m) => { if (m.type() === 'error') errori.push(m.text()); });
  await p.goto('file://' + pagina + '?prova=1&acqua_t=' + t);
  await p.waitForFunction(() => window.provaAcqua && window.provaAcqua.ACQ.ok && window.provaAcqua.ACQ.tick >= 0,
    null, { timeout: 60000 });
  await p.waitForTimeout(300);
  const b64 = await p.evaluate(() => {
    const { ACQ, dipingi } = window.provaAcqua;
    ACQ.chiave = '';
    const t0 = performance.now();
    dipingi(0, 0, ACQ.W, ACQ.H);
    window.__ms = performance.now() - t0;
    const d = ACQ.wi.data;
    let s = '';
    for (let i = 0; i < d.length; i += 0x8000) s += String.fromCharCode.apply(null, d.subarray(i, i + 0x8000));
    return btoa(s);
  });
  fs.writeFileSync(grezzo, Buffer.from(b64, 'base64'));
  const ms = await p.evaluate(() => window.__ms);
  await p.screenshot({ path: foto });
  console.log('tutta l acqua dipinta in', ms.toFixed(1), 'ms; errori', JSON.stringify(errori));
  await b.close();
})();
