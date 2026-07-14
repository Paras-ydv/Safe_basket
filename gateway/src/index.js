'use strict';

require('dotenv').config();

const express = require('express');
const routes = require('./routes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Health check — no auth required
app.get('/', (_req, res) => res.json({ status: 'ok' }));

app.use('/', routes);

// Unhandled errors
app.use((err, _req, res, _next) => {
  console.error('[gateway] unhandled error:', err);
  res.status(500).json({ error: { code: 'internal_error', message: 'Unexpected gateway error' } });
});

app.listen(PORT, () => console.log(`[gateway] listening on port ${PORT}`));
