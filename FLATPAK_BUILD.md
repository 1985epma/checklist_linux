# Flatpak Build and Installation Guide

This guide explains how to build and install CHECK LINUX Security Tools as a Flatpak package.

## Prerequisites

### Install Flatpak and flatpak-builder

#### On Ubuntu/Debian:
```bash
sudo apt update
sudo apt install flatpak flatpak-builder
```

#### On Fedora:
```bash
sudo dnf install flatpak flatpak-builder
```

#### On Arch Linux:
```bash
sudo pacman -S flatpak flatpak-builder
```

### Add Flathub Repository
```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### Install Required Runtime and SDK
```bash
flatpak install flathub org.freedesktop.Platform//23.08
flatpak install flathub org.freedesktop.Sdk//23.08
```

## Building the Flatpak

### 1. Clone the Repository
```bash
git clone https://github.com/1985epma/checklist_linux.git
cd checklist_linux
```

### 2. Build the Flatpak Package

Build the application:
```bash
flatpak-builder --force-clean build-dir com.github._1985epma.ChecklistLinux.yml
```

This will:
- Download the runtime and SDK if not already installed
- Build the application in the `build-dir` directory
- Compile all components according to the manifest

### 3. Install Locally

Install for current user only:
```bash
flatpak-builder --user --install --force-clean build-dir com.github._1985epma.ChecklistLinux.yml
```

Or install system-wide (requires sudo):
```bash
flatpak-builder --install --force-clean build-dir com.github._1985epma.ChecklistLinux.yml
```

## Running the Application

After installation, you can run the application in several ways:

### From Application Menu
Look for "CHECK LINUX Security Tools" in your application menu under System or Utilities.

### From Command Line
```bash
flatpak run com.github._1985epma.ChecklistLinux
```

### Run Specific Tools Directly
```bash
# Security Checklist
flatpak run --command=security-checklist com.github._1985epma.ChecklistLinux

# Service Optimizer
flatpak run --command=service-optimizer com.github._1985epma.ChecklistLinux

# Sudo Permissions Checker
flatpak run --command=sudo-permissions-checker com.github._1985epma.ChecklistLinux
```

## Creating a Distributable Package

### Create a Flatpak Bundle

To create a single file that can be distributed:

```bash
# Build and export to a repository
flatpak-builder --repo=repo --force-clean build-dir com.github._1985epma.ChecklistLinux.yml

# Create a bundle file
flatpak build-bundle repo checklist-linux.flatpak com.github._1985epma.ChecklistLinux
```

This creates `checklist-linux.flatpak` that can be shared with others.

### Install from Bundle

Users can install the bundle with:
```bash
flatpak install checklist-linux.flatpak
```

## Publishing to Flathub

To make your application available on Flathub:

1. Fork the [Flathub repository](https://github.com/flathub/flathub)

2. Create a new repository for your app:
   - Repository name: `com.github._1985epma.ChecklistLinux`
   - Add your manifest file
   - Add a `flathub.json` file if needed

3. Submit a pull request to Flathub

4. Follow the [Flathub submission guidelines](https://github.com/flathub/flathub/wiki/App-Submission)

## Updating the Application

### For Users

Update all Flatpak applications:
```bash
flatpak update
```

Update only CHECK LINUX:
```bash
flatpak update com.github._1985epma.ChecklistLinux
```

### For Developers

After making changes to the code:

1. Update version in the manifest if needed
2. Rebuild and reinstall:
```bash
flatpak-builder --user --install --force-clean build-dir com.github._1985epma.ChecklistLinux.yml
```

## Uninstalling

Remove the application:
```bash
flatpak uninstall com.github._1985epma.ChecklistLinux
```

Remove all unused runtimes:
```bash
flatpak uninstall --unused
```

## Troubleshooting

### Permission Issues

If the application cannot access system files:
```bash
# Grant additional permissions
flatpak override com.github._1985epma.ChecklistLinux --filesystem=host
```

### Debug Mode

Run with debug output:
```bash
flatpak run --verbose com.github._1985epma.ChecklistLinux
```

### Access Shell Inside Flatpak

For debugging purposes:
```bash
flatpak run --command=bash com.github._1985epma.ChecklistLinux
```

## File Locations

After installation, files are located at:

### User Installation
- Application: `~/.local/share/flatpak/app/com.github._1985epma.ChecklistLinux/`
- Data: `~/.var/app/com.github._1985epma.ChecklistLinux/`

### System Installation
- Application: `/var/lib/flatpak/app/com.github._1985epma.ChecklistLinux/`
- Data: `/var/lib/flatpak/app/com.github._1985epma.ChecklistLinux/`

## Sandboxing Notes

Flatpak runs applications in a sandbox. This application requires:

- **Host filesystem access** (read-only): To audit system configurations
- **Network access**: For checking updates
- **System bus access**: For systemd service information
- **PolicyKit integration**: For running privileged operations

These permissions are specified in the manifest and necessary for the security tools to function properly.

## Security Considerations

While this application performs security audits, it runs in a Flatpak sandbox for isolation. When performing privileged operations, it uses PolicyKit (pkexec) to request authorization, ensuring:

- Operations are logged
- User consent is required
- Minimum necessary privileges are granted

## Additional Resources

- [Flatpak Documentation](https://docs.flatpak.org/)
- [Flatpak Builder Documentation](https://docs.flatpak.org/en/latest/flatpak-builder.html)
- [Flathub Submission Guidelines](https://github.com/flathub/flathub/wiki/App-Submission)
- [Project Repository](https://github.com/1985epma/checklist_linux)

## Support

For issues related to:
- **Flatpak packaging**: Open an issue on the [GitHub repository](https://github.com/1985epma/checklist_linux/issues)
- **Application functionality**: See the main [README](readme.md)
- **Flatpak general questions**: Visit [Flatpak documentation](https://docs.flatpak.org/)
