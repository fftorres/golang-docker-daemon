# Go (golang) Docker daemon image

> Docker container built on top of official golang container with docker daemon available

Image is available at [`quay.io/hellofresh/golang-docker-daemon`](https://quay.io/hellofresh/golang-docker-daemon).

## Usage in Concorse CI

It is important to run task that uses the image in privileged mode with `privileged: true` - this
is required for docker daemon to start inside docker container.

Pipeline task example:

```yaml
- name: run-integration-tests
  serial: true
  plan:
  - get: source-code
    version: every
    trigger: true

  - put: source-code
    params:
      path: source-code
      context: integration-tests
      status: pending

  - task: Run integration tests
    privileged: true
    file: source-code/ci/tasks/integration-tests.yml
    params:
      PROJECT_SRC: {{project_src}}

    on_success:
      put: source-code
      params:
        path: source-code
        context: integration-tests
        status: success

    on_failure:
      put: source-code
      params:
        path: source-code
        context: integration-tests
        status: failure
```

Task file example:

```yaml
---
platform: linux

image_resource:
  type: docker-image
  source: {repository: quay.io/hellofresh/golang-docker-daemon}

inputs:
  - name: source-code

run:
  path: source-code/ci/scripts/integration-tests.sh

```

Docker daemon does not start automatically, you need to start it manually. Before exiting script it
is very important to stop docker daemon in explicit way.

Integration tests runner example:

```sh
#!/bin/sh

# Do not exit script if one of the commands fail - process all failures manually
set +e

CWD=$(pwd)

echo "Running docker containers required for integration tests" && \
    service docker start && \
    sleep 3 && \
    docker run --detach --name janus-storage --publish 6379:6379 redis:3.0-alpine && \
    docker run --detach --name janus-database --publish 27017:27017 mongo:3
exit_code=$?
if [ ${exit_code} -ne 0 ]; then
    echo "Failed to run docker containers"
    service docker stop
    exit ${exit_code}
fi

# Prepare all required dependencies first and then run tests
godog --random
exit_code=$?

if [ ${exit_code} -ne 0 ]; then
    echo "Tests failed"
    # flush some logs here
fi

service docker stop
exit ${exit_code}
```

## Versions

`quay.io/hellofresh/golang-docker-daemon:latest` has the following versions:

* [golang](./go-version.md)
* [docker](./docker-version.md)

## TODO:

* [ ] Minimize image size (maybe try to implement the same on top of `golang:x.y.z-alpine`)
* [ ] CI pipeline to build and push images
