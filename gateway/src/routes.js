'use strict';

const { Router } = require('express');
const authMiddleware = require('./authMiddleware');
const proxyToBackend = require('./proxy');

const router = Router();

// All routes require auth — userId is injected into X-User-Id by proxyToBackend
router.use(authMiddleware);

// POST /scan/barcode
router.post('/scan/barcode', (req, res) => proxyToBackend(req, res, '/scan/barcode'));

// POST /scan/photo  (multipart — proxy streams it unchanged)
router.post('/scan/photo', (req, res) => proxyToBackend(req, res, '/scan/photo'));

// Admin routes — backend enforces ADMIN_ALLOWLIST check on X-User-Id
router.post('/admin/edc', (req, res) => proxyToBackend(req, res, '/admin/edc'));
router.put('/admin/edc/:id', (req, res) => proxyToBackend(req, res, `/admin/edc/${req.params.id}`));
router.post('/admin/edc/:id/aliases', (req, res) => proxyToBackend(req, res, `/admin/edc/${req.params.id}/aliases`));
router.delete('/admin/edc/:id/aliases/:aliasId', (req, res) =>
  proxyToBackend(req, res, `/admin/edc/${req.params.id}/aliases/${req.params.aliasId}`)
);

module.exports = router;
