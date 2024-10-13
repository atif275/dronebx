xhost +localhost
docker run -it --rm \
    --env="DISPLAY=host.docker.internal:0" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --name dronebx-container \
    dronebx
