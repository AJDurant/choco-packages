# choco-containerd

containerd is an industry-standard container runtime with an emphasis on
simplicity, robustness, and portability. It is available as a daemon for Linux and
Windows, which can manage the complete container lifecycle of its host system: image
transfer and storage, container execution and supervision, low-level storage and network
attachments, etc.

This package contains the containerd engine for Windows to run Windows containers on Windows hosts.
containerd is designed to be embedded into a larger system, rather than being used directly by developers or end-users.

In order for containerd to be useful to you, your docker engine needs to be configured to use it.
The installer will attempt to do this for you. For example add to your `daemon.json`:

```
{
    "default-runtime": "io.containerd.runhcs.v1",
    "features": {
        "containerd-snapshotter": true
    }
}
```

#### Package Parameters
The following package parameters can be set:

* `/StartService` - Automatically start (or restart) the containerd service after install (or upgrade)

To pass parameters, use `--params "''"` (e.g. `choco install containerd [other options] --params="'/StartService'"`).
To have choco remember parameters on upgrade, be sure to set `choco feature enable -n=useRememberedArgumentsForUpgrades`.

Chocolatey releases for containerd are not done nor supported by the containerd maintainers.
This package is maintained by the community members.

LICENSE: Apache 2.0.
