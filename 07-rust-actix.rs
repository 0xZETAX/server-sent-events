// Rust with Actix-web
use actix_web::{web, App, HttpServer, HttpResponse, Result};
use actix_web::http::header::{CONTENT_TYPE, CACHE_CONTROL, CONNECTION};
use futures::stream::{self, Stream};
use std::time::Duration;
use tokio::time::interval;
use serde_json::json;
use chrono::Utc;

async fn events() -> Result<HttpResponse> {
    let stream = stream::unfold((), |_| async {
        let mut interval = interval(Duration::from_secs(2));
        interval.tick().await; // Skip the first immediate tick
        
        let timestamp = Utc::now().to_rfc3339();
        let message = json!({
            "message": "Hello from Rust Actix-web",
            "timestamp": timestamp
        });
        
        Some((
            Ok::<_, actix_web::Error>(
                web::Bytes::from(format!("data: {}\n\n", message))
            ),
            ()
        ))
    });

    Ok(HttpResponse::Ok()
        .insert_header((CONTENT_TYPE, "text/event-stream"))
        .insert_header((CACHE_CONTROL, "no-cache"))
        .insert_header((CONNECTION, "keep-alive"))
        .insert_header(("Access-Control-Allow-Origin", "*"))
        .streaming(Box::pin(stream)))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .route("/events", web::get().to(events))
    })
    .bind("127.0.0.1:3007")?
    .run()
    .await
}