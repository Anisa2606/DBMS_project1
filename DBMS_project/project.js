const express = require("express");
const router = express.Router();
const db = require("../db");

router.post("/add", (req, res) => {
  const { client_id, title, budget, deadline } = req.body;

  const sql = "INSERT INTO PROJECT (Client_ID, Title, Budget, Deadline) VALUES (?, ?, ?, ?)";
  db.query(sql, [client_id, title, budget, deadline], (err) => {
    if (err) throw err;
    res.send("Project Added");
  });
});

router.get("/", (req, res) => {
  db.query("SELECT * FROM PROJECT", (err, result) => {
    if (err) throw err;
    res.json(result);
  });
});

module.exports = router;