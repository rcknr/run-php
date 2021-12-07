# Docker PHP-FPM 7.4 & nginx on Alpine Linux
Example PHP-FPM 7.4 & nginx setup for [Google Cloud Run](https://cloud.google.com/run), build on [Alpine Linux](https://www.alpinelinux.org/).

## Details

* Follows the KISS principle (Keep It Simple, Stupid) to make it easy to understand and adjust the image to your needs
* WIP: meant to be used with Firebase: there's a build step to compile [required PHP extensions](https://cloud.google.com/php/grpc)
* Single file nginx config:
  - default alpine config with a single default host listening on port 8080 (Cloud Run default)
  - host configuration based on [Laravel example](https://laravel.com/docs/7.x/deployment#nginx)
  - errors logged to `STDERR` with `warn` level, [built-in logging is overriden](https://stackoverflow.com/a/65330408/805259)
  - access log is off (Cloud Run logs access on its own)
  - root directory is `/run/code/public`
  - [realip module](http://nginx.org/en/docs/http/ngx_http_realip_module.html) configured for Cloud Run
  - upload size configured in one place for both nginx and PHP (100M)
  - `fastcgi_buffering` [is](https://stackoverflow.com/q/63251335/805259) [off](https://stackoverflow.com/q/19539501/805259)
* PHP-FPM pool configuration:
  - listens through UNIX socket
  - WIP: static process management
* Services supervision with [runit](http://smarden.org/runit/):
  - nginx service won't start before PHP-FPM socket exists
