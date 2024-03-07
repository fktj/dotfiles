# Setup and install



## Setup

To get quickly up and running run these commands on a fresh install

```shell
curl -o setup.sh https://raw.githubusercontent.com/fktj/dotfiles/main/setup.sh && \
curl -o install.sh https://raw.githubusercontent.com/fktj/dotfiles/main/install.sh
```

```shell
chmod u+x setup.sh && chmod u+x install.sh
```

```shell
sudo ./setup.sh
```
You will be asked to install the packages defined in setup. 
And then once agian if you want to set up global git configuration.


# Install 
Provides a better shell user experience

![Figure](https://github.com/fktj/dotfiles/blob/be691c4fa8a0108d875ffc71e1a09d0ddf92a619/explanation.png)

```shell
./install.sh
```

⚠️ Warning, this will irrevocably replace your config with mine, and install a bunch of stuff on your system.

The installation script is idempotent, so to update your config to the latest version, simply re-run the command above, or use the alias that was defined the first time you ran the installation script:

```shell
updot
```

Any system-specific config should be placed in ~/.localrc. Don't edit ~/.bashrc or ~/.zshrc locally, these will be overwritten when updating as described above.

```shell
rm -f ~/.bashrc
```

```shell
ln -s ~/.dotfiles/.bashrc ~/.bashrc
```

```shell
source ~/.config/envman/PATH.env
```

```shell
source .dotfiles/.commonrc
```

```shell
source .dotfiles/.bashrc
```

```shell
cat ./.bashrc
```

```shell
cat setuplog.txt
```

```shell
cat setuplog.txt
```
Install poetry
```shell
curl -sSL https://install.python-poetry.org | python3 -
```

```shell
poetry --version
```
Navigate to project
```shell
poetry shell
```

```shell
poetry install
```

You can use this to install the extensions for vs code ( you might have to run it from within the vs code terminal)
```shell
curl -o vscode-extensions-list.txt https://raw.githubusercontent.com/fktj/dotfiles/main/vscode-extensions-list.txt
cat vscode-extensions-list.txt | xargs -L 1 code --install-extension
```

Configure you path for poetry and make sure test_setup.py works without

When you have got your poetry environment setup check that setup_test.py is working correctly

#### Setup databricks connect
In order to make this work you have to authenticate with azure
```Shell
az login
```

```Shell
databricks configure
```

Insert the hostname to the databricks development environment and your PAT

```Shell
databricks tokens list
```
! you should now see your token

Navigate to the project and open vscode

```Shell
code .
```

Configure databricks connect
- Click on the databricks vs code extension
- Click on `Configure`
- Choose `Azure CLI`

  Once configured you can run the file test_databricks.py to verify that it works as expected.
  It will give you the 5 first rows of new york taxt sample data. 
