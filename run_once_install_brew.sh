#!/bin/bash

install_on_mac() {
    echo -e "[INFO] Installing Homebrew on Mac..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

OS="$(uname -s)"
case "${OS}" in
    Linux*)
        echo "Linux detected skipping brew install"
        exit 0
        ;;
    Darwin*)
        install_on_mac
        ;;
    *)
        echo "Unsupported operating system: ${OS}"
        exit 1
        ;;
esac

echo "Brew installation complete."
