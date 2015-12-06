FROM osrf/ros:indigo-desktop-full

ENV PYTHONPATH /opt/caffe/python

# Add caffe binaries to path
ENV PATH $PATH:/opt/caffe/.build_release/tools

# Get dependencies
RUN apt-get update && apt-get install -q -y \
  libprotobuf-dev \
  libleveldb-dev \
  libsnappy-dev \
  libopencv-dev \
  libhdf5-serial-dev \
  protobuf-compiler \
  libboost-all-dev \
  libgflags-dev \
  libgoogle-glog-dev \
  liblmdb-dev \
  libatlas-base-dev \
  python-dev \
  wget \
  && rm -rf /var/lib/apt/lists/*

# Clone the Caffe repo
RUN cd /opt && git clone https://github.com/BVLC/caffe.git

# Build Caffe core
RUN cd /opt/caffe && \
  cp Makefile.config.example Makefile.config && \
  sed -i '/^#.* CPU_ONLY /s/^#//' Makefile.config && \
  make all -j$(nproc) && \
  make test -j$(nproc)

# Get ld-so.conf so it can find libcaffe.so
RUN wget https://raw.githubusercontent.com/ruffsl/ros_caffe/master/docker/caffe/caffe-ld-so.conf
RUN mv caffe-ld-so.conf /etc/ld.so.conf.d/

# Run ldconfig again (not sure if needed)
RUN ldconfig

