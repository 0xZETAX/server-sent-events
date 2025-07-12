# Server-Sent Events (SSE) Examples

A comprehensive collection of Server-Sent Events implementations across 20 popular backend languages and frameworks.

## What are Server-Sent Events (SSE)?

Server-Sent Events (SSE) is a web standard that allows a server to push data to a web page in real-time. Unlike traditional HTTP requests where the client asks for data, SSE enables the server to send data to the client whenever new information is available.

## How SSE Works

1. **Client Connection**: The browser opens a persistent HTTP connection to the server
2. **Server Response**: The server keeps the connection open and sends data as it becomes available
3. **Real-time Updates**: Data flows from server to client in real-time without polling
4. **Automatic Reconnection**: The browser automatically reconnects if the connection is lost

## SSE vs Other Technologies

| Feature | SSE | WebSockets | Polling |
|---------|-----|------------|---------|
| **Complexity** | Simple | Complex | Simple |
| **Direction** | Server → Client | Bidirectional | Client → Server |
| **Protocol** | HTTP | WebSocket | HTTP |
| **Reconnection** | Automatic | Manual | N/A |
| **Overhead** | Low | Low | High |

## When to Use SSE

✅ **Perfect for:**
- Live notifications
- Real-time dashboards
- Stock price updates
- Chat applications (receive only)
- Live sports scores
- System monitoring
- Progress updates

❌ **Not ideal for:**
- Bidirectional communication
- File uploads
- Gaming (low latency required)
- Binary data transmission

## Basic SSE Implementation

### Client-Side (JavaScript)

```javascript
// Connect to SSE endpoint
const eventSource = new EventSource('/events');

// Listen for messages
eventSource.onmessage = function(event) {
  const data = JSON.parse(event.data);
  console.log('Received:', data);
};

// Handle connection opened
eventSource.onopen = function() {
  console.log('Connected to SSE');
};

// Handle errors
eventSource.onerror = function(error) {
  console.error('SSE Error:', error);
};

// Close connection
eventSource.close();
```

### Server-Side (Basic Pattern)

```javascript
// Set SSE headers
response.writeHead(200, {
  'Content-Type': 'text/event-stream',
  'Cache-Control': 'no-cache',
  'Connection': 'keep-alive',
  'Access-Control-Allow-Origin': '*'
});

// Send data
const data = { message: 'Hello', timestamp: new Date().toISOString() };
response.write(`data: ${JSON.stringify(data)}\n\n`);
```

## Available Examples

This repository contains SSE implementations in 20 different languages/frameworks:

1. **Node.js** - Express.js
2. **Python** - Flask
3. **Python** - FastAPI
4. **Java** - Spring Boot
5. **C#** - .NET Core
6. **Go** - Standard Library
7. **Rust** - Actix-web
8. **PHP** - Pure PHP
9. **Ruby** - Sinatra
10. **Kotlin** - Ktor
11. **Scala** - Akka HTTP
12. **Elixir** - Phoenix
13. **Clojure** - Ring
14. **Haskell** - Scotty
15. **Dart** - Shelf
16. **Swift** - Vapor
17. **Deno** - Oak
18. **TypeScript** - Express
19. **Perl** - Mojolicious
20. **Lua** - OpenResty

## Running the Examples

### Prerequisites

Make sure you have the respective runtime/compiler installed for each language you want to test.

### Frontend Demo

```bash
# Install dependencies
npm install

# Start the React demo
npm run dev
```

### Backend Examples

Each example runs on a different port (3001-3020):

```bash
# Node.js Express (Port 3001)
node examples/01-nodejs-express.js

# Python Flask (Port 3002)
python examples/02-python-flask.py

# Python FastAPI (Port 3003)
uvicorn examples.03-python-fastapi:app --host 0.0.0.0 --port 3003

# Go (Port 3006)
go run examples/06-go-stdlib.go

# And so on...
```

### Testing SSE Connections

1. Start any backend server
2. Open the React demo in your browser
3. Click "Connect" on the corresponding language card
4. Watch real-time messages stream from the server

## SSE Message Format

SSE uses a simple text-based format:

```
data: This is a simple message\n\n

data: {"message": "JSON data", "timestamp": "2024-01-01T12:00:00Z"}\n\n

event: custom-event\n
data: This is a custom event\n\n

id: 123\n
data: Message with ID for replay\n\n

retry: 3000\n
data: Retry after 3 seconds if disconnected\n\n
```

## Browser Support

SSE is supported in all modern browsers:

- ✅ Chrome 6+
- ✅ Firefox 6+
- ✅ Safari 5+
- ✅ Edge 79+
- ✅ Opera 11+
- ❌ Internet Explorer (use polyfill)

## Common Patterns

### Error Handling

```javascript
eventSource.onerror = function(event) {
  if (eventSource.readyState === EventSource.CLOSED) {
    console.log('Connection was closed');
  } else {
    console.log('An error occurred');
  }
};
```

### Custom Events

```javascript
// Server sends
response.write(`event: notification\ndata: ${JSON.stringify(data)}\n\n`);

// Client listens
eventSource.addEventListener('notification', function(event) {
  const data = JSON.parse(event.data);
  showNotification(data);
});
```

### Authentication

```javascript
const eventSource = new EventSource('/events', {
  headers: {
    'Authorization': 'Bearer ' + token
  }
});
```

## Best Practices

1. **Always set proper headers** - Content-Type, Cache-Control, Connection
2. **Handle client disconnections** - Clean up resources on the server
3. **Implement heartbeat** - Send periodic ping messages
4. **Use JSON for structured data** - Easier to parse on the client
5. **Add error handling** - Handle network issues gracefully
6. **Implement authentication** - Secure your SSE endpoints
7. **Consider connection limits** - Browsers limit concurrent connections

## Troubleshooting

### Common Issues

1. **CORS Errors**: Add proper CORS headers on the server
2. **Connection Timeout**: Implement heartbeat mechanism
3. **Memory Leaks**: Always close EventSource when done
4. **Buffering**: Flush the response after each write

### Debug Tips

```javascript
// Check connection state
console.log(eventSource.readyState);
// 0 = CONNECTING, 1 = OPEN, 2 = CLOSED

// Monitor all events
eventSource.onmessage = console.log;
eventSource.onerror = console.error;
```

## Contributing

Feel free to contribute additional language examples or improvements to existing ones!

## License

MIT License - feel free to use these examples in your projects.