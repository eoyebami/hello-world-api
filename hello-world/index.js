const express = require('express')
const app = express()

const port = process.env.PORT || 8888;

app.get('/', (req, res) => res.send('Hello World!'))

app.listen(port, (err) => {
    if (err) {
      console.log('Error::', err);
    }
    console.log(`Hello-World app listening on port ${port}`);
});