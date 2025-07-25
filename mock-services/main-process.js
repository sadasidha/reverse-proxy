const express = require('express');
const app = express();

app.all('/:space/:client/:api/:version', (req, res) => {
  res.json({
    space: req.params.space,
    client: req.params.client,
    api: req.params.api,
    version: req.params.version,
    message: "Hello from backend!"
  });
});

app.listen(3000, () => console.log("Main process running"));
