FROM kalilinux/kali-rolling

LABEL maintainer="star5o" \
    email="jkliyakai@163.com" \
    description="Security focused development environment based on Kali Linux" \
    version="0.6"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    CONDA_DIR=/opt/miniconda \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    GOROOT="/usr/local/go" \
    GOPATH="/root/go" \
    PATH="/opt/miniconda/bin:/root/go/bin:/usr/local/go/bin:${PATH}"

# Combine multiple RUN commands and clean up in the same layer
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    zsh git lrzsz curl wget vim plocate \
    metasploit-framework sqlmap postgresql \
    kali-linux-headless kali-tools-top10 figlet && \
    # Initialize MSF database
    service postgresql start && msfdb init && \
    # Install Oh My Zsh and plugins
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search /root/.oh-my-zsh/custom/plugins/zsh-history-substring-search

# Install Miniconda and set up Python environment
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py310_24.9.2-0-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -p /opt/miniconda -b && \
    rm /tmp/miniconda.sh && \
    . /opt/miniconda/etc/profile.d/conda.sh && \
    conda update -y conda && \
    conda init bash && \
    conda init zsh && \
    conda create -n ap python=3.10 -y && \
    conda install -y -n ap numpy pandas requests beautifulsoup4 lxml jupyter scrapy scikit-learn matplotlib seaborn && \
    conda clean -afy

# Install Go and Node.js
RUN wget -q https://dl.google.com/go/go1.22.1.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz && \
    # Install Node.js
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure Zsh
RUN sed -i 's/plugins=(git)/plugins=(git aws golang nmap node pip python ubuntu zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)/g' /root/.zshrc && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' /root/.zshrc && \
    echo 'autoload -U compinit && compinit' >> /root/.zshrc && \
    echo '. /opt/miniconda/etc/profile.d/conda.sh' >> /root/.zshrc && \
    echo 'conda activate ap' >> /root/.zshrc && \
    echo '[ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ] || echo "Warning: zsh-syntax-highlighting plugin directory not found"' >> /root/.zshrc

# Set up Go environment and tools
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/pkg" && \
    go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest && \
    nuclei -update-templates

# Configure timezone
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata


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

# Create and configure entrypoint
RUN echo '#!/bin/zsh\n\
    if [ -f /var/run/postgresql/*.pid ]; then\n\
    rm /var/run/postgresql/*.pid\n\
    fi\n\
    service postgresql start\n\
    conda activate ap\n\
    exec /usr/bin/zsh' > /entrypoint.sh && \
    chmod +x /entrypoint.sh


SHELL ["/usr/bin/zsh", "-c"]
ENTRYPOINT ["/entrypoint.sh"]
