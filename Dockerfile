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

RUN apt install build-essential -y
RUN apt install git -y

#clone ardupilot
WORKDIR /src 

# added a user for doing the work
ARG USER_NAME=ardupilot
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd ${USER_NAME} --gid ${USER_GID}\
    && useradd -l -m ${USER_NAME} -u ${USER_UID} -g ${USER_GID} -s /bin/bash

WORKDIR /src/ardupilot

RUN apt-get update && apt-get install --no-install-recommends -y \
    lsb-release \
    sudo \
    tzdata \
    bash-completion

ENV USER=${USER_NAME}
RUN echo "ardupilot ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER_NAME}
RUN chmod 0440 /etc/sudoers.d/${USER_NAME}

RUN git clone https://github.com/ArduPilot/ardupilot.git
RUN cd ardupilot && git submodule update --init --recursive

#RUN chown -R ${USER_NAME}:${USER_NAME} /${USER_NAME}

USER ${USER_NAME}

ENV SKIP_AP_EXT_ENV=1 SKIP_AP_GRAPHIC_ENV=1 SKIP_AP_COV_ENV=1 SKIP_AP_GIT_CHECK=1

WORKDIR /src/ardupilot
RUN cd ardupilot && Tools/environment_install/install-prereqs-ubuntu.sh -y
RUN . ~/.profile


# add waf alias to ardupilot waf to .ardupilot_env
RUN echo "alias waf=\"/${USER_NAME}/waf\"" >> ~/.ardupilot_env

# Check that local/bin are in PATH for pip --user installed package
RUN echo "if [ -d \"\$HOME/.local/bin\" ] ; then\nPATH=\"\$HOME/.local/bin:\$PATH\"\nfi" >> ~/.ardupilot_env

# Create entrypoint as docker cannot do shell substitution correctly
RUN export ARDUPILOT_ENTRYPOINT="/home/${USER_NAME}/ardupilot_entrypoint.sh" \
    && echo "#!/bin/bash" > $ARDUPILOT_ENTRYPOINT \
    && echo "set -e" >> $ARDUPILOT_ENTRYPOINT \
    && echo "source /home/${USER_NAME}/.ardupilot_env" >> $ARDUPILOT_ENTRYPOINT \
    && echo 'exec "$@"' >> $ARDUPILOT_ENTRYPOINT \
    && chmod +x $ARDUPILOT_ENTRYPOINT \
    && sudo mv $ARDUPILOT_ENTRYPOINT /ardupilot_entrypoint.sh

# Set the buildlogs directory into /tmp as other directory aren't accessible
ENV BUILDLOGS=/tmp/buildlogs



#install gazebo plugin for ardupilot master

#RUN cd /Users/ATIFHANIF/Downloads/dronebx-main
RUN sudo git clone https://github.com/khancyr/ardupilot_gazebo.git 
RUN cd ardupilot_gazebo

#build and install plugin

RUN cd ardupilot_gazebo && sudo mkdir build 
#RUN cd ardupilot_gazebo/build
RUN cd ardupilot_gazebo/build &&  sudo cmake .. 
RUN cd ardupilot_gazebo/build && sudo make -j4
RUN cd ardupilot_gazebo/build && sudo make install
RUN echo 'source /usr/share/gazebo/setup.sh' >> ~/.bashrc

#Set paths for models
RUN echo 'export GAZEBO_MODEL_PATH=~/ardupilot_gazebo/models' >> ~/.bashrc
RUN cd 'pwd'
RUN . ~/.bashrc


