const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3000;
const HOST = '0.0.0.0';

const ROOT_DIR = __dirname;
const WEB_DIR = path.join(ROOT_DIR, 'build', 'web');
const APK_PATH = path.join(ROOT_DIR, 'build', 'app', 'outputs', 'flutter-apk', 'app-debug.apk');
const LANDING_PATH = path.join(ROOT_DIR, 'landing.html');

const MIME_TYPES = {
  '.html': 'text/html; charset=UTF-8',
  '.js': 'application/javascript; charset=UTF-8',
  '.json': 'application/json',
  '.css': 'text/css',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.wasm': 'application/wasm',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.apk': 'application/vnd.android.package-archive',
};

const server = http.createServer((req, res) => {
  let reqPath = req.url.split('?')[0];

  // 1. Download Android APK
  if (reqPath === '/lumyra-app.apk' || reqPath === '/app-debug.apk') {
    if (fs.existsSync(APK_PATH)) {
      const stat = fs.statSync(APK_PATH);
      res.writeHead(200, {
        'Content-Type': 'application/vnd.android.package-archive',
        'Content-Length': stat.size,
        'Content-Disposition': 'attachment; filename="lumyra-app.apk"',
      });
      const stream = fs.createReadStream(APK_PATH);
      return stream.pipe(res);
    } else {
      res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
      return res.end('APK not found. Please build it first.');
    }
  }

  // 2. Landing Page
  if (reqPath === '/' || reqPath === '/landing' || reqPath === '/landing.html') {
    if (fs.existsSync(LANDING_PATH)) {
      res.writeHead(200, { 'Content-Type': 'text/html; charset=UTF-8' });
      return fs.createReadStream(LANDING_PATH).pipe(res);
    }
  }

  // 3. Flutter Web App Routes (/app or /app/*)
  if (reqPath.startsWith('/app')) {
    let subPath = reqPath.replace(/^\/app\/?/, '');
    if (!subPath || subPath === '') subPath = 'index.html';

    let filePath = path.join(WEB_DIR, subPath);

    // If file exists, serve it
    if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
      const ext = path.extname(filePath).toLowerCase();
      const contentType = MIME_TYPES[ext] || 'application/octet-stream';
      res.writeHead(200, { 'Content-Type': contentType });
      return fs.createReadStream(filePath).pipe(res);
    } else {
      // Fallback to Flutter Web index.html for SPA routing
      const indexHtml = path.join(WEB_DIR, 'index.html');
      if (fs.existsSync(indexHtml)) {
        res.writeHead(200, { 'Content-Type': 'text/html; charset=UTF-8' });
        return fs.createReadStream(indexHtml).pipe(res);
      }
    }
  }

  // 4. Try serving general static files from build/web (e.g. flutter.js, canvaskit, assets)
  let staticPath = path.join(WEB_DIR, reqPath);
  if (fs.existsSync(staticPath) && fs.statSync(staticPath).isFile()) {
    const ext = path.extname(staticPath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';
    res.writeHead(200, { 'Content-Type': contentType });
    return fs.createReadStream(staticPath).pipe(res);
  }

  // 404 Fallback to Landing
  if (fs.existsSync(LANDING_PATH)) {
    res.writeHead(200, { 'Content-Type': 'text/html; charset=UTF-8' });
    return fs.createReadStream(LANDING_PATH).pipe(res);
  }

  res.writeHead(404, { 'Content-Type': 'text/plain' });
  res.end('Not found');
});

server.listen(PORT, HOST, () => {
  console.log(`🌸 Lumyra Unified Server is running on:`);
  console.log(`   - Local:    http://localhost:${PORT}`);
  console.log(`   - Network:  http://192.168.1.31:${PORT}`);
  console.log(`   - Landing:  http://localhost:${PORT}/`);
  console.log(`   - Flutter Web App: http://localhost:${PORT}/app/`);
  console.log(`   - Android APK:     http://localhost:${PORT}/lumyra-app.apk`);
});
