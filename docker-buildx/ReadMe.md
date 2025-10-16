# docker-buildx

Buildx is a Docker CLI plugin that extends the docker build command with the full support of the features provided by Moby BuildKit builder toolkit.
It provides the same user experience as docker build with many new features like creating scoped builder instances and building against multiple nodes concurrently.

After installation, Buildx can be accessed through the `docker buildx` command with Docker 19.03.
`docker buildx build` is the command for starting a new build.
With Docker versions older than 19.03 Buildx binary can be called directly to access the `docker buildx` subcommands.

Chocolatey releases for Docker are not done nor supported by Docker, Inc.
This package is maintained by the community members.

LICENSE: Apache 2.0.
