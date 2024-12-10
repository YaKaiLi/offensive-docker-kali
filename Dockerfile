FROM kalilinux/kali-rolling

LABEL maintainer="star5o" \
    email="jkliyakai@163.com" \
    description="Security focused development environment based on Kali Linux" \
    version="1.0"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    CONDA_DIR=/opt/miniconda \
    PATH=/opt/miniconda/bin:${PATH} \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# 安装基础包和必要的安全工具
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    zsh \
    git \
    lrzsz \
    curl \
    wget \
    vim \
    plocate \
    metasploit-framework \
    sqlmap \
    postgresql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 初始化 MSF 数据库
RUN service postgresql start && \
    msfdb init && \
    echo "alias msf='service postgresql start && msfconsole'" >> /root/.zshrc

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search /root/.oh-my-zsh/custom/plugins/zsh-history-substring-search

RUN sed -i 's/plugins=(git)/plugins=(git kali aws golang nmap node pip python ubuntu zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)/g' /root/.zshrc \
    && echo 'autoload -U compinit && compinit' >> /root/.zshrc

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py310_24.9.2-0-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -p /opt/miniconda -b \
    && rm /tmp/miniconda.sh

RUN conda update -y conda \
    && conda init bash \
    && conda init zsh \
    && echo ". /opt/miniconda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && echo ". /opt/miniconda/etc/profile.d/conda.sh" >> ~/.zshrc \
    && . /opt/miniconda/etc/profile.d/conda.sh \
    && conda create -n security python=3.9 -y \
    && conda activate security \
    && conda install -y \
    numpy \
    pandas \
    requests \
    beautifulsoup4 \
    lxml \
    jupyter \
    scrapy \
    scikit-learn \
    matplotlib \
    seaborn \
    && conda clean -afy

RUN apt-get update && apt-get install -y --no-install-recommends \
    kali-linux-headless \
    kali-tools-top10 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN wget -q https://dl.google.com/go/go1.22.1.linux-amd64.tar.gz -O go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

ENV GOROOT="/usr/local/go" \
    GOPATH="/root/go" \
    PATH="$PATH:/root/go/bin:/usr/local/go/bin"

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/pkg"

RUN go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest && \
    nuclei -update-templates

RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' /root/.zshrc

RUN apt-get install -y --no-install-recommends figlet \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN . /opt/miniconda/etc/profile.d/conda.sh \
    && conda create -n ap python=3.10 -y \
    && conda activate ap \
    && conda clean -afy

# 复制自定义shell配置文件
COPY shell/ /tmp/

# 应用自定义配置
RUN cat /tmp/banner >> /root/.zshrc && \
    cat /tmp/alias >> /root/.zshrc && \
    cat /tmp/customFunctions >> /root/.zshrc && \
    updatedb

# 添加常用的渗透测试别名和函数
RUN echo 'alias msfconsole="service postgresql start && msfconsole"' >> /root/.zshrc && \
    echo 'alias msf="service postgresql start && msfconsole"' >> /root/.zshrc && \
    echo 'msfdb-start() { service postgresql start && msfdb init; }' >> /root/.zshrc

WORKDIR /root/ap

SHELL ["/usr/bin/zsh", "-c"]

# 创建启动脚本
RUN echo '#!/bin/zsh\n\
    service postgresql start\n\
    conda activate ap\n\
    exec /usr/bin/zsh' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

RUN echo 'conda activate ap' >> /root/.zshrc

ENTRYPOINT ["/entrypoint.sh"]