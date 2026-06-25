FROM ubuntu:22.04
# ========== 1. 安装系统基础依赖 (此时 apt 已走国内源) ==========
RUN apt update && apt-get install -y \
    lsb-release wget telnet curl vim cmake gnupg2 \
    git iputils-ping ca-certificates sudo && \
    apt-get clean all

# wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
COPY cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
#wget https://developer.download.nvidia.com/compute/cuda/12.1.1/local_installers/cuda-repo-wsl-ubuntu-12-1-local_12.1.1-1_amd64.deb
COPY cuda-repo-wsl-ubuntu-12-1-local_12.1.1-1_amd64.deb .
RUN dpkg -i cuda-repo-wsl-ubuntu-12-1-local_12.1.1-1_amd64.deb
RUN cp /var/cuda-repo-wsl-ubuntu-12-1-local/cuda-*-keyring.gpg /usr/share/keyrings/

RUN apt-get update
RUN apt-get -y install cuda && rm cuda-repo-wsl-ubuntu-12-1-local_12.1.1-1_amd64.deb


# ========== 3. 安装 cuDNN 8.9 (【最终修复】指定正确 keyring) ==========
COPY cudnn-local-repo-ubuntu2204-8.9.7.29_1.0-1_amd64.deb .
RUN dpkg -i cudnn-local-repo-ubuntu2204-8.9.7.29_1.0-1_amd64.deb && \
    cp /var/cudnn-local-repo-ubuntu2204-8.9.7.29/cudnn-local-08A7D361-keyring.gpg /usr/share/keyrings/ && \
    apt-get update && \
    rm cudnn-local-repo-ubuntu2204-8.9.7.29_1.0-1_amd64.deb

# ========== 4. 安装 Miniconda (系统级路径 /opt/conda) ==========
COPY Miniconda3-latest-Linux-x86_64.sh .
RUN bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && rm Miniconda3-latest-Linux-x86_64.sh
ENV PATH=/opt/conda/bin:${PATH}

# ========== 5. 【极速】配置 Conda 使用清华镜像源，并安装 Python 和依赖 ==========
# 先接受协议（如果不接受，国内镜像也可能被阻拦）
RUN conda tos accept --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --channel https://repo.anaconda.com/pkgs/r && \
    conda install python=3.12

RUN pip install -i https://mirrors.aliyun.com/pypi/simple/ pandas 
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# ========== 7. 设置系统环境变量 (时区/编码) ==========
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV MPLBACKEND="TkAgg"

# ========== 8. 创建非 root 用户 acelin (Ubuntu 正确写法) ==========
RUN useradd -m -s /bin/bash acelin && \
    usermod -aG sudo acelin && \
    echo "acelin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ========== 10. 切换默认用户为 acelin ==========
USER acelin
WORKDIR /home/acelin

# 配置 nvm 相关环境变量（针对 acelin 用户）
ENV NVM_DIR=/home/acelin/.nvm
ENV NODE_VERSION=20.12.2
ENV NVM_VERSION=v0.40.1


# 一气呵成：下载 nvm -> 激活环境 -> 安装 Node -> 全局安装 codex
# 此时所有文件（包括 npm 全局包）都会自动存储在 /home/acelin 目录下，权限完全属于 acelin
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install ${NODE_VERSION} \
    && nvm alias default ${NODE_VERSION} \
    && nvm use default \
    && npm install -g @openai/codex

# ========== 9. 为 acelin 用户注入环境变量、conda 和别名 ==========
# 1. 注入原有的 conda/cuda 路径
# 2. 【新增】将 nvm 的 bin 目录永久注入 PATH（确保免 source 直接能用 node/npm/codex）
ENV PATH=$NVM_DIR/versions/node/v${NODE_VERSION}/bin:/opt/conda/bin:/usr/local/cuda/bin:${PATH}
RUN echo 'export PATH=/opt/conda/bin:/usr/local/cuda/bin:${PATH}' >> /home/acelin/.bashrc && \
    echo 'source /opt/conda/etc/profile.d/conda.sh' >> /home/acelin/.bashrc && \
    echo 'alias ll="ls -l"' >> /home/acelin/.bashrc 

CMD ["/bin/bash"]