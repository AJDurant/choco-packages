# docker-engine

Docker is an open platform for developers and sysadmins to build, ship, and run
distributed applications. This package contains the docker engine for Windows to run
Windows containers on Windows hosts.

NOTE: Docker engine for Windows is is simply the service to run containers. You might
want to have a look at the "docker-desktop" package for better usability.

From v23 docker engine is installed into `$env:ProgramFiles\docker` (the default docker
location). A shim is still generated for the docker cli.

### Package Specific
This package by default creates the group `docker-users` and adds the installing user to
it, you can customise this with package parameters. In order to communicate with docker
you will need to log out and back in.

**Please Note**: The docker engine requires the Windows Features: Containers and
Microsoft-Hyper-V to be installed in order to function correctly. You can install these
with the chocolatey command:
`choco install Containers Microsoft-Hyper-V --source windowsfeatures`

#### Package Parameters
The following package parameters can be set:

* `/DockerGroup:` - Name of the user group for using docker - defaults to "docker-users"
* `/noAddGroupUser` - Prevent adding the current user to the DockerGroup
* `/StartService` - Automatically start (or restart) the docker service after install (or upgrade)

To pass parameters, use `--params "''"` (e.g. `choco install docker-engine [other options] --params="'/DockerGroup:my-docker-group /noAddGroupUser'"`).
To have choco remember parameters on upgrade, be sure to set `choco feature enable -n=useRememberedArgumentsForUpgrades`.

**Please Note**: If you change the DockerGroup having previously installed
docker-engine, the `daemon.json` config file will not be overwritten, you will need to
manually update it.

Chocolatey releases for Docker are not done nor supported by Docker, Inc.
This package is maintained by the community members.

LICENSE: Apache 2.0.
