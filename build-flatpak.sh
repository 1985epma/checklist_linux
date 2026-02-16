#!/bin/bash
# Flatpak Build Helper Script for CHECK LINUX Security Tools

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

APP_ID="com.github._1985epma.ChecklistLinux"
MANIFEST="${APP_ID}.yml"
BUILD_DIR="build-dir"
REPO_DIR="repo"
BUNDLE_FILE="checklist-linux.flatpak"

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}   CHECK LINUX Security Tools - Flatpak Build Helper${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

check_dependencies() {
    echo -e "${YELLOW}Checking dependencies...${NC}"
    
    if ! command -v flatpak &> /dev/null; then
        echo -e "${RED}Error: flatpak is not installed${NC}"
        echo "Install it with: sudo apt install flatpak"
        exit 1
    fi
    
    if ! command -v flatpak-builder &> /dev/null; then
        echo -e "${RED}Error: flatpak-builder is not installed${NC}"
        echo "Install it with: sudo apt install flatpak-builder"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Dependencies OK${NC}"
    echo ""
}

check_runtime() {
    echo -e "${YELLOW}Checking Flatpak runtime...${NC}"
    
    if ! flatpak list --runtime | grep -q "org.freedesktop.Platform.*23.08"; then
        echo -e "${YELLOW}Runtime not found. Installing...${NC}"
        flatpak install -y flathub org.freedesktop.Platform//23.08
        flatpak install -y flathub org.freedesktop.Sdk//23.08
    fi
    
    echo -e "${GREEN}✓ Runtime OK${NC}"
    echo ""
}

build_flatpak() {
    echo -e "${YELLOW}Building Flatpak package...${NC}"
    echo ""
    
    flatpak-builder --force-clean "$BUILD_DIR" "$MANIFEST"
    
    echo ""
    echo -e "${GREEN}✓ Build completed successfully${NC}"
    echo ""
}

install_flatpak() {
    local install_type="$1"
    
    echo -e "${YELLOW}Installing Flatpak package...${NC}"
    echo ""
    
    if [ "$install_type" = "system" ]; then
        echo -e "${BLUE}Installing system-wide (requires sudo)...${NC}"
        flatpak-builder --install --force-clean "$BUILD_DIR" "$MANIFEST"
    else
        echo -e "${BLUE}Installing for current user...${NC}"
        flatpak-builder --user --install --force-clean "$BUILD_DIR" "$MANIFEST"
    fi
    
    echo ""
    echo -e "${GREEN}✓ Installation completed${NC}"
    echo ""
}

create_bundle() {
    echo -e "${YELLOW}Creating distributable bundle...${NC}"
    echo ""
    
    # Build and export to repository
    flatpak-builder --repo="$REPO_DIR" --force-clean "$BUILD_DIR" "$MANIFEST"
    
    # Create bundle
    flatpak build-bundle "$REPO_DIR" "$BUNDLE_FILE" "$APP_ID"
    
    echo ""
    echo -e "${GREEN}✓ Bundle created: ${BUNDLE_FILE}${NC}"
    echo ""
}

run_app() {
    echo -e "${YELLOW}Running application...${NC}"
    echo ""
    flatpak run "$APP_ID"
}

uninstall_app() {
    echo -e "${YELLOW}Uninstalling application...${NC}"
    echo ""
    
    if flatpak list --app | grep -q "$APP_ID"; then
        flatpak uninstall -y "$APP_ID"
        echo -e "${GREEN}✓ Application uninstalled${NC}"
    else
        echo -e "${YELLOW}Application is not installed${NC}"
    fi
    echo ""
}

clean_build() {
    echo -e "${YELLOW}Cleaning build files...${NC}"
    
    rm -rf "$BUILD_DIR" "$REPO_DIR" .flatpak-builder
    
    if [ -f "$BUNDLE_FILE" ]; then
        rm "$BUNDLE_FILE"
    fi
    
    echo -e "${GREEN}✓ Build files cleaned${NC}"
    echo ""
}

show_menu() {
    print_header
    echo "Select an option:"
    echo ""
    echo "  1) Build Flatpak"
    echo "  2) Build and Install (User)"
    echo "  3) Build and Install (System)"
    echo "  4) Create Distributable Bundle"
    echo "  5) Run Application"
    echo "  6) Uninstall Application"
    echo "  7) Clean Build Files"
    echo "  8) Full Process (Build + Install User + Run)"
    echo "  0) Exit"
    echo ""
    echo -ne "${GREEN}Enter your choice [0-8]: ${NC}"
}

# Main menu loop
main() {
    if [ ! -f "$MANIFEST" ]; then
        echo -e "${RED}Error: Manifest file not found: $MANIFEST${NC}"
        echo "Make sure you're in the project root directory."
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # If arguments provided, run non-interactively
    if [ $# -gt 0 ]; then
        case "$1" in
            build)
                check_runtime
                build_flatpak
                ;;
            install-user)
                check_runtime
                install_flatpak "user"
                ;;
            install-system)
                check_runtime
                install_flatpak "system"
                ;;
            bundle)
                check_runtime
                create_bundle
                ;;
            run)
                run_app
                ;;
            uninstall)
                uninstall_app
                ;;
            clean)
                clean_build
                ;;
            full)
                check_runtime
                build_flatpak
                install_flatpak "user"
                run_app
                ;;
            *)
                echo "Usage: $0 {build|install-user|install-system|bundle|run|uninstall|clean|full}"
                exit 1
                ;;
        esac
        exit 0
    fi
    
    # Interactive mode
    while true; do
        show_menu
        read choice
        
        case $choice in
            0)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            1)
                check_runtime
                build_flatpak
                read -p "Press Enter to continue..."
                ;;
            2)
                check_runtime
                install_flatpak "user"
                read -p "Press Enter to continue..."
                ;;
            3)
                check_runtime
                install_flatpak "system"
                read -p "Press Enter to continue..."
                ;;
            4)
                check_runtime
                create_bundle
                read -p "Press Enter to continue..."
                ;;
            5)
                run_app
                read -p "Press Enter to continue..."
                ;;
            6)
                uninstall_app
                read -p "Press Enter to continue..."
                ;;
            7)
                clean_build
                read -p "Press Enter to continue..."
                ;;
            8)
                check_runtime
                build_flatpak
                install_flatpak "user"
                echo ""
                echo -e "${GREEN}Build and installation complete!${NC}"
                echo -e "${YELLOW}Starting application...${NC}"
                echo ""
                sleep 2
                run_app
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                sleep 2
                ;;
        esac
    done
}

main "$@"
