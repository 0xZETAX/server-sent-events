// Kotlin with Ktor
import io.ktor.application.*
import io.ktor.features.*
import io.ktor.http.*
import io.ktor.response.*
import io.ktor.routing.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import kotlinx.coroutines.delay
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import java.time.Instant

@Serializable
data class Message(val message: String, val timestamp: String)

fun main() {
    embeddedServer(Netty, port = 3010) {
        install(CORS) {
            anyHost()
            allowCredentials = true
        }
        
        routing {
            get("/events") {
                call.response.headers.append("Content-Type", "text/event-stream")
                call.response.headers.append("Cache-Control", "no-cache")
                call.response.headers.append("Connection", "keep-alive")
                
                call.respondTextWriter(contentType = ContentType.Text.EventStream) {
                    write("data: Connected to Kotlin Ktor SSE\n\n")
                    flush()
                    
                    while (true) {
                        val message = Message(
                            message = "Hello from Kotlin Ktor",
                            timestamp = Instant.now().toString()
                        )
                        
                        write("data: ${Json.encodeToString(Message.serializer(), message)}\n\n")
                        flush()
                        delay(2000)
                    }
                }
            }
        }
    }.start(wait = true)
}