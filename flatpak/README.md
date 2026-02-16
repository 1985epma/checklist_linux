# Flatpak Files

This directory contains all files necessary for building and packaging CHECK LINUX Security Tools as a Flatpak application.

## Files in this Directory

### Application Files
- **checklist-linux-launcher** - Main launcher script that provides a menu interface
- **com.github._1985epma.ChecklistLinux.desktop** - Desktop entry file
- **com.github._1985epma.ChecklistLinux.appdata.xml** - AppStream metadata for app stores
- **com.github._1985epma.ChecklistLinux.svg** - Application icon

## Building the Flatpak

See the [FLATPAK_BUILD.md](../FLATPAK_BUILD.md) file in the project root for detailed build instructions.

### Quick Start

From the project root directory:

```bash
# Interactive build helper
./build-flatpak.sh

# Or build directly
flatpak-builder --user --install --force-clean build-dir com.github._1985epma.ChecklistLinux.yml
```

## File Descriptions

### checklist-linux-launcher
The main entry point for the Flatpak application. Provides an interactive menu to access all tools:
- Security Checklist
- Service Optimizer (CLI and GUI)
- Sudo Permissions Checker
- Corporate Sudo Configurator
- i18n Demo
- Documentation

### Desktop File
Standard freedesktop.org desktop entry that allows the application to appear in application menus. Includes:
- Multiple language translations (en, pt_BR, es)
- Quick action shortcuts
- Proper categorization

### AppData/AppStream Metadata
Provides information for software centers like GNOME Software, KDE Discover, or Flathub:
- Application description
- Screenshots (to be added)
- Release notes
- Developer information
- Keywords and categories

### Icon
SVG vector icon featuring:
- Shield symbol representing security
- Linux penguin mascot
- Lock and terminal symbols
- Scalable to any size

## Customization

If you need to modify the Flatpak package:

1. **Change permissions**: Edit the `finish-args` section in the manifest
2. **Add dependencies**: Add modules in the manifest
3. **Modify launcher**: Edit `checklist-linux-launcher`
4. **Update metadata**: Edit the `.appdata.xml` file
5. **Change icon**: Replace the SVG file

## Testing

After building, test the application:

```bash
# Run the app
flatpak run com.github._1985epma.ChecklistLinux

# Run with debug output
flatpak run --verbose com.github._1985epma.ChecklistLinux

# Access the sandbox shell
flatpak run --command=bash com.github._1985epma.ChecklistLinux
```

## Distribution

Create a bundle for distribution:

```bash
./build-flatpak.sh bundle
```

This creates `checklist-linux.flatpak` that can be shared with others.

## Support

For Flatpak-specific issues, see:
- [FLATPAK_BUILD.md](../FLATPAK_BUILD.md) - Build guide
- [readme.md](../readme.md) - Main documentation
- [GitHub Issues](https://github.com/1985epma/checklist_linux/issues)
