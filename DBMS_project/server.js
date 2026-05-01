const express = require("express");
const cors = require("cors");
const db = require("./db");

const app = express();
app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("FreelanceHub API Running");
});

app.use("/users", require("./routes/user"));
app.use("/projects", require("./routes/project"));

app.listen(5000, () => console.log("Server running on port 5000"));