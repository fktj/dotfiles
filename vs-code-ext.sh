#!/bin/bash

# URL of the extensions list
EXTENSIONS_URL="https://raw.githubusercontent.com/fktj/dotfiles/main/vscode-extensions-list.txt"

# Check if Visual Studio Code command 'code' is available
if ! command -v code &> /dev/null
then
    echo "Visual Studio Code command 'code' could not be found"
    exit 1
fi

# Check if curl is available
if ! command -v curl &> /dev/null
then
    echo "curl could not be found"
    exit 1
fi

# Fetch the list of extensions and install each one
echo "Fetching list of extensions from $EXTENSIONS_URL"
curl -sS $EXTENSIONS_URL | while IFS= read -r extension
do
    # Install each extension
    if [ ! -z "$extension" ]; then # Check if the line is not empty
        echo "Installing $extension..."
        code --install-extension "$extension"
    fi
done

echo "All extensions have been installed."
