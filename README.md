# CoreOS-CUDA
Docker image to install CUDA 8.0 with CoreOS

To run, do the following: 

```
docker run --device /dev/nvidia0:/dev/nvidia0 --device /dev/nvidia1:/dev/nvidia1 --device /dev/nvidiactl:/dev/nvidiactl --device /dev/nvidia-uvm:/dev/nvidia-uvm -it --privileged jasmor/coreos-cuda /bin/bash
```

You might have to reinstall the package, if so run 

```
./cuda_8.0.61_375.26_linux-run  --verbose --driver --toolkit --samples --override --kernel-source-path=/usr/src/kernels/linux/ --silent in /opt/nvidia/
```
