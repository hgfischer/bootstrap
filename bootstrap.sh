#!/bin/bash

DOWNLOADS=~/Downloads

source /etc/os-release

notice() {
	echo -n "$(tput bold)$(tput smul)$(tput setaf 7)$(tput setab 4)"
	echo -n " $(echo "$@" | tr [a-z] [A-Z]) "
	echo "$(tput sgr0)$(tput bel)"
}

ask() {
	echo -n "$(tput bold)$(tput setaf 6)$(tput setab 0)"
	echo -n "$@"
	echo -n "$(tput sgr0) "
}

info() {
	echo -n "$(tput bold)$(tput setaf 2)$(tput setab 0)"
	echo -n "$@"
	echo "$(tput sgr0)"
}

warn() {
	echo -n "$(tput bold)$(tput setaf 0)$(tput setab 2)"
	echo -n "$@"
	echo -n "$(tput sgr0)"
}

error() {
	echo -n "$(tput bold)$(tput setaf 7)$(tput setab 1)"
	echo -n "$@"
	echo -n "$(tput sgr0)"
}


if [ ! -f ~/.gitconfig ]; then
	info "Setting-up git"
	notice "Input the following data according to the machine you are bootstrapping!"
	ask "E-mail:"
	read email
	ask "Full name:"
	read -e name
	echo
	sudo apt-get install -y git
	git config --global user.name $name
	git config --global user.email $email
fi


info "Setting up package repositories"
sudo add-apt-repository -y ppa:gnome-terminator/nightly-gtk3
sudo add-apt-repository -y ppa:pi-rho/dev
echo "deb http://download.virtualbox.org/virtualbox/debian $UBUNTU_CODENAME contrib" | \
	sudo tee /etc/apt/sources.list.d/virtualbox.list
wget -q -O - https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo apt-key add -
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update


info "Installing vim"
sudo apt-get remove -y vim-tiny
sudo apt-get install -y vim-nox
sudo apt-get install -y vim-gtk

info "Installing terminator"
sudo apt-get install -y terminator

info "Installing curl"
sudo apt-get install -y curl

info "Installing python software properties"
sudo apt-get install -y python-software-properties

info "Installing build-essential"
sudo apt-get install -y build-essential

info "Installing ctags"
sudo apt-get install -y exuberant-ctags

info "Installing htop"
sudo apt-get install -y htop

info "Installing tree"
sudo apt-get install -y tree

info "Installing tmux"
sudo apt-get install -y tmux

info "Installing xclip"
sudo apt-get install -y xclip

if [ ! -d ~/.go ]; then
	info "Installing golang"
	GOVERSION=1.8beta2
	TARBALL="go${GOVERSION}.linux-amd64.tar.gz"
	curl https://storage.googleapis.com/golang/${TARBALL} -o ${DOWNLOADS}/${TARBALL}
	tar xvzf ${DOWNLOADS}/${TARBALL} -C ${DOWNLOADS}
	mv ${DOWNLOADS}/go ~/.go
fi

info "Configuring vim"
cp files/vimrc ~/.vimrc
VIMPLUGINS=~/.vim/pack/plugins/start
if [ ! -d $VIMPLUGINS ]; then
	mkdir -p $VIMPLUGINS
	pushd $VIMPLUGINS
	git init
	git submodule init
	git submodule add https://github.com/Shougo/neocomplete.vim.git
	git submodule add https://github.com/airblade/vim-gitgutter.git
	git submodule add https://github.com/bling/vim-airline.git
	git submodule add https://github.com/dgryski/vim-godef.git
	git submodule add https://github.com/elubow/cql-vim.git
	git submodule add https://github.com/elzr/vim-json.git
	git submodule add https://github.com/fatih/vim-go.git
	git submodule add https://github.com/flazz/vim-colorschemes.git
	git submodule add https://github.com/godlygeek/tabular.git
	git submodule add https://github.com/jstemmer/gotags.git
	git submodule add https://github.com/kien/ctrlp.vim.git
	git submodule add https://github.com/klen/python-mode.git
	git submodule add https://github.com/majutsushi/tagbar.git
	git submodule add https://github.com/nanotech/jellybeans.vim.git
	git submodule add https://github.com/oblitum/rainbow.git
	git submodule add https://github.com/pangloss/vim-javascript.git
	git submodule add https://github.com/saltstack/salt-vim.git
	git submodule add https://github.com/scrooloose/nerdcommenter.git
	git submodule add https://github.com/scrooloose/syntastic.git
	git submodule add https://github.com/tomasr/molokai.git
	git submodule add https://github.com/tpope/vim-fugitive.git
	git submodule add https://github.com/tpope/vim-ragtag.git
	git submodule add https://github.com/tpope/vim-surround.git
	git add -A
	git commit -m 'Installed...'
	popd
else
	pushd $VIMPLUGINS
	git submodule update --remote --merge
	git add -A
	git commit -m 'Updated...'
	popd
fi

info "Configuring bash"
mkdir -p ~/.profile.d/
cp files/bashrc ~/.bashrc
cp files/profile.d/* ~/.profile.d/

info "Installing VirtualBox"
sudo apt-get install -y virtualbox-5.1

info "Installing Vagrant"
VAGRANT_VERSION=1.9.1
VAGRANT_PKG=vagrant_${VAGRANT_VERSION}_x86_64.deb
curl https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/${VAGRANT_PKG} \
	-o ${DOWNLOADS}/${VAGRANT_PKG}
sudo dpkg -I ${VAGRANT_PKG}

info "Installing Java8"
sudo apt-get -y install oracle-java8-installer oracle-java8-set-default

info "Installing Visual Studio Code"
curl -L https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable \
	-o ${DOWNLOADS}/vscode.deb
sudo dpkg -I ${DOWNLOADS}/vscode.deb
