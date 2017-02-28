FROM ubuntu:16.04
MAINTAINER Jason Morris <jasonmorris2@acm.org>

# Install required packages
RUN apt-get update -y
RUN apt-get install -y gcc-4.9 g++-4.9 wget git make dpkg-dev bc python-pip python-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev libjpeg8-dev zlib1g-dev module-init-tools
RUN apt-get purge nvidia-* -y

# Switch to gcc 4.9
RUN update-alternatives --remove gcc /usr/bin/gcc-5.4
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9
RUN update-alternatives --config gcc

RUN mkdir -p /usr/src/kernels
RUN mkdir -p /opt/nvidia/

# Build modules
WORKDIR /usr/src/kernels
RUN git clone https://github.com/coreos/linux.git
WORKDIR /usr/src/kernels/linux
#RUN git checkout -b remotes/origin/v`uname -r | sed -e "s/-.*//" | sed -e "s/\.[0]*$//"`-coreos 
RUN git checkout remotes/origin/v4.7.3-coreos
RUN zcat /proc/config.gz > .config 
RUN make modules_prepare
RUN sed -i -e 's/4.10.0+/4.7.3-coreos-r3/' include/generated/utsrelease.h
RUN sed -i -e 's/4.7.3+/4.7.3-coreos-r3/' include/generated/utsrelease.h

# Nvidia drivers setup
WORKDIR /opt/nvidia/
ADD https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda_8.0.61_375.26_linux-run /opt/nvidia/
RUN chmod +x /opt/nvidia/cuda_8.0.61_375.26_linux-run 
CMD ./cuda_8.0.61_375.26_linux-run  --verbose --driver --toolkit --samples --override --kernel-source-path=/usr/src/kernels/linux/ --silent
#RUN chmod +x cuda_8.0.61_375.26_linux-run && ./cuda_8.0.61_375.26_linux-run -extract=`pwd`/nvidia_installers

#WORKDIR /opt/nvidia/nvidia_installers

# Install packages
#RUN ./NVIDIA-Linux-x86_64-375.26.run -a -s -Z -f --kernel-source-path=/usr/src/kernels/linux/
#RUN ./cuda-linux64-rel-8.0.61-21551265.run --noprompt
#RUN ./cuda-samples-linux-8.0.61-21551265.run --cudaprefix=/usr/local/cuda-8.0/ --noprompt

# Query the GPU to test
#WORKDIR /root/NVIDIA_CUDA-8.0_Samples/1_Utilities/deviceQuery
#RUN make -j`grep -c processor /proc/cpuinfo`
#RUN ./deviceQuery
