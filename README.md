# dotfiles
My dotfiles

![Figure](https://github.com/fktj/dotfiles/blob/be691c4fa8a0108d875ffc71e1a09d0ddf92a619/explanation.png)


## Usage

To get this config without any modification:

```shell
source <(curl -fsSL https://raw.githubusercontent.com/fktj/dotfiles/main/setup.sh)
```

⚠️ Warning, this will irrevocably replace your config with mine, and install a bunch of stuff on your system.

The installation script is idempotent, so to update your config to the latest version, simply re-run the command above, or use the alias that was defined the first time you ran the installation script:

```shell
updot
```

Any system-specific config should be placed in ~/.localrc. Don't edit ~/.bashrc or ~/.zshrc locally, these will be overwritten when updating as described above.
