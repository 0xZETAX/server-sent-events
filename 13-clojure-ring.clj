; Clojure with Ring
(ns sse-server.core
  (:require [ring.adapter.jetty :refer [run-jetty]]
            [ring.middleware.cors :refer [wrap-cors]]
            [cheshire.core :as json])
  (:import [java.time Instant]))

(defn sse-headers []
  {"Content-Type" "text/event-stream"
   "Cache-Control" "no-cache"
   "Connection" "keep-alive"
   "Access-Control-Allow-Origin" "*"})

(defn create-sse-stream []
  (let [stream (java.io.PipedInputStream.)
        writer (java.io.PipedOutputStream. stream)]
    
    ; Start background thread for sending messages
    (future
      (with-open [w (java.io.OutputStreamWriter. writer)]
        (try
          (.write w "data: Connected to Clojure Ring SSE\n\n")
          (.flush w)
          
          (loop []
            (let [message {:message "Hello from Clojure Ring"
                          :timestamp (.toString (Instant/now))}
                  data (str "data: " (json/generate-string message) "\n\n")]
              (.write w data)
              (.flush w)
              (Thread/sleep 2000)
              (recur)))
          (catch Exception e
            (println "Stream error:" (.getMessage e))))))
    
    stream))

(defn events-handler [request]
  {:status 200
   :headers (sse-headers)
   :body (create-sse-stream)})

(defn app [request]
  (if (= (:uri request) "/events")
    (events-handler request)
    {:status 404 :body "Not found"}))

(def wrapped-app
  (wrap-cors app :access-control-allow-origin [#".*"]
                 :access-control-allow-methods [:get :post :put :delete]))

(defn -main []
  (run-jetty wrapped-app {:port 3013 :join? false})
  (println "Clojure Ring SSE server running on port 3013"))