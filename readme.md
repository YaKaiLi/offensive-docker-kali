
# Offensive Docker Kali
[![Docker Pulls](https://img.shields.io/docker/pulls/dulala/offensive-docker-kali.svg)](https://hub.docker.com/r/dulala/offensive-docker-kali)
[![Docker Stars](https://img.shields.io/docker/stars/dulala/offensive-docker-kali.svg)](https://hub.docker.com/r/dulala/offensive-docker-kali)

A comprehensive security-focused development environment based on Kali Linux, equipped with essential penetration testing tools and development frameworks.

基于 Kali Linux 的综合安全开发环境，配备必要的渗透测试工具和开发框架。

## Quick Start | 快速开始

```bash
# Pull the image
docker pull dulala/offensive-docker-kali:latest

# Run the container
docker run -it dulala/offensive-docker-kali
```

## Features | 功能特点

### Security Tools | 安全工具
- **Network Tools**: nmap, masscan, netcat-traditional
- **Web Tools**: gobuster, dirb, dirbuster, wfuzz, nikto, whatweb, wafw00f
- **Exploitation**: metasploit-framework, burpsuite, zaproxy
- **Password Tools**: hydra, john, hashcat
- **Wireless**: aircrack-ng, reaver, pixiewps
- **Forensics**: binwalk, foremost, testdisk
- **Others**: sqlmap, crackmapexec, exploitdb

### Development Environment | 开发环境
- **Python**: Miniconda (Python 3.10)
  - NumPy, Pandas, Requests
  - BeautifulSoup4, Jupyter
  - Scrapy, Scikit-learn
  - Matplotlib, Seaborn
- **Go**: v1.22.1
- **Node.js**: 20.x
- **Tools**: git, vim, curl, wget

### Shell Environment | Shell 环境
- ZSH with Oh My Zsh
- Custom plugins and themes
- Agnoster theme
- Autosuggestions and syntax highlighting

## Usage Examples | 使用示例

### Basic Usage | 基本使用
```bash
# Start container with host network
docker run -it --network host dulala/offensive-docker-kali

# Mount a local directory
docker run -it -v $(pwd):/root/workspace dulala/offensive-docker-kali

# Start with specific tools
docker run -it dulala/offensive-docker-kali msfconsole
```

### Pre-configured Aliases | 预置别名
```bash
# Start Metasploit
msf

# Initialize MSF database
msfdb-start
```

## Installed Tools | 已安装工具

### Network & Web | 网络和Web工具
- nmap
- masscan
- netcat-traditional
- gobuster
- dirb/dirbuster
- wfuzz
- nikto
- whatweb
- wafw00f

### Exploitation & Password | 漏洞利用和密码工具
- metasploit-framework
- burpsuite
- zaproxy
- hydra
- john
- hashcat

### Forensics & Others | 取证和其他工具
- binwalk
- foremost
- testdisk
- sqlmap
- crackmapexec
- exploitdb

## Environment Variables | 环境变量
```bash
DEBIAN_FRONTEND=noninteractive
TZ=Asia/Shanghai
CONDA_DIR=/opt/miniconda
GOROOT=/usr/local/go
GOPATH=/root/go
LC_ALL=C.UTF-8
LANG=C.UTF-8
```

## Notes | 注意事项
- Container starts with `ap` conda environment activated
- PostgreSQL service starts automatically
- All tools are pre-configured and ready to use
- Some tools may require additional configuration

## Contributing | 贡献
Feel free to submit issues and enhancement requests!

欢迎提交问题和改进建议！

## Maintainer | 维护者
- **Author**: star5o
- **Email**: jkliyakai@163.com
- **Version**: 0.7

## License | 许可
MIT License

## Links | 相关链接
- [Docker Hub](https://hub.docker.com/r/dulala/offensive-docker-kali)
- [GitHub](https://github.com/yourusername/offensive-docker-kali)
