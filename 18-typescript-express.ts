// TypeScript with Express
import express, { Request, Response } from 'express';
import cors from 'cors';

interface SSEMessage {
  message: string;
  timestamp: string;
}

const app = express();

app.use(cors());

app.get('/events', (req: Request, res: Response) => {
  // Set SSE headers
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
    'Access-Control-Allow-Origin': '*'
  });

  // Send initial connection message
  res.write('data: Connected to TypeScript Express SSE\n\n');

  // Send periodic messages
  const interval = setInterval(() => {
    const message: SSEMessage = {
      message: 'Hello from TypeScript Express',
      timestamp: new Date().toISOString()
    };
    
    res.write(`data: ${JSON.stringify(message)}\n\n`);
  }, 2000);

  // Clean up on client disconnect
  req.on('close', () => {
    clearInterval(interval);
    res.end();
  });

  req.on('error', (err) => {
    console.error('SSE request error:', err);
    clearInterval(interval);
    res.end();
  });
});

const PORT = process.env.PORT || 3018;
app.listen(PORT, () => {
  console.log(`TypeScript Express SSE server running on port ${PORT}`);
});