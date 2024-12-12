
# Kali Linux Security Development Environment
# Kali Linux 安全开发环境

A comprehensive security-focused development environment based on Kali Linux, equipped with essential penetration testing tools and development frameworks.

基于 Kali Linux 的综合安全开发环境，配备必要的渗透测试工具和开发框架。

## Features | 功能特点

### Base System | 基础系统
- Based on `kali-rolling` with latest security updates
- Pre-configured timezone (Asia/Shanghai)
- ZSH shell with Oh My Zsh and custom plugins
- Customized terminal experience with Agnoster theme

- 基于 `kali-rolling` 并包含最新安全更新
- 预配置时区（亚洲/上海）
- 配备 Oh My Zsh 和自定义插件的 ZSH shell
- 使用 Agnoster 主题的定制终端体验

### Security Tools | 安全工具
- Metasploit Framework (with PostgreSQL integration)
- SQLMap
- Nuclei (with latest templates)
- Kali Linux Headless
- Top 10 Kali Tools

- Metasploit 框架（集成 PostgreSQL）
- SQLMap
- Nuclei（附带最新模板）
- Kali Linux Headless
- Kali Top 10 工具集

### Development Environment | 开发环境
- Miniconda with Python 3.10
- Go 1.22.1
- Node.js 20.x
- Git and essential development tools

- Miniconda（Python 3.10）
- Go 1.22.1
- Node.js 20.x
- Git 和基础开发工具

### Python Packages (ap environment) | Python 包（ap 环境）
- NumPy
- Pandas
- Requests
- BeautifulSoup4
- Jupyter
- Scrapy
- Scikit-learn
- Matplotlib
- Seaborn

### ZSH Plugins | ZSH 插件
- zsh-autosuggestions
- zsh-syntax-highlighting
- zsh-history-substring-search
- Various Oh My Zsh plugins (git, aws, golang, nmap, node, pip, python, ubuntu)

- zsh-autosuggestions（自动提示）
- zsh-syntax-highlighting（语法高亮）
- zsh-history-substring-search（历史搜索）
- 多个 Oh My Zsh 插件（git、aws、golang、nmap、node、pip、python、ubuntu）

## Usage | 使用方法

### Building the Image | 构建镜像
```bash
docker build -t security-dev-env .
```

### Running the Container | 运行容器
```bash
docker run -it security-dev-env
```

### Pre-configured Aliases | 预配置别名
- `msf` or `msfconsole`: Start Metasploit Framework with PostgreSQL
- `msfdb-start`: Initialize MSF database

- `msf` 或 `msfconsole`：启动 Metasploit Framework（含 PostgreSQL）
- `msfdb-start`：初始化 MSF 数据库

## Environment Variables | 环境变量
- `DEBIAN_FRONTEND=noninteractive`
- `TZ=Asia/Shanghai`
- `CONDA_DIR=/opt/miniconda`
- `GOROOT=/usr/local/go`
- `GOPATH=/root/go`
- `LC_ALL=C.UTF-8`
- `LANG=C.UTF-8`

## Additional Features | 附加功能
- Automatic PostgreSQL service start
- Custom shell configurations and functions
- Pre-configured banner and aliases
- Automatic conda environment activation
- Custom shell functions and aliases

- PostgreSQL 服务自动启动
- 自定义 shell 配置和函数
- 预配置的欢迎横幅和别名
- Conda 环境自动激活
- 自定义 shell 函数和别名

## Maintainer | 维护者
- Maintainer | 维护者: star5o
- Email | 邮箱: jkliyakai@163.com
- Version | 版本: 0.6

## Notes | 注意事项
- The container starts with the `ap` conda environment activated by default
- PostgreSQL service starts automatically on container launch
- All tools and environments are pre-configured and ready to use

- 容器默认启动时激活 `ap` conda 环境
- 容器启动时自动启动 PostgreSQL 服务
- 所有工具和环境均已预配置完成，可直接使用
