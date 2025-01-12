FROM kalilinux/kali-rolling

LABEL maintainer="star5o" \
    email="jkliyakai@163.com" \
    description="Security focused development environment based on Kali Linux" \
    version="0.8"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    CONDA_DIR=/opt/miniconda \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    GOROOT="/usr/local/go" \
    GOPATH="/root/go" \
    PATH="/opt/miniconda/bin:/root/go/bin:/usr/local/go/bin:${PATH}"

# First install minimal essential packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    wget curl ca-certificates \
    git zsh lrzsz vim plocate htop && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda and set up Python environment
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py310_24.9.2-0-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -p /opt/miniconda -b && \
    rm /tmp/miniconda.sh && \
    . /opt/miniconda/etc/profile.d/conda.sh && \
    conda update -y conda && \
    conda init bash && conda init zsh && \
    conda create -n ap python=3.10 -y && \
    conda install -y -n ap numpy pandas requests beautifulsoup4 lxml jupyter scrapy scikit-learn matplotlib seaborn && \
    conda clean -afy

# Install development libraries and build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Basic build tools
    build-essential \
    # Python development
    python3-dev \
    # PostgreSQL development
    libpq-dev \
    # OpenVAS/GVM dependencies
    cmake pkg-config \
    libglib2.0-dev \
    libgpgme11-dev \
    libgnutls28-dev \
    uuid-dev \
    libssh-dev \
    libhiredis-dev \
    libxml2-dev \
    libpcap-dev \
    libnet1-dev \
    libmicrohttpd-dev \
    redis-server \
    xsltproc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install tools that might depend on Python and dev libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql figlet gcc \
    # Network tools 
    nmap masscan netcat-traditional iputils-ping \
    smbclient smbmap enum4linux \
    # Web tools
    gobuster dirb dirbuster wfuzz \
    nikto whatweb wafw00f \
    # Password tools
    hydra john hashcat \
    # Additional tools
    steghide hexedit xxd \
    cewl crunch rsmangler && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Kali tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    metasploit-framework sqlmap \
    kali-linux-headless kali-tools-top10 \
    crackmapexec wpscan burpsuite zaproxy \
    exploitdb shellnoob \
    aircrack-ng reaver pixiewps \
    binwalk foremost testdisk \
    openvas \
    && service postgresql start && msfdb init && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install zsh plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search /root/.oh-my-zsh/custom/plugins/zsh-history-substring-search

# Install security wordlists
RUN mkdir -p /usr/share/wordlists && \
    cd /usr/share/wordlists && \
    git clone --depth 1 https://github.com/danielmiessler/SecLists.git && \
    wget https://raw.githubusercontent.com/praetorian-inc/Hob0Rules/master/wordlists/rockyou.txt.gz && \
    gunzip rockyou.txt.gz && \
    wget https://raw.githubusercontent.com/maurosoria/dirsearch/master/db/dicc.txt

# Install Go and Node.js
RUN wget -q https://dl.google.com/go/go1.22.1.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set up Go environment
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/pkg"

# Install additional security tools
RUN . /opt/miniconda/etc/profile.d/conda.sh && \
    conda activate ap && \
    go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest && \
    wget https://github.com/shadow1ng/fscan/releases/download/1.8.4/fscan -O /usr/local/bin/fscan && \
    chmod +x /usr/local/bin/fscan

# Initialize OpenVAS
RUN systemctl enable redis-server && \
    greenbone-nvt-sync && \
    greenbone-feed-sync --type GVMD_DATA && \
    greenbone-feed-sync --type SCAP && \
    greenbone-feed-sync --type CERT && \
    gvm-setup

# Configure timezone and locale
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Configure zsh
RUN sed -i 's/plugins=(git)/plugins=(git aws golang nmap node pip python ubuntu zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)/g' /root/.zshrc && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' /root/.zshrc && \
    echo 'autoload -U compinit && compinit' >> /root/.zshrc && \
    echo '. /opt/miniconda/etc/profile.d/conda.sh' >> /root/.zshrc && \
    echo 'conda activate ap' >> /root/.zshrc

# Copy and apply custom shell configurations
COPY shell/ /tmp/
RUN cat /tmp/banner >> /root/.zshrc && \
    cat /tmp/alias >> /root/.zshrc && \
    cat /tmp/customFunctions >> /root/.zshrc && \
    updatedb

# Add penetration testing aliases
RUN echo 'alias msfconsole="service postgresql start && msfconsole"' >> /root/.zshrc && \
    echo 'alias msf="service postgresql start && msfconsole"' >> /root/.zshrc && \
    echo 'msfdb-start() { service postgresql start && msfdb init; }' >> /root/.zshrc && \
    echo 'alias nmap="nmap --privileged"' >> /root/.zshrc

WORKDIR /root/ap

# Create entrypoint
RUN echo '#!/bin/zsh\n\
    if [ -f /var/run/postgresql/*.pid ]; then\n\
    rm /var/run/postgresql/*.pid\n\
    fi\n\
    service postgresql start\n\
    service redis-server start\n\
    conda activate ap\n\
    exec /usr/bin/zsh' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

SHELL ["/usr/bin/zsh", "-c"]
ENTRYPOINT ["/entrypoint.sh"]