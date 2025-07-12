// Scala with Akka HTTP
import akka.actor.ActorSystem
import akka.http.scaladsl.Http
import akka.http.scaladsl.model._
import akka.http.scaladsl.server.Directives._
import akka.stream.scaladsl.Source
import akka.util.ByteString
import spray.json._
import DefaultJsonProtocol._

import scala.concurrent.duration._
import java.time.Instant

implicit val system = ActorSystem("sse-server")
implicit val executionContext = system.dispatcher

case class Message(message: String, timestamp: String)
implicit val messageFormat = jsonFormat2(Message)

val route = path("events") {
  get {
    complete {
      val source = Source
        .tick(Duration.Zero, 2.seconds, ())
        .map { _ =>
          val message = Message("Hello from Scala Akka HTTP", Instant.now().toString)
          ByteString(s"data: ${message.toJson.toString}\n\n")
        }
        .prepend(Source.single(ByteString("data: Connected to Scala Akka HTTP SSE\n\n")))

      HttpResponse(
        status = StatusCodes.OK,
        headers = List(
          headers.RawHeader("Content-Type", "text/event-stream"),
          headers.RawHeader("Cache-Control", "no-cache"),
          headers.RawHeader("Connection", "keep-alive"),
          headers.RawHeader("Access-Control-Allow-Origin", "*")
        ),
        entity = HttpEntity.Chunked.fromData(ContentTypes.`text/event-stream`, source)
      )
    }
  }
}

Http().newServerAt("localhost", 3011).bind(route)
println("Scala Akka HTTP SSE server running on port 3011")