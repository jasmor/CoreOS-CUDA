FROM ubuntu:16.04
MAINTAINER Jason Morris <jasonmorris2@acm.org>

# Install required packages
RUN apt-get update -y
RUN apt-get install -y gcc-4.9 g++-4.9 wget git make dpkg-dev bc python-pip python-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev libjpeg8-dev zlib1g-dev module-init-tools

# Switch to gcc 4.9
RUN update-alternatives --remove gcc /usr/bin/gcc-5.4
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9
RUN update-alternatives --config gcc

RUN mkdir -p /usr/src/kernels
RUN mkdir -p /opt/nvidia/

# Build modules
WORKDIR /usr/src/kernels
RUN git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git linux
WORKDIR linux
RUN git checkout -b remotes/origin/v`uname -r | sed -e "s/-.*//" | sed -e "s/\.[0]*$//"`-coreos 
RUN zcat /proc/config.gz > .config 
RUN yes ""| make oldconfig && make modules_prepare
RUN sed -i -e "s/`uname -r | sed -e "s/-.*//" | sed -e "s/\.[0]??*$//"`/`uname -r`/" include/generated/utsrelease.h

# Nvidia drivers setup
WORKDIR /opt/nvidia/
ADD https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda_8.0.61_375.26_linux-run /opt/nvidia/
RUN chmod +x cuda_8.0.61_375.26_linux-run && ./cuda_8.0.61_375.26_linux-run -extract=`pwd`/nvidia_installers
WORKDIR /opt/nvidia/nvidia_installers

# Install packages
RUN ./NVIDIA-Linux-x86_64-375.26.run -a -x --ui=none --kernel-source-path=/usr/src/kernels/linux/
RUN ./cuda-linux64-rel-8.0.61-21551265.run --noprompt
RUN ./cuda-samples-linux-8.0.61-21551265.run --cudaprefix=/usr/local/cuda-8.0/ --noprompt

# Query the GPU to test
WORKDIR /usr/local/cuda-8.0/samples/1_Utilities/deviceQuery
RUN make -j`grep -c processor /proc/cpuinfo`
#RUN ./deviceQuery
