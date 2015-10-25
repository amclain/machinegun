# machinegun

[![Gem Version](https://badge.fury.io/rb/machinegun.svg)](https://badge.fury.io/rb/machinegun)
[![Coverage Status](https://coveralls.io/repos/amclain/machinegun/badge.svg?branch=master&service=github)](https://coveralls.io/github/amclain/machinegun?branch=master)
[![API Documentation](https://img.shields.io/badge/docs-api-blue.svg)](http://www.rubydoc.info/gems/machinegun)
[![MIT License](https://img.shields.io/badge/license-MIT-yellowgreen.svg)](https://github.com/amclain/machinegun/blob/master/license.txt)

An automatic reloading Rack development web server for Ruby.

This gem was inspired by [shotgun](https://github.com/rtomayko/shotgun), which reloads the application on every request to ensure that the latest code is running. However, reloading on request can cause performance problems for applications that consume a lot of memory and/or generate a lot of requests. machinegun solves this problem by reloading the application when there are changes to the filesystem, instead of reloading on each request. This allows for the best of both worlds: A web server that reloads when changes to the code are made, and also performs quickly when serving requests.

## Installation

```text
$ gem install machinegun
```

## Use

The `machinegun` command replaces `rackup`. rackup's command line options should be compatible with the machinegun executable. Since machinegun is a wrapper around Rack, your project also needs a [Rack configuration file](https://github.com/rack/rack/wiki/(tutorial)-rackup-howto#config-file-syntax), typically `config.ru`.

For example, the following command will launch the web server on port 9393 and bind it to all network adapters:

```text
$ machinegun -p 9393 -o 0.0.0.0
```

## Development

To skip the integration tests during development, run the test suite with:
```text
$ SKIP_INTEGRATION_TESTS=true bundle exec rake
```