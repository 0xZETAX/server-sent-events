# Perl with Mojolicious
use Mojolicious::Lite -signatures;
use Mojo::JSON qw(encode_json);
use Time::HiRes qw(sleep);

# Enable CORS
hook after_render => sub ($c, @) {
  $c->res->headers->header('Access-Control-Allow-Origin' => '*');
  $c->res->headers->header('Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS');
  $c->res->headers->header('Access-Control-Allow-Headers' => 'Content-Type, Authorization');
};

get '/events' => sub ($c) {
  $c->res->headers->content_type('text/event-stream');
  $c->res->headers->cache_control('no-cache');
  $c->res->headers->connection('keep-alive');
  
  # Create a stream
  my $stream = Mojo::IOLoop::Stream->new;
  
  $c->write("data: Connected to Perl Mojolicious SSE\n\n");
  
  # Send periodic messages
  my $timer = Mojo::IOLoop->recurring(2 => sub {
    my $message = encode_json({
      message => 'Hello from Perl Mojolicious',
      timestamp => scalar(localtime),
    });
    
    $c->write("data: $message\n\n");
  });
  
  # Clean up on disconnect
  $c->on(finish => sub {
    Mojo::IOLoop->remove($timer);
  });
  
  # Keep connection open
  $c->render_later;
};

# Start the application
app->start('daemon', '-l', 'http://*:3019');