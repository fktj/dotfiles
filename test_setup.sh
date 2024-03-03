#!/bin/sh
set -e
echo "Please enter your email:"
read user_email
echo "Please enter your username:"
read user_name
echo "$user_email"
echo "$user_name"

# Get shell name
shell_name=$(sh -c 'ps -p $$ -o ppid=' | xargs ps -o comm= -p)


# Function to install a package if it's not already installed
install_package() {
    if ! command -v $1 &> /dev/null
    then
        echo "Installing $1"
        sudo apt install $1 -y
    else
        echo "$1 is already installed."
    fi
}

# Array of packages to install
packages=("unzip" "zsh" "gh" "gnupg")

# Update and upgrade packages
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y

# Install basic packages
echo "Do you want to setup basics? (yes/no)"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
    echo "Installing basic packages"
    
    # Check if unzip is installed, if not install it
    if ! command -v unzip &> /dev/null
    then
        sudo apt install unzip -y
    fi

    # Check if zsh is installed, if not install it
    if ! command -v zsh &> /dev/null
    then
        sudo apt install zsh -y
    fi

    # Check if gh is installed, if not install it
    if ! command -v gh &> /dev/null
    then
        sudo apt install gh -y
    fi

    # Check if databricks-cli is installed, if not install it
    if ! command -v databricks &> /dev/null
    then
        curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sudo sh
    fi

    # Check if azure cli is installed, if not install it
    if ! command -v az &> /dev/null
    then
        echo "Installing azure-cli"
        sleep 2
        sudo apt install ca-certificates curl apt-transport-https lsb-release gnupg -y
        curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
        AZ_REPO=$(lsb_release -cs)
        # might be an issue here
        echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
        sudo apt update
        sudo apt install azure-cli -y
    fi
    az_version=$(az --version)
    echo $az_version
    sleep 2

    # Check if git-credential-manager is installed, if not install it
    if ! command -v git-credential-manager &> /dev/null
    then
        echo "Installing git credential manager"
        sleep 2
        sudo dpkg --print-architecture
        wget "https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.4.1/gcm-linux_amd64.2.4.1.deb" -O /tmp/gcmcore.deb
        sudo dpkg -i /tmp/gcmcore.deb
    fi
    git_cred_manager_version=$(git-credential-manager --version)
    echo "Git Credential Manager: $git_cred_manager_version"
    sleep 2

    # Check if gpg is installed, if not install it
    if ! command -v gpg &> /dev/null
    then
        echo "GPG is not installed. Installing..."
        sudo apt update
        sudo apt install gnupg -y
    else
        echo "GPG is already installed."
        gpg_version_full=$(gpg --version)
        gpg_version=$(echo "$gpg_version_full" | head -n 1 | awk '{print $3}')
        if [[ $(echo -e "2.1.17\n$gpg_version" | sort -V | head -n1) != "2.1.17" ]]; then
            echo "GPG version is below 2.1.17. Updating..."
            sudo apt update
            sudo apt upgrade gnupg -y
        else
            echo "GPG version is equal to or above 2.1.17"
        fi
    fi

    # Setup GPG
    echo "Setting up GPG"
    gpg --full-generate-key
    output=$(gpg --list-secret-keys --keyid-format=long)
    key_id=$(echo "$output" | awk '/sec/{print $2}' | cut -d'/' -f2)
    gpg --armor --export key_id
    sleep 2


    # Check if ssh is installed, if not install it
    if ! command -v ssh &> /dev/null
    then
        echo "SSH is not installed. Installing..."
        sudo apt update
        sudo apt install openssh-client -y
    else
        echo "SSH is already installed."
        ssh_version_full=$(ssh -V 2>&1)
        ssh_version=$(echo "$ssh_version_full" | awk -F_ '{print $2}')
        if [[ $(echo -e "7.6\n$ssh_version" | sort -V | head -n1) != "7.6" ]]; then
            echo "SSH version is below 7.6. Updating..."
            sudo apt update
            sudo apt upgrade openssh-client -y
        else
            echo "SSH version is equal to or above 7.6"
        fi
    fi

    # Setup ssh
    echo "Setting up SSH..."
    ssh-keygen -t rsa -b 4096 -C $user_email


    # Check if git is installed
    if ! command -v git &> /dev/null
    then
        echo "Git is not installed. Installing..."
        sudo apt update
        sudo apt install git -y
    else
        echo "Git is already installed."
    fi

    # Set global git config
    echo "Do you want to set global git config? (yes/no)"
    read answer

    if [ "$answer" != "${answer#[Yy]}" ] ;then
        # Set git global config 
        git config --global user.email $user_email
        git config --global user.name $user_name
    fi

    if ! command -v mcfly &> /dev/null
    then
        echo "McFly is not installed. Installing..."
        curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly --to ~/.local/bin
        echo "McFly installation completed."
    else
        echo "McFly is already installed."
        sleep 2
    fi

    if ! command -v zoxide &> /dev/null
    then
        echo "zoxide is not installed. Installing..."
        curl -sS https://webinstall.dev/zoxide | bash
        echo "zoxide installation completed."
    else
        echo "zoxide is already installed."
    fi

    # Check if Oh My Zsh is installed
    if [ ! -d "$HOME/.oh-my-zsh" ]
    then
        echo "Oh My Zsh is not installed. Installing..."
        echo "Installing oh-my-zsh (choose 2 and it will be setup quickly)"
        sleep 3
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        echo "Oh-my-zsh installation completed. Returning to setup script..."
        chsh -s /bin/bash $user_name
        sleep 3
        echo "Installing plugins"
        sudo apt install fzf -y && \
        sudo apt install zsh-autosuggestions -y
    else
        echo "Oh My Zsh is already installed."
    fi

    # Check if Starship is installed
    if ! command -v starship &> /dev/null
    then
        echo "Starship is not installed. Installing..."
        echo "Installing fira code font"
        sleep 2
        mkdir -p ~/.local/share/fonts/
        for type in Bold Light Medium Regular Retina; do wget -nc -O ~/.local/share/fonts//FiraCode-$type.ttf "https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/FiraCode/$type/complete/Fira%20Code%20$type%20Nerd%20Font%20Complete.ttf?raw=true"; done
        fc-cache -f ~/.local/share/fonts/
        
        
        echo "Installing starship"
        # Ensure Starship is installed and up to date.
        mkdir -p ~/.local/bin
        RUNZSH=no sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --force --bin-dir ~/.local/bin
        export PATH="~/.local/bin:$PATH"
        echo "Starship installation completed. Returning to setup script..."
    else
        echo "Starship is already installed."
    fi
    echo "Getting dotfiles"
    sleep 2
    # Ensure dotfiles are downloaded.
    mkdir -p ~/.dotfiles
    wget -N -P ~/.dotfiles/ "https://raw.githubusercontent.com/fktj/dotfiles/main/.dotfiles/starship.toml"
    wget -N -P ~/.dotfiles/ "https://raw.githubusercontent.com/fktj/dotfiles/main/.dotfiles/.commonrc"
    wget -N -P ~/.dotfiles/ "https://raw.githubusercontent.com/fktj/dotfiles/main/.dotfiles/.zshrc"
    wget -N -P ~/.dotfiles/ "https://raw.githubusercontent.com/fktj/dotfiles/main/.dotfiles/.bashrc"


    # Ensure dotfiles are symlinked.
    echo "Symlinking dotfiles"
    sleep 2
    case $shell_name in
        *"zsh"* )
            rm -f ~/.zshrc
            ln -s ~/.dotfiles/.zshrc ~/.zshrc
            ;;
        *"bash"* )
            rm -f ~/.bashrc
            ln -s ~/.dotfiles/.bashrc ~/.bashrc
            ;;
    esac
    mkdir -p ~/.config
    rm -f ~/.config/starship.toml
    ln -s ~/.dotfiles/starship.toml ~/.config/starship.toml
    
    # Source dotfiles.
    case $shell_name in
        *"zsh"* )
            test -e ~/.zshrc && . ~/.zshrc
            ;;
        *"bash"* )
            test -e ~/.bashrc && . ~/.bashrc
            ;;
    esac

    # Finished
    echo "Done. Remember to move or symlink any local rc to ~/.localrc"

    # Setup pip and pipx
    echo "Setting up pip and pipx"
    sleep 2

    
    if ! which pip3 > /dev/null; then
        sudo apt install python3-pip -y
    fi

    if ! which pipx > /dev/null; then
        sudo apt install pipx -y
    fi

    pipx ensurepath
    source ~/.bashrc || source ~/.zshrc
    pipx_version=$(pipx --version)
    echo "pipx: $pipx_version"
    sleep 2

    # Bash
    pipx install poetry
    pipx upgrade poetry

    # Set an environment variable
    echo "adding poetry to PATH"
    sleep 2
    export POETRY_HOME="$HOME/.poetry"
    echo 'export PATH="$POETRY_HOME/bin:$PATH"' >> ~/.bashrc

    # Source the profile file to make the PATH changes take effect
    source ~/.bashrc

    # Check the Poetry version
    poetry_version=$(poetry --version)
    echo "Poetry: $poetry_version"
    sleep 3


    ubuntu_version=$(lsb_release -d)
    python_version=$(python3 --version)
    git_version=$(git --version)
    databricks_version=$(databricks --version)
    zsh_version=$(zsh --version)
    echo "Verifications"
    echo "Ubuntu: $ubuntu_version"
    echo $python_version
    echo $git_version
    echo $databricks_version
    echo $zsh_version
    echo "--------------------------------"
    sleep 6
    echo "You need to run the manually and setup the credential manager with command:"
    echo "git-credential-manager configure"
    sleep 3
    # Finished
    echo "Done. Remember to move or symlink any local rc to ~/.localrc"
fi



