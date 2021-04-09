# ants2-geant4-x11

Dockerized GUI version of ANTS2 package with optional Geant4 back-end and graphics exported via plain X11 

## Build

Argument JOBS in Dockerfile controls number of make jobs running in parallel (-j argument) during the build process. You can adjust it according to the number of threads in your system and then build with 

`docker build -t a2g4x11 .`

## Usage

Create two folders for sharing files between the host and the ANTS inside the container, for example
`ants2docker/config` and `ants2docker/work` in your home directory. Then start a container: 

`docker run -it -v $HOME/ants2docker/config:/ants_config -v $HOME/ants2docker/work:/work -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -e UID=$(id -u) -e GID=$(id -g) -e USER=$USER vovasolo/a2g4x11`
