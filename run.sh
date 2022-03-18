# Start X server if necessary
if [ -z $(ls /tmp/.X11-unix/X10) ]
then
	echo "No X server found on display :10, starting one"
	nvidia-xconfig -a --allow-empty-initial-configuration --use-display-device=None -o ./docker-xorg.conf
	export
	nohup Xorg $DISPLAY -config ./docker-xorg.conf &
    rm docker-xorg.conf
fi

DISPLAY=:10 xhost +SI:localuser:root # Allow local user to connect to X server
docker run -it -P --rm \
	--runtime=nvidia \
	--gpus all \
	--ipc host \
	--device /dev/snd:/dev/snd:rw \
	--group-add audio \
	-e NVIDIA_VISIBLE_DEVICES=all \
	-e NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute,video \
    -e VGL_DISPLAY=:10.0 \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	--name devrun \
	-p 25901:5901 -p 26901:6901 \
	docker.io/accetto/dev-headless-drawing-g3:latest --tail-vnc --verbose
DISPLAY=:10 xhost -SI:localuser:root # Allow local user to connect to X server

