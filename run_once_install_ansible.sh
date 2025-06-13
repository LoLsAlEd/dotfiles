#!/bin/bash

install_on_fedora() {
    echo -e "[INFO] Installing Homebrew on Fedora..."
    sudo dnf install -y ansible
}

install_on_ubuntu() {
    # Install Homebrew
    echo -e "[INFO] Installing Homebrew on Ubuntu..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc

    # Install Ansible
    echo -e "[INFO] Installing Ansible on Linux..."
    sudo apt-get update
    sudo apt-get install -y ansible
}

install_on_mac() {
    echo -e "[INFO] Installing Ansible on Mac..."
    brew install ansible
}

OS="$(uname -s)"
case "${OS}" in
    Linux*)
        if [ -f /etc/fedora-release ]; then
            install_on_fedora
        elif [ -f /etc/lsb-release ]; then
            install_on_ubuntu
        else
            echo "Unsupported Linux distribution"
            exit 1
        fi
        ;;
    Darwin*)
        install_on_mac
        ansible-playbook ~/.bootstrap/setup-mac.yml --ask-become-pass
        ;;
    *)
        echo "Unsupported operating system: ${OS}"
        exit 1
        ;;
esac

echo "Ansible installation complete."
