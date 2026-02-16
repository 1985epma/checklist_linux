# CHECK LINUX Security Tools - Container Image
FROM ubuntu:24.04

LABEL org.opencontainers.image.title="CHECK LINUX Security Tools"
LABEL org.opencontainers.image.description="Comprehensive security audit and system optimization toolkit for Ubuntu Linux"
LABEL org.opencontainers.image.authors="Everton Araujo"
LABEL org.opencontainers.image.source="https://github.com/1985epma/checklist_linux"
LABEL org.opencontainers.image.documentation="https://github.com/1985epma/checklist_linux/blob/main/readme.md"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.version="2.0"

# Avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install dependencies
RUN apt-get update && apt-get install -y \
    apt-utils \
    systemd \
    ufw \
    openssh-server \
    sudo \
    curl \
    wget \
    net-tools \
    iptables \
    ca-certificates \
    rkhunter \
    zenity \
    xterm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create application directory
WORKDIR /opt/checklist-linux

# Copy application files
COPY security_checklist.sh .
COPY service_optimizer.sh .
COPY service_optimizer_gui.sh .
COPY sudo_permissions_checker.sh .
COPY corporate_sudo_configurator.sh .
COPY i18n_demo.sh .
COPY i18n/ ./i18n/

# Make scripts executable
RUN chmod +x *.sh

# Create symbolic links for easier access
RUN ln -s /opt/checklist-linux/security_checklist.sh /usr/local/bin/security-checklist && \
    ln -s /opt/checklist-linux/service_optimizer.sh /usr/local/bin/service-optimizer && \
    ln -s /opt/checklist-linux/service_optimizer_gui.sh /usr/local/bin/service-optimizer-gui && \
    ln -s /opt/checklist-linux/sudo_permissions_checker.sh /usr/local/bin/sudo-checker && \
    ln -s /opt/checklist-linux/corporate_sudo_configurator.sh /usr/local/bin/sudo-configurator && \
    ln -s /opt/checklist-linux/i18n_demo.sh /usr/local/bin/i18n-demo

# Copy documentation
COPY readme.md README.*.md I18N_README.md BRANCH_PROTECTION.md /usr/share/doc/checklist-linux/

# Create volume for output files
VOLUME ["/output"]

# Set working directory for output
WORKDIR /output

# Default command shows help menu
CMD ["/opt/checklist-linux/security_checklist.sh", "--help"]
