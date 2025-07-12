// Java with Spring Boot
package com.example.sse;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@SpringBootApplication
@RestController
@CrossOrigin(origins = "*")
public class SseApplication {

    public static void main(String[] args) {
        SpringApplication.run(SseApplication.class, args);
    }

    @GetMapping(value = "/events", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter streamEvents() {
        SseEmitter emitter = new SseEmitter(Long.MAX_VALUE);
        ScheduledExecutorService executor = Executors.newSingleThreadScheduledExecutor();

        try {
            emitter.send("Connected to Java Spring Boot SSE");
        } catch (IOException e) {
            emitter.completeWithError(e);
            return emitter;
        }

        executor.scheduleAtFixedRate(() -> {
            try {
                String message = String.format(
                    "{\"message\": \"Hello from Java Spring Boot\", \"timestamp\": \"%s\"}",
                    LocalDateTime.now().toString()
                );
                emitter.send(message);
            } catch (IOException e) {
                emitter.completeWithError(e);
                executor.shutdown();
            }
        }, 2, 2, TimeUnit.SECONDS);

        emitter.onCompletion(() -> executor.shutdown());
        emitter.onTimeout(() -> executor.shutdown());

        return emitter;
    }
}