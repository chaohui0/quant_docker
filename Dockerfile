FROM ubuntu:20.04

# 安装miniconda
#wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
COPY Miniconda3-latest-Linux-x86_64.sh .
RUN /bin/bash Miniconda3-latest-Linux-x86_64.sh -b && rm Miniconda3-latest-Linux-x86_64.sh
ENV PATH=/root/miniconda3/bin:${PATH}

RUN apt update
RUN apt-get install -y lsb-release wget telnet curl vim cmake gnupg2 && apt-get clean all


# wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
COPY cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
#wget https://developer.download.nvidia.com/compute/cuda/12.1.1/local_installers/cuda-repo-wsl-ubuntu-12-1-local_12.1.1-1_amd64.deb
COPY cuda-repo-wsl-ubuntu-12-1-local_12.1.1-1_amd64.deb .
RUN dpkg -i cuda-repo-wsl-ubuntu-12-1-local_12.1.1-1_amd64.deb
RUN cp /var/cuda-repo-wsl-ubuntu-12-1-local/cuda-*-keyring.gpg /usr/share/keyrings/
RUN apt-get update
RUN apt-get -y install cuda && rm cuda-repo-wsl-ubuntu-12-1-local_12.1.1-1_amd64.deb

COPY cudnn-local-repo-ubuntu2004-8.9.2.26_1.0-1_amd64.deb .
RUN cp /var/cudnn-local-repo-ubuntu2004-8.9.2.26/cudnn-local-6D0A7AE1-keyring.gpg /usr/share/keyrings/
RUN dpkg -i cudnn-local-repo-ubuntu2004-8.9.2.26_1.0-1_amd64.deb && rm cudnn-local-repo-ubuntu2004-8.9.2.26_1.0-1_amd64.deb

RUN conda install -c http://mirrors.aliyun.com/anaconda/cloud/conda-forge --override-channel python=3.8
RUN conda install -c fastai -c pytorch -c anaconda fastai gh anaconda

COPY requirement.txt .
RUN pip install -i https://mirrors.aliyun.com/pypi/simple/ --no-cache-dir -r requirement.txt

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV MPLBACKEND="TkAgg"

