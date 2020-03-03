# flump

A lightweight framework for building network applications in ruby.

```ruby
# config.ru

require 'rack/handler/flump'

placeholder_app = ->(env) { [200, {}, []] }

Rack::Handler::Flump.run placeholder_app,
                         host: 'localhost',
                         port: 65432
```

```bash
rackup
```

```bash
$ curl -v http://localhost:65432
* Rebuilt URL to: http://localhost:65432/
*   Trying 127.0.0.1...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 65432 (#0)
> GET / HTTP/1.1
> Host: localhost:65432
> User-Agent: curl/7.54.0
> Accept: */*
>
< HTTP/1.1 200 OK
< Server: Flump
< Date: Mon, 02 Mar 2020 04:37:42 GMT
< Connection: close
<
* Closing connection 0
```
