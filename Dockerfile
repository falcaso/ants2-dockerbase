# Download base image ubuntu 18.04
FROM ubuntu:18.04
# About the custom image
LABEL description="This is a custom Docker Image for ANTS2."

ARG ROOTTGZ=root_v6.22.06.Linux-ubuntu18-x86_64-gcc7.5.tar.gz
ARG JOBS=14

# Update all packages
RUN apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade
# Install packages
# Essential utilities
RUN apt-get -y install git nano wget
# Development environment (gcc, make, etc. + cmake)
RUN apt-get -y install build-essential cmake
# Qt5 base system + modules required by ANTS
RUN apt-get -y install qt5-default libqt5websockets5-dev qtscript5-dev qtwebengine5-dev
# additional libs needed by ROOT
RUN apt-get -y install libtbb-dev
# additional libs needed by ANTS
RUN apt-get -y install libeigen3-dev
# xeyes to test X11 forwarding + some X11 packaged needed by ROOT pulled as dependencies
RUN apt-get -y install x11-apps
# OpenGL, FLANN and FANN
RUN apt-get -y install libgl2ps-dev libflann-dev libfann-dev liblz4-dev
# Python scripting
RUN apt-get -y install python3-dev libpythonqt-qt5-python3-dev

# ROOT Installation
RUN wget https://root.cern.ch/download/$ROOTTGZ
RUN tar -xzf $ROOTTGZ -C /opt
RUN rm $ROOTTGZ
RUN echo ". /opt/root/bin/thisroot.sh" >> ~/.bashrc

# Ncrystal
RUN cd / && git clone https://github.com/mctools/ncrystal.git # refresh+1!
RUN cd /ncrystal && cmake . && make -j$JOBS && make install
RUN echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/lib" >> ~/.bashrc
#ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

# ANTS installation
# RUN mkdir /ants2 && cd /ants2 && git clone -b Dev https://github.com/falcaso/ANTS2-my-version.git # refresh+1!
RUN mkdir /ants2 && cd /ants2 && git clone -b Dev https://github.com/andrmor/ANTS2.git # refresh+1!
RUN cd /ants2/ANTS2 && mkdir build

### the effect of sourcing a script lasts only inside one RUN command
### so we need to pack it together with compilation as a one-liner
RUN /bin/bash -c "source /opt/root/bin/thisroot.sh \
    && cd /ants2/ANTS2/build && qmake \"CONFIG += ants2_docker\" ../src/ants2.pro && make -j$JOBS"

# Additional Python packages
RUN apt-get -y install python3-pip
#RUN pip3 install PyQt5
RUN pip3 install numpy scipy pandas scikit-learn
## Could also install nestpy here...
# pip3 install nestpy
## or...
# RUN git clone https://github.com/NESTCollaboration/nestpy
# RUN cd nestpy && python3 setup.py install --user

ENV LD_LIBRARY_PATH=/opt/root/lib:/ncrystal
COPY startup.sh /root/
ENTRYPOINT ["/root/startup.sh"]


