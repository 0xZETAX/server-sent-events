// Swift with Vapor
import Vapor
import Foundation

func configure(_ app: Application) throws {
    // Configure CORS
    app.middleware.use(CORSMiddleware(configuration: .init(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
    )))
    
    // SSE route
    app.get("events") { req -> Response in
        let response = Response(
            status: .ok,
            headers: HTTPHeaders([
                ("Content-Type", "text/event-stream"),
                ("Cache-Control", "no-cache"),
                ("Connection", "keep-alive")
            ])
        )
        
        let stream = AsyncThrowingStream<ByteBuffer, Error> { continuation in
            let task = Task {
                // Send initial message
                let initialData = "data: Connected to Swift Vapor SSE\n\n"
                var buffer = ByteBufferAllocator().buffer(capacity: initialData.count)
                buffer.writeString(initialData)
                continuation.yield(buffer)
                
                // Send periodic messages
                while !Task.isCancelled {
                    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                    
                    let message: [String: Any] = [
                        "message": "Hello from Swift Vapor",
                        "timestamp": ISO8601DateFormatter().string(from: Date())
                    ]
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: message)
                    let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
                    let sseData = "data: \(jsonString)\n\n"
                    
                    var buffer = ByteBufferAllocator().buffer(capacity: sseData.count)
                    buffer.writeString(sseData)
                    continuation.yield(buffer)
                }
                
                continuation.finish()
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
        
        response.body = .init(asyncSequence: stream)
        return response
    }
}

// main.swift
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }

try configure(app)
try app.run()