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
    mv "$file" "${file}.bak"
  done
}

backup_or_remove() {
  local destination="$1"

  if [ -e "$destination" ]; then
    if [ -L "$destination" ]; then
      cprint "Removing symlink: $destination"
      rm "$destination"
    else
      backup "$destination"
      # local backup_file="${destination}.bak"
      # cprint "Renaming $destination to $backup_file"
      # mv "$destination" "$backup_file"
    fi
  fi
}

copy_from_to() {
  local source="$1"
  local destination="$2"

  if [ ! -e "$source" ]; then
    cprint "File not found: $source"
    return 1
  fi

  # check if the destination file exists
  if [ -e "$destination" ]; then
    # check if the destination file is a symlink
    if [ -L "$destination" ]; then
      cprint "Removing symlink: $destination"
      rm "$destination"
    else
      # backup the destination file
      backup "$destination"
      # local backup_file="${destination}.bak"
      # cprint "Renaming $destination to $backup_file"
      # mv "$destination" "$backup_file"
    fi
  fi

  # check if the source file is a folder
  if [ -d "$source" ]; then
    cp -r "$source" "$destination"
  else
    cp "$source" "$destination"
  fi

  cprint "Copied $source to $destination"
  return 0
}


################################################################################
## INSTALL #####################################################################
################################################################################
cprint -p "Installing NixHyper Dotfiles.."
cprint "This will setup zsh, nvim, git, and alacritty"

# would you like to continue
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi


################################################################################
## ZSH #########################################################################
################################################################################
cprint -p "Installing ZSH Dotfiles.."

# run the common commands here
cprint "Old Files: backing up or removing symlinks.."
backup_or_remove "$HOME/.zshrc"
backup_or_remove "$HOME/.local/share/zsh"

cprint "Creating new directories.."
ln -s "$HOME/bin/nixhyper/zsh/zshrc" "$HOME/.zshrc"


################################################################################
## NEOVIM ######################################################################
################################################################################
cprint -p "Installing NVIM Dotfiles.."

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
cprint -p "Installing Git Dotfiles.."
cprint "Old Files: backing up or removing symlinks.."
backup_or_remove "$HOME/.gitconfig"

cprint "Creating new directories.."
ln -s "$HOME/bin/nixhyper/git/gitconfig" "$HOME/.gitconfig"


################################################################################
## ALACRITTY ###################################################################
################################################################################
cprint -p "Installing Alacritty Dotfiles.."

# run the common commands here
cprint "Old Files: backing up or removing symlinks.."
backup_or_remove "$HOME/.config/alacritty"

cprint "Creating new directories.."
mkdir -p "$HOME/.config"
ln -s "$HOME/bin/nixhyper/alacritty" "$HOME/.config/alacritty"
