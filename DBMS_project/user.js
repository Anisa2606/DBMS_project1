const express = require("express");
const router = express.Router();
const db = require("../db");

router.post("/register", (req, res) => {
  const { name, email, password, role } = req.body;

  const sql = "INSERT INTO USER (Name, Email, Password, Role) VALUES (?, ?, ?, ?)";
  db.query(sql, [name, email, password, role], (err, result) => {
    if (err) throw err;
    res.send("User Registered");
  });
});

router.get("/", (req, res) => {
  db.query("SELECT * FROM USER", (err, result) => {
    if (err) throw err;
    res.json(result);
  });
});

module.exports = router;