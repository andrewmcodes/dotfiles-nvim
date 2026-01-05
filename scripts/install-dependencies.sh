#!/usr/bin/env bash
# Installation script for Neovim dependencies
# This script installs required tools using mise or Homebrew

set -e

echo "🚀 Installing Neovim dependencies..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if mise is installed
if command -v mise &> /dev/null; then
    echo -e "${BLUE}📦 Using mise for dependency management${NC}"

    cd "$(dirname "$0")/.."

    echo -e "${GREEN}Installing tools from .mise.toml...${NC}"
    mise install

    echo -e "${GREEN}✓ mise tools installed${NC}"
    echo -e "${BLUE}Run 'mise list' to see installed tools${NC}"

elif command -v brew &> /dev/null; then
    echo -e "${BLUE}🍺 Using Homebrew for dependency management${NC}"

    echo -e "${GREEN}Installing required tools...${NC}"

    # Install Lua tools
    brew install lua@5.1 || true
    brew install stylua || true
    brew install selene || true

    # Install Node.js for language servers
    brew install node || true

    # Optional: Install Ruby
    # brew install ruby || true

    echo -e "${GREEN}✓ Homebrew packages installed${NC}"

else
    echo -e "${RED}❌ Neither mise nor Homebrew found!${NC}"
    echo ""
    echo "Please install one of the following:"
    echo ""
    echo "Option 1 - mise (recommended):"
    echo "  curl https://mise.run | sh"
    echo "  Then run this script again"
    echo ""
    echo "Option 2 - Homebrew:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "  Then run this script again"
    echo ""
    exit 1
fi

# Install/update Mason packages from within Neovim
echo ""
echo -e "${GREEN}📦 Installing Neovim plugins and LSP servers...${NC}"
echo -e "${BLUE}Opening Neovim to install plugins via lazy.nvim and Mason...${NC}"
echo ""
echo "After Neovim opens:"
echo "1. Wait for lazy.nvim to install plugins"
echo "2. Run :Mason to verify LSP servers are installed"
echo "3. Run :checkhealth to verify everything is working"
echo ""
echo "Press Enter to continue..."
read

nvim +Lazy +qa
nvim +MasonInstallAll +qa 2>/dev/null || echo "MasonInstallAll not available, install Mason tools manually with :Mason"

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Run 'nvim' to start Neovim"
echo "2. Run ':checkhealth' to verify installation"
echo "3. Run ':Mason' to see installed LSP servers"
echo "4. Read CODEX.md for keybindings and features"
