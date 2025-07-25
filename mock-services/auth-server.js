const express = require('express');
const app = express();

app.get('/validate', (req, res) => {
  const { name, client, target_api, version } = req.query;
  const auth = req.headers.authorization;

  if (auth === 'Bearer validtoken') {
    return res.send('Authorized');
  }

  res.status(401).send('Unauthorized');
});

app.listen(3000, () => console.log("Auth server running"));
