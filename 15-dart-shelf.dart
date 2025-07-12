// Dart with Shelf
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

Response eventsHandler(Request request) {
  final controller = StreamController<String>();
  
  // Send initial message
  controller.add('data: Connected to Dart Shelf SSE\n\n');
  
  // Start periodic timer
  Timer.periodic(Duration(seconds: 2), (timer) {
    if (controller.isClosed) {
      timer.cancel();
      return;
    }
    
    final message = {
      'message': 'Hello from Dart Shelf',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    controller.add('data: ${jsonEncode(message)}\n\n');
  });
  
  // Clean up when client disconnects
  request.context['shelf.io.connection_info']?.onDone.then((_) {
    controller.close();
  });
  
  return Response.ok(
    controller.stream,
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    },
  );
}

void main() async {
  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler((request) {
        if (request.url.path == 'events') {
          return eventsHandler(request);
        }
        return Response.notFound('Not found');
      });

  final server = await shelf_io.serve(handler, '0.0.0.0', 3015);
  print('Dart Shelf SSE server running on port ${server.port}');
}