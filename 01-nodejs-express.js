// Node.js with Express
const express = require('express');
const app = express();

app.use(express.static('public'));

app.get('/events', (req, res) => {
  // Set SSE headers
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
    'Access-Control-Allow-Origin': '*'
  });

  // Send initial connection message
  res.write('data: Connected to Node.js Express SSE\n\n');

  // Send periodic messages
  const interval = setInterval(() => {
    const timestamp = new Date().toISOString();
    res.write(`data: {"message": "Hello from Node.js Express", "timestamp": "${timestamp}"}\n\n`);
  }, 2000);

  // Clean up on client disconnect
  req.on('close', () => {
    clearInterval(interval);
    res.end();
  });
});

app.listen(3001, () => {
  console.log('Node.js Express SSE server running on port 3001');
});