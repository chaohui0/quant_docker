FROM ubuntu:20.04

# 安装miniconda
#wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
COPY Miniconda3-latest-Linux-x86_64.sh .
RUN /bin/bash Miniconda3-latest-Linux-x86_64.sh -b && rm Miniconda3-latest-Linux-x86_64.sh
ENV PATH=/root/miniconda3/bin:${PATH}

# RUN conda install -c http://mirrors.aliyun.com/anaconda/cloud/conda-forge --override-channels "gxx>=10.0" h5py "hdf5>=1.12" matplotlib numpy  "python=3.9" zlib
RUN apt update
RUN apt-get install -y lsb-release wget telnet curl vim cmake gnupg2 && apt-get clean all


# wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
COPY cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
#wget https://developer.download.nvidia.com/compute/cuda/12.1.1/local_installers/cuda-repo-wsl-ubuntu-12-1-local_12.1.1-1_amd64.deb
COPY cuda-repo-wsl-ubuntu-12-1-local_12.1.1-1_amd64.deb .
RUN dpkg -i cuda-repo-wsl-ubuntu-12-1-local_12.1.1-1_amd64.deb
RUN cp /var/cuda-repo-wsl-ubuntu-12-1-local/cuda-*-keyring.gpg /usr/share/keyrings/
RUN apt-get update
RUN apt-get -y install cuda

# #wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
# COPY cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
# #wget http://developer.download.nvidia.com/compute/cuda/11.0.2/local_installers/cuda-repo-ubuntu2004-11-0-local_11.0.2-450.51.05-1_amd64.deb
# COPY cuda-repo-ubuntu2004-11-0-local_11.0.2-450.51.05-1_amd64.deb .
# RUN dpkg -i cuda-repo-ubuntu2004-11-0-local_11.0.2-450.51.05-1_amd64.deb
# RUN apt-key add /var/cuda-repo-ubuntu2004-11-0-local/7fa2af80.pub
# RUN apt-get update
# ENV DEBIAN_FRONTEND=noninteractive
# RUN apt-get -y install cuda && rm cuda-repo-ubuntu2004-11-0-local_11.0.2-450.51.05-1_amd64.deb

# COPY cudnn-local-repo-ubuntu2004-8.9.2.26_1.0-1_amd64.deb .
# RUN dpkg -i cudnn-local-repo-ubuntu2004-8.9.2.26_1.0-1_amd64.deb && rm cudnn-local-repo-ubuntu2004-8.9.2.26_1.0-1_amd64.deb

# COPY requirement.txt .
# RUN pip install -i https://mirrors.aliyun.com/pypi/simple/ --no-cache-dir -r requirement.txt

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV MPLBACKEND="TkAgg"

