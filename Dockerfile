FROM ubuntu:focal as dronebx

ENV DEBIAN_FRONTEND noninteractive

RUN apt update
RUN apt install tzdata -y
ENV TZ=America/New_York
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata


# begin general stuff
RUN apt install lsb-release -y
RUN apt install vim -y
RUN apt install wget -y
RUN apt install gnupg1 -y
# end general stuff 

#begin xpra
RUN apt install ca-certificates -y
RUN wget -O "/usr/share/keyrings/xpra.asc" https://xpra.org/xpra.asc
RUN cd "/etc/apt/sources.list.d/" && \
    wget https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/focal/xpra.sources
RUN apt update && apt install xpra -y
ENV XPRA_DISPLAY=":100"
ARG XPRA_PORT=10000
ENV XPRA_PORT=$XPRA_PORT
EXPOSE $XPRA_PORT
COPY run_in_xpra /usr/bin/run_in_xpra
# end xpra


# begin gazebo install
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN cat /etc/apt/sources.list.d/gazebo-stable.list
RUN wget https://packages.osrfoundation.org/gazebo.key -O - | apt-key add -
RUN apt update
RUN apt install gazebo11 -y
RUN apt install libgazebo11-dev -y
# end gazebo install


RUN apt install xterm -y


#ardupilot dependencies

RUN apt-get update && apt-get install -y git
RUN apt-get install -y gitk git-gui


#clone ardupilot
RUN apt-get update && apt-get install -y sudo
RUN sudo apt-get -y update
RUN git clone https://github.com/ArduPilot/ardupilot.git
RUN cd ardupilot && git submodule update --init --recursive




# done this to shift to non root directory 
RUN useradd -ms /bin/bash nonrootuser
RUN usermod -aG sudo nonrootuser
RUN sudo usermod -aG dialout nonrootuser
RUN echo "nonrootuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /ardupilot
RUN chown -R nonrootuser:nonrootuser /ardupilot
USER nonrootuser

# to run ubuntu.sh file and configure arduupilor 
RUN Tools/environment_install/install-prereqs-ubuntu.sh -y
RUN . ~/.profile
RUN ./waf configure --board CubeBlack
RUN ./waf copter


#install gazebo plugin for ardupilot master

RUN cd ~
RUN git clone https://github.com/khancyr/ardupilot_gazebo.git
RUN cd ardupilot_gazebo

#build and install plugin

RUN mkdir build
RUN cd build
RUN cmake ..
RUN make -j4
RUN sudo make install
RUN echo 'source /usr/share/gazebo/setup.sh' >> ~/.bashrc

#Set paths for models
RUN echo 'export GAZEBO_MODEL_PATH=~/ardupilot_gazebo/models' >> ~/.bashrc
RUN . ~/.bashrc

