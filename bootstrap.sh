#!/bin/bash

DOWNLOADS=~/Downloads/.bootstrap
mkdir -p $DOWNLOADS

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
	git config --global push.default simple
fi


info "Setting up package repositories"
sudo add-apt-repository -y ppa:gnome-terminator/nightly-gtk3
sudo add-apt-repository -y ppa:pi-rho/dev
echo "deb http://download.virtualbox.org/virtualbox/debian $UBUNTU_CODENAME contrib" | \
	sudo tee /etc/apt/sources.list.d/virtualbox.list
wget -q -O - https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo apt-key add -
sudo add-apt-repository -y ppa:webupd8team/java
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | \
	sudo tee /etc/apt/sources.list.d/google-chrome.list
echo "deb [arch=amd64] http://dl.google.com/linux/talkplugin/deb/ stable main" | \
	sudo tee /etc/apt/sources.list.d/google-talkplugin.list
sudo add-apt-repository -y ppa:niko2040/e19
sudo apt-get update


info "Installing vim"
sudo apt-get remove -y vim-tiny
sudo apt-get install -y vim-nox
sudo apt-get install -y vim-gtk

info "Installing Google Chrome"
sudo apt-get install -y google-chrome-stable

info "Installing Google Talk Plugin"
sudo apt-get install -y google-talkplugin

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
pushd ${DOWNLOADS}
wget -c http://download.virtualbox.org/virtualbox/5.1.12/Oracle_VM_VirtualBox_Extension_Pack-5.1.12-112440.vbox-extpack
vboxmanage extpack install --replace `ls -1 *.vbox-extpack`
popd

info "Installing Vagrant"
VAGRANT_VER=1.9.1
VAGRANT_PKG=vagrant_${VAGRANT_VER}_x86_64.deb
curl -C - https://releases.hashicorp.com/vagrant/${VAGRANT_VER}/${VAGRANT_PKG} \
	-o ${DOWNLOADS}/${VAGRANT_PKG}
sudo dpkg -i ${DOWNLOADS}/${VAGRANT_PKG}

info "Installing Java8"
sudo apt-get -y install oracle-java8-installer oracle-java8-set-default

info "Installing Visual Studio Code"
if [ ! -f ${DOWNLOADS}/vscode.deb ]; then
	curl -C - -L https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable \
		-o ${DOWNLOADS}/vscode.deb
	sudo dpkg -i ${DOWNLOADS}/vscode.deb
fi

info "Installing Sublime Text 3"
if [ ! -f ${DOWNLOADS}/sublime-text3.deb ]; then
	curl -C - -L https://download.sublimetext.com/sublime-text_build-3126_amd64.deb \
		-o ${DOWNLOADS}/sublime-text3.deb
	sudo dpkg -i ${DOWNLOADS}/sublime-text3.deb
fi

info "Installing Franz"
FRANZ_VER=4.0.4
if [ ! -f ${DOWNLOADS}/franz.tgz ]; then
	curl -C - -L \
		https://github.com/meetfranz/franz-app/releases/download/${FRANZ_VER}/Franz-linux-x64-${FRANZ_VER}.tgz \
		-o ${DOWNLOADS}/franz.tgz
fi
sudo mkdir /opt/Franz
sudo tar xvzf ${DOWNLOADS}/franz.tgz -C /opt/Franz
cat files/Franz.desktop | sudo tee /usr/share/applications/Franz.desktop

info "Installing Android Tools"
sudo apt-get install -y adb fastboot

info "Installing hexadecimal editors"
sudo apt-get install -y bless ghex dhex

info "Installing ack-grep"
sudo apt-get install -y ack-grep

info "Installing sqlite3"
sudo apt-get install -y sqlite3

info "Installing some fonts"
sudo apt-get install -y fonts-inconsolata fonts-fantasque-sans fonts-jura ttf-mscorefonts-installer

[ -d /usr/share/fonts/opentype ] || sudo mkdir /usr/share/fonts/opentype
sudo git clone https://github.com/adobe-fonts/source-code-pro.git /usr/share/fonts/opentype/scp
sudo fc-cache -f -v

info "Installing jd-gui"
if [ ! -f ${DOWNLOADS}/jd-gui.deb ]; then
	curl -C - -L https://github.com/java-decompiler/jd-gui/releases/download/v1.4.0/jd-gui_1.4.0-0_all.deb \
		-o ${DOWNLOADS}/jd-gui.deb
	sudo dpkg -i ${DOWNLOADS}/jd-gui.deb
fi

info "Installing power management stuff"
sudo apt-get install -y powertop

info "Installing sysfs utils"
sudo apt-get install -y sysfsutils

info "Installing deps for gnome panels" 
sudo apt-get install -y gir1.2-gtop-2.0 vnstat vnstati

info "Installing tool for gnome-open" 
sudo apt-get install -y libgnome2-bin

info "Installing sysstat"
sudo apt-get install -y sysstat

info "Cleaning up"
sudo apt-get autoremove -y

info "Adding tmux-cssh"
sudo wget https://raw.githubusercontent.com/dennishafemann/tmux-cssh/master/tmux-cssh -O /usr/local/bin/tmux-cssh
sudo chmod +x /usr/local/bin/tmux-cssh
