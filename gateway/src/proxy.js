'use strict';

const http = require('http');
const https = require('https');
const { URL } = require('url');

/**
 * Forwards req to the Dart backend, injects X-User-Id, unwraps { data, disclaimer, error }.
 * Streams multipart bodies unchanged for /scan/photo.
 */
function proxyToBackend(req, res, backendPath) {
  const base = process.env.BACKEND_URL;
  const target = new URL(backendPath, base);
  const isHttps = target.protocol === 'https:';
  const transport = isHttps ? https : http;

  const options = {
    hostname: target.hostname,
    port: target.port || (isHttps ? 443 : 80),
    path: target.pathname + (target.search || ''),
    method: req.method,
    headers: {
      ...req.headers,
      host: target.host,
      'x-user-id': req.userId || '',
    },
  };

  const proxyReq = transport.request(options, (proxyRes) => {
    // For non-JSON content types (shouldn't happen but be safe), pass through raw
    const ct = proxyRes.headers['content-type'] || '';
    if (!ct.includes('application/json')) {
      res.status(proxyRes.statusCode);
      proxyRes.pipe(res);
      return;
    }

    let body = '';
    proxyRes.setEncoding('utf8');
    proxyRes.on('data', (chunk) => { body += chunk; });
    proxyRes.on('end', () => {
      let parsed;
      try {
        parsed = JSON.parse(body);
      } catch {
        return res.status(502).json({ error: { code: 'bad_gateway', message: 'Backend returned non-JSON response' } });
      }

      // Unwrap envelope
      if (parsed.error) {
        return res.status(proxyRes.statusCode).json({ error: parsed.error });
      }

      const payload = { data: parsed.data };
      if (parsed.disclaimer) payload.disclaimer = parsed.disclaimer;
      return res.status(proxyRes.statusCode).json(payload);
    });
  });

  proxyReq.on('error', (err) => {
    console.error('[gateway] backend unreachable:', err.message);
    res.status(503).json({ error: { code: 'backend_unavailable', message: 'Could not reach backend' } });
  });

  req.pipe(proxyReq);
}

module.exports = proxyToBackend;
