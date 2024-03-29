#!/bin/bash
if [[ ! -f .fl ]]
then
	cat <<-GREETINGS
	Welcome to the configuration script for your virtual (or not) machine
	Before the script starts and you are ready to use the VM one warning
	RTFM! Often the question your asking has been forecasted by the ones
	who developped the tool you're now using and more often than not the
	answer is in the doc.
	Don't forget to upgrade your system to the latest version too
	If zsh is not your login shell after running the script
	run : "chsh -s \$(which zsh)"
	You can also add the plugin "colored-man-pages" to your .zshrc
	(should be around line 73)
	Write an email to nsainton@student.42.fr in case of trouble.
	Now I wish you the best programming experience
	GREETINGS
	touch .fl
	exit
fi
if [ "$2" == "" ]
then
	echo "Please enter your username and your email for git config"
	echo "Use the script as follows : ./path_to_script username email"
	exit 3
fi

configuration="
apt -y update
apt -y upgrade
apt -y install apt-file
apt -y install curl
apt -y install pip
apt -y install zsh
apt -y install vim
apt -y install npm
apt -y install valgrind
apt -y install bat
apt -y autoremove
apt -y install libreadline6-dev
apt -y install libx11-dev
apt -y install libxext-dev
apt -y install libbsd-dev
apt -y install xclip
apt -y install python3.10-venv
apt -y install emacs
"
#The clang lines allows to install clang compiler and scan-build static llvm analyser
#They seem to make the script buggy but feel free to install them by yourself
#apt -y install clang
#apt -y install clang-tools
#These lines seems to make the configuration script buggy
if [ ! "$(sudo -s -- <<<"$configuration")" ]
then
	echo unknown error, might be due to interaction
	exit 3
fi
lbin="$HOME/.local/bin"
ubin="/usr/bin"
mkdir -p "$lbin"
ln -s "$ubin"/batcat "$lbin"/bat
if [ -d "$HOME"/.oh-my-zsh ]
then
	echo "ZSH already exists"
	omz_switch="off"
else
	yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	omz_switch="on"
fi
git config --global init.defaultBranch main
git config --global user.email "$2"
git config --global user.name "$1"
git config --global core.editor "vim"
python3 -m pip install --upgrade pip setuptools
python3 -m pip install norminette
if [ $omz_switch == "on" ]
then
	echo $omz_switch
	cat <<-ALIASES >> "$HOME"/.zshrc
		alias wgcc="gcc -Wall -Wextra -Werror"
		alias wclang="clang -Wall -Wextra -Werror"
		alias norme="norminette -RCheckForbiddenSourceHeader"
	ALIASES
	echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME"/.zshrc
fi
cat <<VIMCONFIG > "$HOME"/.vimrc
filetype on
set autoindent
set tabstop=4
let g:user42 = '$1'
let g:mail42 = '$2'
set number
colorscheme darkblue
VIMCONFIG

plugins_folder="$HOME/.vim/plugin"
stdheader="stdheader.vim"
if [ ! -f "$plugins_folder"/stdheader.vim ]
then
	mkdir -p "$plugins_folder"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/42Paris/42header/master/plugin/stdheader.vim -o "$plugins_folder"/"$stdheader")"\
	&& echo $stdheader installed || echo Unknown error
fi
