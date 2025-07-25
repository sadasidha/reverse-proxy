const express = require('express');
const app = express();
app.use(express.json());

app.post('/backup', (req, res) => {
  console.log("🔁 Received backup:", req.body);
  res.send("OK");
});

app.listen(3000, () => console.log("Backup server running"));
