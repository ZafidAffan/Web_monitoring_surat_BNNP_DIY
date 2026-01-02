const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).json({ message: 'Unauthorized: token tidak ditemukan' });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // { id, role, divisi }
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Unauthorized: token tidak valid' });
  }
};
