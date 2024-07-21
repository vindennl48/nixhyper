#!/usr/bin/env bash

################################################################################
## HELPERS #####################################################################
################################################################################
cprint() {
  local leader="     "  # Default leader

  # Process flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p)
        leader="---->"
        shift
        ;;
      --)
        shift
        break
        ;;
      -*)
        echo "Unknown option: $1" >&2
        return 1
        ;;
      *)
        break
        ;;
    esac
  done

  # Print the leader followed by the remaining arguments
  echo "$leader" "$@"
}

backup() {
  # for all files listed as arguments
  for file in "$@"; do
    # rename the file with .bak
    sudo mv "$file" "${file}.bak"
  done
}

backup_or_remove() {
  local destination="$1"

  if [ -e "$destination" ]; then
    if [ -L "$destination" ]; then
      cprint "Removing symlink: $destination"
      sudo rm "$destination"
    else
      backup "$destination"
      # local backup_file="${destination}.bak"
      # cprint "Renaming $destination to $backup_file"
      # mv "$destination" "$backup_file"
    fi
  fi
}


################################################################################
## INSTALL #####################################################################
################################################################################
cprint -p "Installing NixHyper and Dotfiles.."
cprint "This will setup NixOS, looking-glass, zsh, nvim, git, and alacritty"

# would you like to continue
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi


################################################################################
## NIXOS #######################################################################
################################################################################
cprint -p "Setting Up NixOS"

# run the common commands here
cprint "Old Files: backing up or removing symlinks.."
backup_or_remove "/etc/nixos"

cprint "Creating new directories.."
ln -s "$HOME/bin/nixhyper/nixos" "/etc/nixos"


################################################################################
## LOOKING-GLASS ###############################################################
################################################################################
cprint -p "Setting Up Looking-Glass Dotfiles.."

# run the common commands here
cprint "Old Files: backing up or removing symlinks.."
backup_or_remove "$HOME/.config/looking-glass/client.ini"

cprint "Creating new directories.."
mkdir -p "$HOME/.config/looking-glass"
ln -s "$HOME/bin/nixhyper/looking-glass/client.ini" "$HOME/.config/looking-glass/client.ini"


################################################################################
## ZSH #########################################################################
################################################################################
cprint -p "Setting Up ZSH Dotfiles.."

# run the common commands here
cprint "Old Files: backing up or removing symlinks.."
backup_or_remove "$HOME/.zshrc"
backup_or_remove "$HOME/.local/share/zsh"

cprint "Creating new directories.."
ln -s "$HOME/bin/nixhyper/zsh/zshrc" "$HOME/.zshrc"


################################################################################
## NEOVIM ######################################################################
################################################################################
cprint -p "Setting Up NVIM Dotfiles.."

# run the common commands here
cprint "Old Files: backing up or removing symlinks.."
backup_or_remove "$HOME/.config/nvim"
backup_or_remove "$HOME/.local/share/nvim"

cprint "Creating new directories.."
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share/nvim/plugins"
ln -s "$HOME/bin/nixhyper/nvim" "$HOME/.config/nvim"

cprint "Installing vim-plug.."
git clone https://github.com/junegunn/vim-plug.git "$HOME/.local/share/nvim/plugins/vim-plug"


################################################################################
## GIT #########################################################################
################################################################################
cprint -p "Setting Up Git Dotfiles.."
cprint "Old Files: backing up or removing symlinks.."
backup_or_remove "$HOME/.gitconfig"

cprint "Creating new directories.."
ln -s "$HOME/bin/nixhyper/git/gitconfig" "$HOME/.gitconfig"


################################################################################
## ALACRITTY ###################################################################
################################################################################
cprint -p "Setting Up Alacritty Dotfiles.."

# run the common commands here
cprint "Old Files: backing up or removing symlinks.."
backup_or_remove "$HOME/.config/alacritty"

cprint "Creating new directories.."
mkdir -p "$HOME/.config"
ln -s "$HOME/bin/nixhyper/alacritty" "$HOME/.config/alacritty"

################################################################################
################################################################################

cprint -p "Done setting up dotfiles! Please rebuild and reboot."

