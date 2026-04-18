# vfox-grails

A [vfox](https://vfox.dev) plugin for managing [Grails](https://grails.apache.org) SDK versions.

## Requirements

- [vfox](https://vfox.dev/guides/quick-start.html) 0.3.0+

## Installation

```sh
vfox add verglor/grails
```

## Usage

```sh
vfox search grails              # list available versions
vfox install grails@7.0.0      # install a specific version
vfox use grails@7.0.0          # activate a version
```

Activating a version sets `GRAILS_HOME` and prepends `$GRAILS_HOME/bin` to `PATH`.

## Development

Run the full test suite (unit + integration) in Docker:

```sh
docker build -t vfox-grails-test .
docker run --rm vfox-grails-test
```
