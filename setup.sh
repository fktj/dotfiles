#!/bin/sh

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
        sudo apt install -y $1
    else
        echo "$1 is already installed. Updating to the latest version..."
        sudo apt upgrade -y $1
    fi
}

# Update package lists
sudo apt update -y

# Upgrade packages and remove unnecessary packages
sudo apt upgrade -y && sudo apt autoremove -y

# Install basic packages
echo "Do you want to setup basics? (yes/no)"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
    echo "Installing basic packages"

    # Array of packages to install
    packages=(  "unzip" \
                "zsh" \
                "gh" \
                "gnupg" \
                "openssh-client" \
                "git" \
                "python3-pip" \
                "pipx" \
                "ca-certificates" \
                "curl" \
                "apt-transport-https" \
                "lsb-release" \
                "direnv"
            )

    # Loop over the array and install each package
    for package in "${packages[@]}"
    do
        install_package $package
    done


    # Check if certain commands are installed, if not install them
    commands=( "databricks" "az" "git-credential-manager" "mcfly" "zoxide" "zsh" "starship" )


    for command in "${commands[@]}"
    do
        if ! command -v $command &> /dev/null
        then
            echo "Installing $command..."
            case $command in
                "databricks")
                    curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sudo sh
                    ;;
                "az")
                    # Azure CLI installation script
                    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
                    AZ_REPO=$(lsb_release -cs)
                    # might be an issue here
                    echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
                    sudo apt update
                    sudo apt install azure-cli -y
                    az_version=$(az --version)
                    ;;
                "git-credential-manager")
                    # Insert Git Credential Manager installation script here
                    sudo dpkg --print-architecture
                    wget "https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.4.1/gcm-linux_amd64.2.4.1.deb" -O /tmp/gcmcore.deb && sudo dpkg -i /tmp/gcmcore.deb
                    git_cred_manager_version=$(git-credential-manager --version)
                    ;;
                "mcfly")
                    curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly --to ~/.local/bin
                    ;;
                "zoxide")
                    curl -sS https://webinstall.dev/zoxide | bash
                    ;;
                "zsh")
                    if [ ! -d "$HOME/.oh-my-zsh" ]
                    then
                        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
                        chsh -s /bin/bash $user_name
                        sudo apt install fzf -y && sudo apt install zsh-autosuggestions -y
                    fi
                    ;;
                "starship")
                    mkdir -p ~/.local/share/fonts/
                    for type in Bold Light Medium Regular Retina; 
                    do 
                        wget -nc -O ~/.local/share/fonts//FiraCode-$type.ttf "https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/FiraCode/$type/complete/Fira%20Code%20$type%20Nerd%20Font%20Complete.ttf?raw=true"; 
                    done
                    fc-cache -f ~/.local/share/fonts/
                    mkdir -p ~/.local/bin
                    RUNZSH=no sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --force --bin-dir ~/.local/bin
                    export PATH="~/.local/bin:$PATH"
                    ;;
            esac
        else
            echo "$command is already installed."
        fi
    done


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


    # Set pipx path and add poetry
    pipx ensurepath
    source ~/.bashrc || source ~/.zshrc
    pipx_version=$(pipx --version)
    pipx install poetry
    source ~/.bashrc || source ~/.zshrc
    pipx upgrade poetry
    export PATH="$HOME/.local/bin:$PATH"
    poetry_version=$(poetry --version)
 

    # Set global git config
    echo "Do you want to set global git config? (yes/no)"
    read answer

    if [ "$answer" != "${answer#[Yy]}" ] ;then
        # Set git global config 
        git config --global user.email $user_email
        git config --global user.name $user_name
        git config --global credential.helper "$(which git-credential-manager)"
    fi

    # Configure ssh connection
    ssh-keygen -t rsa -b 4096 -C $user_email
    # Start the ssh-agent in the background
    eval "$(ssh-agent -s)"
    # Add your SSH private key to the ssh-agent
    ssh-add ~/.ssh/id_rsa
    echo "######### Add this SSH key to your azure devops account  #########"
    cat ~/.ssh/id_rsa.pub
    echo "######### Done  #########"
    echo "Remember to move or symlink any local rc to ~/.localrc"