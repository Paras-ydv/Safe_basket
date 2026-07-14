'use strict';

const jwt = require('jsonwebtoken');

/**
 * Verifies the Bearer token in Authorization header.
 * On success, sets req.userId and calls next().
 * On failure, returns 401.
 */
function authMiddleware(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: { code: 'unauthorized', message: 'Missing or invalid Authorization header' } });
  }

  const token = authHeader.slice(7);
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = payload.sub || payload.userId || payload.id;
    if (!req.userId) {
      return res.status(401).json({ error: { code: 'unauthorized', message: 'Token has no user identifier' } });
    }
    next();
  } catch (err) {
    return res.status(401).json({ error: { code: 'unauthorized', message: 'Invalid or expired token' } });
  }
}

module.exports = authMiddleware;
