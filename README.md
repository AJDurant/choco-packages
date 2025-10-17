[![Auto Update][auto_update_badge]][auto_update_actions]

[auto_update_badge]: https://github.com/ajdurant/choco-packages/workflows/Auto%20Update/badge.svg
[auto_update_actions]: https://github.com/ajdurant/choco-packages/actions?query=workflow%3A%22Auto+Update%22

----

# choco-packages

This repository contains my [chocolatey packages](https://docs.chocolatey.org/en-us/getting-started#what-are-chocolatey-packages) which are automatically updated by [Chocolatey-AU](https://github.com/chocolatey-community/chocolatey-au).
[GitHub Actions](https://github.com/features/actions) is used for CI/CD. ([Update Report](https://gist.github.com/ajdurant/460a993a176efcd009c2ffaccd4fb85f))

The packages are available in the Chocolatey Community: [chocolatey/ajdurant](https://community.chocolatey.org/profiles/ajdurant)

## Package List

| id                             | title                                                         | version                                                                  | downloads                                                                    | embedded? | auto update? |
|--------------------------------|---------------------------------------------------------------|--------------------------------------------------------------------------|------------------------------------------------------------------------------|-----------|--------------|
| [containerd](containerd)       | [containerd](https://github.com/containerd/containerd)        | [![containerd version][containerd_version]][containerd_package]          | [![containerd downloads][containerd_downloads]][containerd_package]          |           |              |
| [docker-buildx](docker-buildx) | [docker-buildx](https://github.com/docker/buildx)             | [![docker-buildx version][docker-buildx_version]][docker-buildx_package] | [![docker-buildx downloads][docker-buildx_downloads]][docker-buildx_package] | ✓         |              |
| [docker-engine](docker-engine) | [docker-engine](https://github.com/moby/moby)                 | [![docker-engine version][docker-engine_version]][docker-engine_package] | [![docker-engine downloads][docker-engine_downloads]][docker-engine_package] |           | ✓            |
| [sqlitespy](sqlitespy)         | [SQLiteSpy](https://www.yunqa.de/delphi/apps/sqlitespy/index) | [![sqlitespy version][sqlitespy_version]][sqlitespy_package]             | [![sqlitespy downloads][sqlitespy_downloads]][sqlitespy_package]             | ✓         | ✓            |

[containerd_version]: https://img.shields.io/chocolatey/v/containerd
[containerd_downloads]: https://img.shields.io/chocolatey/dt/containerd
[containerd_package]: https://chocolatey.org/packages/containerd
[docker-buildx_version]: https://img.shields.io/chocolatey/v/docker-buildx
[docker-buildx_downloads]: https://img.shields.io/chocolatey/dt/docker-buildx
[docker-buildx_package]: https://chocolatey.org/packages/docker-buildx
[docker-engine_version]: https://img.shields.io/chocolatey/v/docker-engine
[docker-engine_downloads]: https://img.shields.io/chocolatey/dt/docker-engine
[docker-engine_package]: https://chocolatey.org/packages/docker-engine
[sqlitespy_version]: https://img.shields.io/chocolatey/v/sqlitespy
[sqlitespy_downloads]: https://img.shields.io/chocolatey/dt/sqlitespy
[sqlitespy_package]: https://chocolatey.org/packages/sqlitespy

## References

- [Create Packages](https://docs.chocolatey.org/en-us/create/create-packages)
- [Automatic Packaging](https://github.com/chocolatey-community/chocolatey-au) with [GitHub Actions](https://docs.github.com/en/actions)
