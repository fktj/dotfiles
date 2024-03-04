# Setup and install



## Setup

To get quickly up and running run these commands on a fresh install

```shell
curl -o setup.sh https://raw.githubusercontent.com/fktj/dotfiles/main/setup.sh
```

```shell
chmod u+x setup.sh
```

```shell
sudo ./setup.sh
```



# Install 
Provides a better shell user experience

![Figure](https://github.com/fktj/dotfiles/blob/be691c4fa8a0108d875ffc71e1a09d0ddf92a619/explanation.png)

```shell
source <(curl -fsSL https://raw.githubusercontent.com/fjtk/dotfiles/main/install.sh)
```

⚠️ Warning, this will irrevocably replace your config with mine, and install a bunch of stuff on your system.

The installation script is idempotent, so to update your config to the latest version, simply re-run the command above, or use the alias that was defined the first time you ran the installation script:

```shell
updot
```

Any system-specific config should be placed in ~/.localrc. Don't edit ~/.bashrc or ~/.zshrc locally, these will be overwritten when updating as described above.
