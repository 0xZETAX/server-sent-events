// Go with standard library
package main

import (
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "time"
)

type Message struct {
    Message   string `json:"message"`
    Timestamp string `json:"timestamp"`
}

func eventsHandler(w http.ResponseWriter, r *http.Request) {
    // Set SSE headers
    w.Header().Set("Content-Type", "text/event-stream")
    w.Header().Set("Cache-Control", "no-cache")
    w.Header().Set("Connection", "keep-alive")
    w.Header().Set("Access-Control-Allow-Origin", "*")

    // Send initial message
    fmt.Fprint(w, "data: Connected to Go SSE\n\n")
    if f, ok := w.(http.Flusher); ok {
        f.Flush()
    }

    // Create a ticker for periodic messages
    ticker := time.NewTicker(2 * time.Second)
    defer ticker.Stop()

    for {
        select {
        case <-ticker.C:
            msg := Message{
                Message:   "Hello from Go",
                Timestamp: time.Now().Format(time.RFC3339),
            }
            
            jsonData, _ := json.Marshal(msg)
            fmt.Fprintf(w, "data: %s\n\n", jsonData)
            
            if f, ok := w.(http.Flusher); ok {
                f.Flush()
            }
        case <-r.Context().Done():
            return
        }
    }
}

func main() {
    http.HandleFunc("/events", eventsHandler)
    log.Println("Go SSE server running on port 3006")
    log.Fatal(http.ListenAndServe(":3006", nil))
}