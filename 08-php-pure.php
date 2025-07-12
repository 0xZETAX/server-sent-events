<?php
// Pure PHP SSE Server

header('Content-Type: text/event-stream');
header('Cache-Control: no-cache');
header('Connection: keep-alive');
header('Access-Control-Allow-Origin: *');

// Disable output buffering
if (ob_get_level()) {
    ob_end_clean();
}

// Send initial connection message
echo "data: Connected to PHP SSE\n\n";
flush();

// Function to send SSE message
function sendSSEMessage($data) {
    echo "data: " . json_encode($data) . "\n\n";
    flush();
}

// Keep connection alive and send periodic messages
$startTime = time();
while (true) {
    // Check if client disconnected
    if (connection_aborted()) {
        break;
    }
    
    $message = [
        'message' => 'Hello from PHP',
        'timestamp' => date('c'),
        'uptime' => time() - $startTime
    ];
    
    sendSSEMessage($message);
    
    // Sleep for 2 seconds
    sleep(2);
    
    // Prevent infinite execution
    if ((time() - $startTime) > 300) { // 5 minutes max
        break;
    }
}
?>