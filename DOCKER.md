# Docker Container Guide

This guide explains how to use CHECK LINUX Security Tools as a Docker container from GitHub Container Registry.

## 📦 Quick Start

### Pull from GitHub Container Registry

```bash
docker pull ghcr.io/1985epma/checklist-linux:latest
```

### Run Security Checklist

```bash
# Basic security check
docker run --rm --privileged \
  -v $(pwd)/output:/output \
  -v /etc:/host/etc:ro \
  -v /var:/host/var:ro \
  ghcr.io/1985epma/checklist-linux:latest \
  security-checklist

# Generate HTML report
docker run --rm --privileged \
  -v $(pwd)/output:/output \
  -v /etc:/host/etc:ro \
  -v /var:/host/var:ro \
  ghcr.io/1985epma/checklist-linux:latest \
  security-checklist -f html -o /output/security_report.html
```

### Interactive Shell

```bash
docker run -it --rm --privileged \
  -v $(pwd)/output:/output \
  -v /etc:/host/etc:ro \
  -v /var:/host/var:ro \
  ghcr.io/1985epma/checklist-linux:latest \
  /bin/bash
```

## 🚀 Using Docker Compose

### Basic Usage

```bash
# Start interactive container
docker-compose up -d interactive

# Access the shell
docker-compose exec interactive bash

# Run security check
docker-compose run security-check

# Stop and remove containers
docker-compose down
```

### Custom Configuration

Create a `docker-compose.override.yml` file:

```yaml
version: '3.8'

services:
  checklist-linux:
    environment:
      - LANG=pt_BR.UTF-8
    volumes:
      - /custom/path:/output
```

## 🔧 Available Commands

All tools are available in the container:

```bash
# Security Checklist
docker run --rm ghcr.io/1985epma/checklist-linux:latest security-checklist --help

# Service Optimizer
docker run --rm --privileged ghcr.io/1985epma/checklist-linux:latest service-optimizer --help

# Sudo Permissions Checker
docker run --rm --privileged ghcr.io/1985epma/checklist-linux:latest sudo-checker

# Corporate Sudo Configurator
docker run --rm --privileged ghcr.io/1985epma/checklist-linux:latest sudo-configurator

# i18n Demo
docker run --rm ghcr.io/1985epma/checklist-linux:latest i18n-demo
```

## 📋 Container Options

### Privileged Mode

The container requires `--privileged` mode for system auditing:

```bash
docker run --privileged ...
```

**Why privileged?**
- Access to system information (processes, users, etc.)
- Read system configuration files
- Perform security audits
- Check firewall rules and network settings

### Volume Mounts

#### Output Directory

Mount a directory for reports:

```bash
-v $(pwd)/output:/output
```

#### Host System Access (Read-Only)

For accurate system auditing:

```bash
-v /etc:/host/etc:ro
-v /var:/host/var:ro
-v /sys:/host/sys:ro
-v /proc:/host/proc:ro
```

#### Docker Socket (Optional)

To inspect containers:

```bash
-v /var/run/docker.sock:/var/run/docker.sock:ro
```

### Network Mode

Use host network for system inspection:

```bash
--network host
```

Or in docker-compose:

```yaml
network_mode: host
```

## 🏗️ Building Locally

### Build from Source

```bash
# Clone repository
git clone https://github.com/1985epma/checklist_linux.git
cd checklist_linux

# Build image
docker build -t checklist-linux:local .

# Run
docker run --rm --privileged checklist-linux:local security-checklist
```

### Build with Docker Compose

```bash
docker-compose build
docker-compose up
```

### Multi-platform Build

```bash
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t checklist-linux:multi .
```

## 📊 Example Usage Scenarios

### 1. Quick Security Audit

```bash
#!/bin/bash
# quick-audit.sh

docker run --rm --privileged \
  --name security-audit \
  -v $(pwd)/reports:/output \
  -v /etc:/host/etc:ro \
  -v /var:/host/var:ro \
  ghcr.io/1985epma/checklist-linux:latest \
  security-checklist -f html -o /output/audit-$(date +%Y%m%d).html

echo "Report generated in: reports/audit-$(date +%Y%m%d).html"
```

### 2. Service Optimization

```bash
docker run -it --rm --privileged \
  --network host \
  -v /etc:/host/etc:ro \
  ghcr.io/1985epma/checklist-linux:latest \
  service-optimizer -t server -m 2
```

### 3. Scheduled Audits with Cron

```bash
# Add to crontab
0 2 * * * docker run --rm --privileged -v /reports:/output -v /etc:/host/etc:ro ghcr.io/1985epma/checklist-linux:latest security-checklist -f html -o /output/daily-$(date +\%Y\%m\%d).html
```

### 4. CI/CD Integration

```yaml
# .gitlab-ci.yml or GitHub Actions
security-audit:
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker pull ghcr.io/1985epma/checklist-linux:latest
    - docker run --rm --privileged 
        -v $(pwd)/reports:/output 
        ghcr.io/1985epma/checklist-linux:latest 
        security-checklist -f html -o /output/security_report.html
  artifacts:
    paths:
      - reports/
```

## 🔐 Security Considerations

### Why Privileged Mode?

The container needs privileged mode to:
- Read system configurations
- Access process information
- Inspect network settings
- Audit security configurations

### Read-Only Mounts

Host system directories are mounted read-only (`:ro`) to prevent accidental modifications.

### Isolation

Even in privileged mode, the container:
- Runs in its own namespace
- Has limited access to host resources
- Cannot modify host system (with read-only mounts)

## 📦 Image Variants

### Tags Available

- `latest` - Latest stable release from main branch
- `develop` - Development version from develop branch
- `v2.0` - Specific version tag
- `main` - Main branch build
- `<commit-sha>` - Specific commit

### Pull Specific Version

```bash
docker pull ghcr.io/1985epma/checklist-linux:v2.0
docker pull ghcr.io/1985epma/checklist-linux:develop
```

## 🛠️ Troubleshooting

### Permission Denied

If you get permission errors:

```bash
# Run with user namespace
docker run --userns=host --privileged ...

# Or add your user to docker group
sudo usermod -aG docker $USER
```

### Container Won't Start

Check Docker daemon:

```bash
sudo systemctl status docker
sudo systemctl start docker
```

### Can't Pull Image

Login to GitHub Container Registry:

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

### Output Files Not Created

Ensure output directory exists and has proper permissions:

```bash
mkdir -p output
chmod 755 output
```

## 🌐 Environment Variables

Available environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `LANG` | `en_US.UTF-8` | Language setting |
| `TZ` | `UTC` | Timezone |
| `DEBIAN_FRONTEND` | `noninteractive` | Avoid prompts |

Set in docker-compose.yml or with `-e`:

```bash
docker run -e LANG=pt_BR.UTF-8 -e TZ=America/Sao_Paulo ...
```

## 📚 Additional Resources

- [Dockerfile](Dockerfile) - Container build configuration
- [docker-compose.yml](docker-compose.yml) - Docker Compose configuration
- [Main Documentation](readme.md) - Full project documentation
- [GitHub Container Registry](https://github.com/1985epma/checklist_linux/pkgs/container/checklist-linux)

## 🤝 Contributing

To contribute to the Docker configuration:

1. Fork the repository
2. Modify Dockerfile or docker-compose.yml
3. Test locally: `docker build -t test .`
4. Submit a Pull Request

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

---

**Need help?** Open an issue on [GitHub](https://github.com/1985epma/checklist_linux/issues)
