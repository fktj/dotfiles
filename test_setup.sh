echo "Please enter your email:"
read user_email
echo "Please enter your username:"
read user_name
echo $user_email
echo $user_name

sudo apt update -y && \
sudo apt upgrade -y && \
sudo apt autoremove -y

# Install basic packages
echo "Do you want to setup basics? (yes/no)"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
    echo "Installing basic packages"
    sudo apt install unzip -y && \
    sudo apt install zsh -y && \
    sudo apt install gh -y && \
    curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sudo sh
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
fi

# Install azure-cli
echo "Do you want to setup azure cli? (yes/no)"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
    echo "Installing azure-cli"
    sudo apt install ca-certificates curl apt-transport-https lsb-release gnupg -y
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
    AZ_REPO=$(lsb_release -cs)
    # might be an issue here
    echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
    sudo apt update
    sudo apt install azure-cli -y
    az_version=$(az --version)
    echo $az_version
    sleep 3
fi


# Install git credential manager
echo "Do you want to setup git credential manager? (yes/no)"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
    echo "Installing git credential manager"
    sudo dpkg --print-architecture
    wget "https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.4.1/gcm-linux_amd64.2.4.1.deb" -O /tmp/gcmcore.deb
    sudo dpkg -i /tmp/gcmcore.deb
    git_cred_manager_version=$(git-credential-manager --version)
    echo "Git Credential Manager: $git_cred_manager_version"
    echo "You need to run the manually and setup the credential manager with command:"
    echo "git-credential-manager configure"
    sleep 3
fi


# Install gpg and ssh and set global git config
echo "Do you want to setup gpg and ssh and set global git config? (yes/no)"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then

    # Set git global config 
    git config --global user.email $user_email
    git config --global user.name $user_name

    # Install gpg
    gpg_version_full=$(gpg --version)
    gpg_version=$(echo "$gpg_version_full" | head -n 1 | awk '{print $3}')

    if [[ $(echo -e "2.1.17\n$gpg_version" | sort -V | head -n1) == "2.1.17" ]]; then
        echo "GPG version is equal to or above 2.1.17"
        gpg --full-generate-key
        output=$(gpg --list-secret-keys --keyid-format=long)
        key_id=$(echo "$output" | awk '/sec/{print $2}' | cut -d'/' -f2)
        gpg --armor --export key_id
    else
        echo "GPG version is below 2.1.17"
        echo "See: https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key?platform=linux"
    fi
    sleep 3
    # Install ssh
    if ! command -v ssh-keygen &> /dev/null
    then
        echo "ssh-keygen could not be found"
    else
        echo "ssh-keygen is installed"
        ssh-keygen -t rsa -b 4096 -C $user_email
        eval "$(ssh-agent -s)"
        gh ssh-key add ~/.ssh/id_rsa.pub --title signing
        echo "You need to add the ssh key to your github account"
        gh auth login
    fi
    
fi


# Install oh-my-zsh
echo "Do you want to setup oh-my-zsh? (yes/no)"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
    echo "Installing oh-my-zsh (choose 2 and it will be setup quickly)"
    sleep 3
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "Oh-my-zsh installation completed. Returning to setup script..."
    chsh -s /bin/bash $user_name
    sleep 3
    echo "Installing plugins"
    sudo apt install fzf -y && \
    sudo apt install zsh-autosuggestions -y

fi


# Install starship
echo "Do you want to setup starship? (yes/no)"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then


    echo "Getting fira code font"
    mkdir -p ~/.local/share/fonts/
    for type in Bold Light Medium Regular Retina; do wget -nc -O ~/.local/share/fonts//FiraCode-$type.ttf "https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/FiraCode/$type/complete/Fira%20Code%20$type%20Nerd%20Font%20Complete.ttf?raw=true"; done
    fc-cache -f ~/.local/share/fonts/
    ;;
    
    echo "Installing starship"
    # Ensure Starship is installed and up to date.
    mkdir -p ~/.local/bin
    RUNZSH=no sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --force --bin-dir ~/.local/bin
    export PATH="~/.local/bin:$PATH"
    echo "Starship installation completed. Returning to setup script..."

fi


# Install python3 and pip
echo "Do you want to setup python, pip and poetry? (yes/no)"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
    echo "Installing python3 and pip"
    sudo apt install python3-pip -y && \
    sudo apt install pipx
    pipx ensurepath
    pipx --version
    sleep 3
    pipx install poetry
    pipx upgrade poetry
    poetry --version
    sleep 3
fi