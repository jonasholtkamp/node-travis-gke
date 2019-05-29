const express = require('express')
const httpStatus = require('http-status')

const app = express()
const port = 8080

app.get('/', (_, res) => {
  res.send('<a href="/200">GET /status</a>') 
})

app.get('/:status', (req, res) => {
  const reqStatus = req.params.status || 200
  const resStatus = httpStatus[reqStatus] ? reqStatus : 400
  const resBody = httpStatus[reqStatus] || `Param '${reqStatus}' is not a valid HTTP status`

  res.status(resStatus).send(resBody)
})

app.listen(port, () => console.log(`Listening on port ${port}`))
