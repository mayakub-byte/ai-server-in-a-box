#!/bin/bash
# ============================================================
#  AI Server in a Box - Set API Keys
#  Configure environment variables for AI services
#
#  Run: bash scripts/set_api_keys.sh
# ============================================================

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║     API Keys Configuration                   ║"
echo "║     AI Server in a Box                       ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ============================================================
# Google API Key (Gemini, Imagen, etc.)
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Google API Key (for Gemini)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Get your key from: https://aistudio.google.com/apikey"
echo ""

if [ -n "$GOOGLE_API_KEY" ]; then
    echo "Current GOOGLE_API_KEY is set:"
    echo "  ${GOOGLE_API_KEY:0:20}..."
    read -p "Update it? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        GOOGLE_API_KEY_NEW=$GOOGLE_API_KEY
    else
        read -p "Enter your Google API key: " GOOGLE_API_KEY_NEW
    fi
else
    read -p "Enter your Google API key: " GOOGLE_API_KEY_NEW
fi

# ============================================================
# Anthropic API Key (Claude)
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Anthropic API Key (for Claude Code)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Get your key from: https://console.anthropic.com/settings/keys"
echo ""

if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo "Current ANTHROPIC_API_KEY is set:"
    echo "  ${ANTHROPIC_API_KEY:0:20}..."
    read -p "Update it? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        ANTHROPIC_API_KEY_NEW=$ANTHROPIC_API_KEY
    else
        read -p "Enter your Anthropic API key: " ANTHROPIC_API_KEY_NEW
    fi
else
    read -p "Enter your Anthropic API key: " ANTHROPIC_API_KEY_NEW
fi

# ============================================================
# Save to shell profiles
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Saving keys to shell profiles..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Add to zsh (macOS default)
if [ -f ~/.zshrc ]; then
    # Remove old entries if they exist
    sed -i '' '/export GOOGLE_API_KEY=/d' ~/.zshrc
    sed -i '' '/export ANTHROPIC_API_KEY=/d' ~/.zshrc

    # Add new entries
    echo "" >> ~/.zshrc
    echo "# AI Server API Keys" >> ~/.zshrc
    echo "export GOOGLE_API_KEY=\"$GOOGLE_API_KEY_NEW\"" >> ~/.zshrc
    echo "export ANTHROPIC_API_KEY=\"$ANTHROPIC_API_KEY_NEW\"" >> ~/.zshrc

    echo "✓ Updated ~/.zshrc"
fi

# Add to bash profile
if [ -f ~/.bash_profile ]; then
    # Remove old entries if they exist
    sed -i '' '/export GOOGLE_API_KEY=/d' ~/.bash_profile
    sed -i '' '/export ANTHROPIC_API_KEY=/d' ~/.bash_profile

    # Add new entries
    echo "" >> ~/.bash_profile
    echo "# AI Server API Keys" >> ~/.bash_profile
    echo "export GOOGLE_API_KEY=\"$GOOGLE_API_KEY_NEW\"" >> ~/.bash_profile
    echo "export ANTHROPIC_API_KEY=\"$ANTHROPIC_API_KEY_NEW\"" >> ~/.bash_profile

    echo "✓ Updated ~/.bash_profile"
fi

# Set in current session
export GOOGLE_API_KEY="$GOOGLE_API_KEY_NEW"
export ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY_NEW"

# Set via launchctl for background services
launchctl setenv GOOGLE_API_KEY "$GOOGLE_API_KEY_NEW" 2>/dev/null
launchctl setenv ANTHROPIC_API_KEY "$ANTHROPIC_API_KEY_NEW" 2>/dev/null

# ============================================================
# Summary
# ============================================================
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  API Keys Configured!                        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Your keys have been saved to:"
echo "  • ~/.zshrc"
echo "  • ~/.bash_profile"
echo ""
echo "Keys are now available in:"
echo "  • Current terminal session"
echo "  • New terminal windows (after reload)"
echo "  • Background services (launchctl)"
echo ""
echo "To reload in current session:"
echo "  source ~/.zshrc"
echo ""
echo "Test your keys:"
echo "  echo \$GOOGLE_API_KEY"
echo "  echo \$ANTHROPIC_API_KEY"
echo ""
