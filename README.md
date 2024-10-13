
# to build

```bash
. ./b.sh
```


# to run

```bash
. ./run.sh
```



# For ardupilot:


```bash
cd ardupilot/ArduCopter
```

For SITL ardupilot:

```bash
sudo ../Tools/autotest/sim_vehicle.py -v ArduCopter -f gazebo-iris
```

In Another Terminal Run this command to access the running dronebx-container (Navigate to dronebx):

```bash
. ./r.sh
```

Run MAVProxy in a new Xterm window from the second terminal (inside the running container):

```bash
sudo xterm -e "mavproxy.py --master=tcp:127.0.0.1:5760 --console --map" &
```



once you run the above you should see two xterm pop on your your screen
one is for serial ports data and other is mavproxy console

# on your mac

brew install xpra 

# Possible Errors
1. If you see an error containing CRYPTOGRAPHY_OPENSSL_NO_LEGACY try doing the following
    export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=TRUE
2. Down grading xpra to 4.4.9,23 using brew
    brew edit xpra
    HOMEBREW_NO_INSTALL_FROM_API=1 brew reinstall xpra


# Run Gazebo to launch  drone world

gazebo --verbose ~/ardupilot_gazebo/worlds/iris_arducopter_runway.world

In another Terminal (Terminal 2), run SITL:
cd ~/ardupilot/ArduCopter/
sim_vehicle.py -v ArduCopter -f gazebo-iris --console
