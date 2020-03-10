FROM sd2e/python3:ubuntu18

MAINTAINER mdehaven@sift.net

ENV LANG=en_US.UTF-8
ENV PYTHONIOENCODING=UTF-8

RUN apt-get update && \
    apt-get install -y \
    cmake \
    cpio \
    gfortran \
    git \
    man \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    wget && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install cython pybind11 && \
    python3 -m pip install --upgrade setuptools

RUN cd /tmp && \
    wget http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/15816/l_mkl_2019.5.281.tgz && \
    tar -xzf l_mkl_2019.5.281.tgz && \
    cd l_mkl_2019.5.281 && \
    sed -i 's/ACCEPT_EULA=decline/ACCEPT_EULA=accept/g' silent.cfg && \
    ./install.sh -s silent.cfg && \
    cd .. && \
    rm -rf *


RUN echo "/opt/intel/mkl/lib/intel64" >> /etc/ld.so.conf.d/intel.conf && \
    ldconfig && \
    echo ". /opt/intel/bin/compilervars.sh intel64" >> /etc/bash.bashrc

RUN cd /tmp && \
    git clone https://github.com/numpy/numpy.git numpy && \
    cd numpy && \
    cp site.cfg.example site.cfg && \
    echo "\n[mkl]" >> site.cfg && \
    echo "include_dirs = /opt/intel/mkl/include/intel64/" >> site.cfg && \
    echo "library_dirs = /opt/intel/mkl/lib/intel64/" >> site.cfg && \
    echo "mkl_libs = mkl_rt" >> site.cfg && \
    echo "lapack_libs =" >> site.cfg && \
    python3 setup.py build --fcompiler=gnu95 && \
    python3 setup.py install && \
    cd .. && \
    rm -rf *

RUN cd /tmp && \
    git clone https://github.com/scipy/scipy.git scipy && \
    cd scipy && \
    python3 setup.py build && \
    python3 setup.py install && \
    cd .. && \
    rm -rf *
