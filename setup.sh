#!/bin/bash
echo "######### Setup log #########" >> setuplog.txt
echo "Please enter your email:"
read user_email

if [ -n "$SUDO_USER" ]; then
    user_name=$SUDO_USER
else
    user_name=$(whoami)
fi

if [ -n "$SUDO_USER" ]; then
    user_home=$(getent passwd $SUDO_USER | cut -d: -f6)
else
    user_home=$HOME
fi

shell_name=$(basename $SHELL)

echo "Ran as: $user_name" >> setuplog.txt
echo "User home: $user_home" >> setuplog.txt
echo "Shell name: $shell_name" >> setuplog.txt
echo "---------------------------------" >> setuplog.txt

install_package() {
    if ! command -v $1 &> /dev/null
    then
        sudo apt install -y $1
    else
        echo "$1 is already installed. Updating to the latest version..."
        sudo apt upgrade -y $1
    fi
}

sudo apt update -y
sudo apt upgrade -y && sudo apt autoremove -y

echo "Do you want to setup basics? (yes/no)"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
    echo "Installing basic packages"

    packages=(  "unzip" \
                "zsh" \
                "gh" \
                "git" \
                "python3-pip" \
                "gnupg" \
                "pipx" \
                "ca-certificates" \
                "apt-transport-https" \
                "curl" \
                "lsb-release" 
            )

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
                "zsh")
                    if [ ! -d "$user_home/.oh-my-zsh" ]
                    then
                        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
                        chsh -s /bin/zsh $user_name
                        sudo apt install fzf -y && sudo apt install zsh-autosuggestions -y
                    fi
                    ;;
                "databricks")
                    curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sudo sh
                    ;;
                "az")
                    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
                    AZ_REPO=$(lsb_release -cs)
                    echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
                    sudo apt update
                    sudo apt install azure-cli -y
                    ;;
                "git-credential-manager")
                    wget "https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.4.1/gcm-linux_amd64.2.4.1.deb" -O /tmp/gcmcore.deb && sudo dpkg -i /tmp/gcmcore.deb
                    ;;
                "mcfly")
                    curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly --to $user_home/.local/bin
                    ;;
                "zoxide")
                    curl -sS https://webinstall.dev/zoxide | bash
                    ;;
                "starship")
                    mkdir -p $user_home/.local/share/fonts/
                    for type in Bold Light Medium Regular Retina; 
                    do 
                        wget -nc -O $user_home/.local/share/fonts//FiraCode-$type.ttf "https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/FiraCode/$type/complete/Fira%20Code%20$type%20Nerd%20Font%20Complete.ttf?raw=true"; 
                    done
                    fc-cache -f $user_home/.local/share/fonts/
                    mkdir -p $user_home/.local/bin
                    RUNZSH=no sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --force --bin-dir $user_home/.local/bin
                    export PATH="$user_home/.local/bin:$PATH"
                    ;;
            esac
        else
            echo "$command is already installed."
        fi
    done

    # Ensure dotfiles are downloaded.
    mkdir -p $user_home/.dotfiles || echo "---->Failed to create directory $user_home/.dotfiles" >> setuplog.txt
    wget -N -P $user_home/.dotfiles/ "https://raw.githubusercontent.com/fktj/dotfiles/main/.dotfiles/starship.toml"
    wget -N -P $user_home/.dotfiles/ "https://raw.githubusercontent.com/fktj/dotfiles/main/.dotfiles/.commonrc"
    wget -N -P $user_home/.dotfiles/ "https://raw.githubusercontent.com/fktj/dotfiles/main/.dotfiles/.zshrc"
    wget -N -P $user_home/.dotfiles/ "https://raw.githubusercontent.com/fktj/dotfiles/main/.dotfiles/.bashrc"

    # Ensure dotfiles are symlinked.
    echo "Symlinking dotfiles"
    case $shell_name in
        *"zsh"* )
            rm -f $user_home/.zshrc
            ln -s $user_home/.dotfiles/.zshrc $user_home/.zshrc
            ;;
        *"bash"* )
            rm -f $user_home/.bashrc
            ln -s $user_home/.dotfiles/.bashrc $user_home/.bashrc
            ;;
    esac
    mkdir -p $user_home/.config || echo "Failed to create directory $user_home/.config"
    rm -f $user_home/.config/starship.toml
    ln -s $user_home/.dotfiles/starship.toml $user_home/.config/starship.toml
    
    # Source dotfiles.
    case $shell_name in
        *"zsh"* )
            test -e $user_home/.zshrc && . $user_home/.zshrc
            ;;
        *"bash"* )
            test -e $user_home/.bashrc && . $user_home/.bashrc
            ;;
    esac

    # Set pipx path and add poetry
    pipx ensurepath
    export PATH="$user_home/.local/bin:$PATH"
    source $user_home/.bashrc || source $user_home/.zshrc
    pipx install poetry
    pipx upgrade poetry
 
    # Set git global config
    echo "Do you want to set global git config? (yes/no)"
    read answer
    if [ "$answer" != "${answer#[Yy]}" ] ;then
        # Set git global config 
        git config --global user.email $user_email
        git config --global user.name $user_name
        git config --global credential.helper "$(which git-credential-manager)"
    fi

    unzip_version="unsip: $(unzip -v | head -n 1)"
    zsh_version=$(zsh --version)
    gh_version=$(gh --version | head -n 1)
    git_version=$(git --version)
    python3_version=$(python3 --version)
    python3_pip_version=$(pip3 --version)
    ca_certificates_version="ca-certificates: $(apt-cache policy ca-certificates | head -n 3)"
    curl_version=$(curl --version | head -n 1 | awk '{print $1, $2, $3}')
    lsb_release_version="lsb release: $(lsb_release -a 2>/dev/null | grep Description | cut -f 2- -d ':')"
    databricks_version=$(databricks --version)
    az_version=$(az --version | head -n 1)
    git_cred_manager_version="git credential manger: $(git-credential-manager --version)"
    pipx_version="pipx: $(pipx --version)"
    poetry_version=$(poetry --version)
    git_config=$(git config --global --list)

    echo "$unzip_version" >> setuplog.txt
    echo "$zsh_version" >> setuplog.txt
    echo "$gh_version" >> setuplog.txt
    echo "$git_version" >> setuplog.txt
    echo "$python3_version" >> setuplog.txt
    echo "$python3_pip_version" >> setuplog.txt
    echo "$ca_certificates_version" >> setuplog.txt
    echo "$curl_version" >> setuplog.txt
    echo "$lsb_release_version" >> setuplog.txt
    echo "$databricks_version" >> setuplog.txt
    echo "$az_version" >> setuplog.txt
    echo "$git_cred_manager_version" >> setuplog.txt
    echo "$pipx_version" >> setuplog.txt
    echo "$poetry_version" >> setuplog.txt
    echo "$git_config" >> setuplog.txt
    echo "######### Done  #########"
    echo "Remember to move or symlink any local rc to ~/.localrc"
fi
