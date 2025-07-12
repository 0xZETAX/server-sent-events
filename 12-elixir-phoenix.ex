# Elixir with Phoenix (LiveView)
defmodule SseWeb.EventController do
  use SseWeb, :controller

  def stream(conn, _params) do
    conn
    |> put_resp_header("content-type", "text/event-stream")
    |> put_resp_header("cache-control", "no-cache")
    |> put_resp_header("connection", "keep-alive")
    |> put_resp_header("access-control-allow-origin", "*")
    |> send_chunked(200)
    |> then(&stream_events/1)
  end

  defp stream_events(conn) do
    # Send initial message
    {:ok, conn} = chunk(conn, "data: Connected to Elixir Phoenix SSE\n\n")
    
    # Start streaming
    stream_loop(conn)
  end

  defp stream_loop(conn) do
    message = %{
      message: "Hello from Elixir Phoenix",
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }
    
    data = "data: #{Jason.encode!(message)}\n\n"
    
    case chunk(conn, data) do
      {:ok, conn} ->
        :timer.sleep(2000)
        stream_loop(conn)
      {:error, :closed} ->
        conn
    end
  end
end

# Router configuration
defmodule SseWeb.Router do
  use SseWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SseWeb do
    pipe_through :api
    get "/events", EventController, :stream
  end
end