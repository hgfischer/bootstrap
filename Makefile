include /etc/os-release

NAME          := Herbert Fischer
EMAIL         := herbert.fischer@
KERNEL_VER    := $(shell uname -r)
DOWNLOADS_DIR := ~/Downloads/.bootstrap
GO_VER        := 1.8
VIMPLUGINS    := ~/.vim/pack/plugins/start
VAGRANT_VER   := 1.9.3
FRANZ_VER     := 4.0.4


$(DOWNLOADS_DIR):
	mkdir -p $(DOWNLOADS_DIR)


bash:
	mkdir -p ~/.profile.d/
	cp files/bashrc ~/.bashrc_TODO
	cp files/profile.d/* ~/.profile.d/


docker:
	sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 \
		--recv-keys 58118E89F3A912897C070ADBF76221572C52609D
	echo deb https://apt.dockerproject.org/repo ubuntu-xenial main | \
		sudo tee /etc/apt/sources.list.d/docker.list
	sudo apt-get update
	sudo apt-get install -y linux-image-extra-$(shell uname -r)
	sudo apt-get install -y docker-engine



GO_TARBALL = go$(GO_VER).linux-amd64.tar.gz
golang: curl $(DOWNLOADS_DIR)
	curl https://storage.googleapis.com/golang/${GO_TARBALL} -o $(DOWNLOADS_DIR)/$(GO_TARBALL)
	tar xvzf $(DOWNLOADS_DIR)/$(GO_TARBALL) -C $(DOWNLOADS_DIR)
	rm -rf ~/.go
	mv $(DOWNLOADS_DIR)/go ~/.go


git:
	sudo apt-get install -y git
	git config --global user.name $(NAME)
	git config --global user.email $(EMAIL)
	git config --global push.default simple


vim:
	sudo add-apt-repository -y ppa:jonathonf/vim
	sudo apt-get update
	sudo apt-get remove -y vim-tiny
	sudo apt-get install -y vim-nox
	sudo apt-get install -y vim-gtk


vim-plugins:
	cp files/vimrc ~/.vimrc
	mkdir -p $(VIMPLUGINS)
	cd $(VIMPLUGINS) && \
	git init && \
	git submodule init && \
	git submodule add https://github.com/Shougo/neocomplete.vim.git && \
	git submodule add https://github.com/airblade/vim-gitgutter.git && \
	git submodule add https://github.com/bling/vim-airline.git && \
	git submodule add https://github.com/dgryski/vim-godef.git && \
	git submodule add https://github.com/elubow/cql-vim.git && \
	git submodule add https://github.com/elzr/vim-json.git && \
	git submodule add https://github.com/fatih/vim-go.git && \
	git submodule add https://github.com/flazz/vim-colorschemes.git && \
	git submodule add https://github.com/godlygeek/tabular.git && \
	git submodule add https://github.com/jstemmer/gotags.git && \
	git submodule add https://github.com/kien/ctrlp.vim.git && \
	git submodule add https://github.com/klen/python-mode.git && \
	git submodule add https://github.com/majutsushi/tagbar.git && \
	git submodule add https://github.com/nanotech/jellybeans.vim.git && \
	git submodule add https://github.com/oblitum/rainbow.git && \
	git submodule add https://github.com/pangloss/vim-javascript.git && \
	git submodule add https://github.com/saltstack/salt-vim.git && \
	git submodule add https://github.com/scrooloose/nerdcommenter.git && \
	git submodule add https://github.com/scrooloose/syntastic.git && \
	git submodule add https://github.com/tomasr/molokai.git && \
	git submodule add https://github.com/tpope/vim-fugitive.git && \
	git submodule add https://github.com/tpope/vim-ragtag.git && \
	git submodule add https://github.com/tpope/vim-surround.git && \
	git add -A && \
	git commit -m 'Installed...'


update-vim-plugins:
	cd $(VIMPLUGINS) && \
	git submodule update --remote --merge \
	git add -A \
	git commit -m 'Updated...'


chrome:
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | \
		sudo tee /etc/apt/sources.list.d/google-chrome.list
	echo "deb [arch=amd64] http://dl.google.com/linux/talkplugin/deb/ stable main" | \
		sudo tee /etc/apt/sources.list.d/google-talkplugin.list
	sudo apt-get update
	sudo apt-get install -y google-chrome-stable google-talkplugin


terminator:
	sudo add-apt-repository -y ppa:gnome-terminator/nightly-gtk3
	sudo apt-get update
	sudo apt-get install -y terminator


java:
	sudo add-apt-repository -y ppa:webupd8team/java
	sudo apt-get update
	sudo apt-get -y install oracle-java8-installer oracle-java8-set-default


virtualbox: $(DOWNLOADS_DIR)
	echo "deb http://download.virtualbox.org/virtualbox/debian $(UBUNTU_CODENAME) contrib" | \
		sudo tee /etc/apt/sources.list.d/virtualbox.list
	wget -q -O - https://www.virtualbox.org/download/oracle_vbox_2016.asc | \
		sudo apt-key add -
	sudo apt-get update
	sudo apt-get install -y virtualbox-5.1
	cd $(DOWNLOADS_DIR) && \
	wget -c http://download.virtualbox.org/virtualbox/5.1.18/Oracle_VM_VirtualBox_Extension_Pack-5.1.18-114002.vbox-extpack && \
	sudo vboxmanage extpack install --replace `ls -1 *.vbox-extpack`


VAGRANT_PKG = vagrant_${VAGRANT_VER}_x86_64.deb
vagrant: $(DOWNLOADS_DIR)
	cd $(DOWNLOADS_DIR) && \
	wget https://releases.hashicorp.com/vagrant/${VAGRANT_VER}/${VAGRANT_PKG} \
		-O ${VAGRANT_PKG} && \
	sudo dpkg -i ${VAGRANT_PKG}


vscode: $(DOWNLOADS_DIR)
	cd $(DOWNLOADS_DIR) && \
	wget https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable \
		-O vscode.deb && \
	sudo dpkg -i vscode.deb


sublime3: $(DOWNLOADS_DIR)
	cd $(DOWNLOADS_DIR) && \
	wget https://download.sublimetext.com/sublime-text_build-3126_amd64.deb \
		-O sublime-text3.deb && \
	sudo dpkg -i sublime-text3.deb


franz:
	cd $(DOWNLOADS_DIR) && \
	wget https://github.com/meetfranz/franz-app/releases/download/${FRANZ_VER}/Franz-linux-x64-${FRANZ_VER}.tgz \
		-O franz.tgz && \
	sudo mkdir -p /opt/Franz && \
	sudo tar xvzf franz.tgz -C /opt/Franz
	cat files/Franz.desktop | sudo tee /usr/share/applications/Franz.desktop


/usr/share/fonts/opentype/scp:
	sudo mkdir -p /usr/share/fonts/opentype
	sudo git clone https://github.com/adobe-fonts/source-code-pro.git \
		/usr/share/fonts/opentype/scp


/usr/share/fonts/opentype/FiraCode:
	cd /tmp && \
	git clone https://github.com/tonsky/FiraCode.git && \
	sudo mv FiraCode/distr/otf /usr/share/fonts/opentype/FiraCode


fonts: /usr/share/fonts/opentype/scp /usr/share/fonts/opentype/FiraCode
	sudo fc-cache -f -v
	sudo apt-get install -y \
		fonts-inconsolata \
		fonts-fantasque-sans \
		fonts-jura \
		ttf-mscorefonts-installer


themes:
	sudo add-apt-repository -y ppa:numix/ppa
	sudo add-apt-repository -y ppa:noobslab/themes
	sudo add-apt-repository -y ppa:noobslab/icons
	sudo apt-get update
	sudo apt-get install -y \
		unity-tweak-tool \
		numix-icon-theme-circle \
		arc-theme \
		arc-icons


tmux-cssh:
	sudo wget https://raw.githubusercontent.com/dennishafemann/tmux-cssh/master/tmux-cssh -O /usr/local/bin/tmux-cssh
	sudo chmod +x /usr/local/bin/tmux-cssh


curl:
	sudo apt-get install -y curl


misc:
	sudo apt-get install -y \
		python-software-properties \
		build-essential \
		exuberant-ctags \
		htop \
		tree \
		tmux \
		xclip \
		adb \
		fastboot \
		bless \
		ghex \
		dhex \
		ack-grep \
		sqlite3 \
		powertop \
		sysfsutils \
		sysstat
