// Deno with Oak
import { Application, Router } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import { oakCors } from "https://deno.land/x/cors@v1.2.2/mod.ts";

const router = new Router();

router.get("/events", (context) => {
  const target = context.sendEvents();
  
  // Send initial message
  target.dispatchMessage("Connected to Deno Oak SSE");
  
  // Send periodic messages
  const interval = setInterval(() => {
    const message = {
      message: "Hello from Deno Oak",
      timestamp: new Date().toISOString(),
    };
    
    target.dispatchMessage(JSON.stringify(message));
  }, 2000);
  
  // Clean up on disconnect
  target.addEventListener("close", () => {
    clearInterval(interval);
  });
});

const app = new Application();

app.use(oakCors({
  origin: "*",
  credentials: true,
}));

app.use(router.routes());
app.use(router.allowedMethods());

console.log("Deno Oak SSE server running on port 3017");
await app.listen({ port: 3017 });