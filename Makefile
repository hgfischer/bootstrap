include /etc/os-release

NAME          := Herbert Fischer
EMAIL         := herbert.fischer@
KERNEL_VER    := $(shell uname -r)
DOWNLOADS_DIR := ~/Downloads/.bootstrap
GO_VER        := 1.9.3
VIMPLUGINS    := ~/.vim/pack/plugins/start
VAGRANT_VER   := 2.0.1
FRANZ_VER     := 5.0.0-beta.15
INTELLIJ_VER  := 2017.2.3
LSB_CODENAME  := $(shell lsb_release -s -c)
APT_UPDATE    := sudo apt update
APT_INSTALL   := sudo apt install -y


$(DOWNLOADS_DIR):
	mkdir -p $(DOWNLOADS_DIR)


bash:
	mkdir -p ~/.profile.d/
	cp files/bashrc ~/.bashrc
	cp files/profile.d/* ~/.profile.d/


monitor_wakeup_fix:
	cat files/30_wakemonitor | sudo tee /etc/pm/sleep.d/30_wakemonitor
	sudo chmod +x /etc/pm/sleep.d


docker:
	sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 \
		--recv-keys 58118E89F3A912897C070ADBF76221572C52609D
	echo deb https://apt.dockerproject.org/repo ubuntu-xenial main | \
		sudo tee /etc/apt/sources.list.d/docker.list
	$(APT_UPDATE)
	$(APT_INSTALL) linux-image-extra-$(shell uname -r) docker-engine



GO_TARBALL = go$(GO_VER).linux-amd64.tar.gz
golang: curl $(DOWNLOADS_DIR)
	curl https://storage.googleapis.com/golang/$(GO_TARBALL) -o $(DOWNLOADS_DIR)/$(GO_TARBALL)
	tar xvzf $(DOWNLOADS_DIR)/$(GO_TARBALL) -C $(DOWNLOADS_DIR)
	rm -rf ~/.go
	mv $(DOWNLOADS_DIR)/go ~/.go


git:
	$(APT_INSTALL) git
	git config --global user.name $(NAME)
	git config --global user.email $(EMAIL)
	git config --global push.default simple


vim:
	if [ "0$(LSB_CODENAME)" == "0xenial" ]; then \
		sudo add-apt-repository -y ppa:jonathonf/vim; \
		$(APT_UPDATE); \
	fi;
	sudo apt-get remove -y vim-tiny
	$(APT_INSTALL) vim-nox
	$(APT_INSTALL) vim-gtk


vim-plugins:
	cp files/vimrc ~/.vimrc
	mkdir -p $(VIMPLUGINS)
	cd $(VIMPLUGINS)                                                  && \
	git init                                                          && \
	git submodule init                                                && \
	git submodule add https://github.com/Shougo/neocomplete.vim.git   && \
	git submodule add https://github.com/airblade/vim-gitgutter.git   && \
	git submodule add https://github.com/bling/vim-airline.git        && \
	git submodule add https://github.com/dgryski/vim-godef.git        && \
	git submodule add https://github.com/elubow/cql-vim.git           && \
	git submodule add https://github.com/elzr/vim-json.git            && \
	git submodule add https://github.com/fatih/vim-go.git             && \
	git submodule add https://github.com/flazz/vim-colorschemes.git   && \
	git submodule add https://github.com/godlygeek/tabular.git        && \
	git submodule add https://github.com/jstemmer/gotags.git          && \
	git submodule add https://github.com/kien/ctrlp.vim.git           && \
	git submodule add https://github.com/klen/python-mode.git         && \
	git submodule add https://github.com/majutsushi/tagbar.git        && \
	git submodule add https://github.com/nanotech/jellybeans.vim.git  && \
	git submodule add https://github.com/oblitum/rainbow.git          && \
	git submodule add https://github.com/pangloss/vim-javascript.git  && \
	git submodule add https://github.com/saltstack/salt-vim.git       && \
	git submodule add https://github.com/scrooloose/nerdcommenter.git && \
	git submodule add https://github.com/scrooloose/syntastic.git     && \
	git submodule add https://github.com/tomasr/molokai.git           && \
	git submodule add https://github.com/tpope/vim-fugitive.git       && \
	git submodule add https://github.com/tpope/vim-ragtag.git         && \
	git submodule add https://github.com/tpope/vim-surround.git       && \
	git add -A                                                        && \
	git commit -m 'Installed...'


update-vim-plugins:
	cd $(VIMPLUGINS)                      && \
	git submodule update --remote --merge && \
	git add -A                            && \
	git commit -m 'Updated...'


chrome:
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | \
		sudo tee /etc/apt/sources.list.d/google-chrome.list
	echo "deb [arch=amd64] http://dl.google.com/linux/talkplugin/deb/ stable main" | \
		sudo tee /etc/apt/sources.list.d/google-talkplugin.list
	$(APT_UPDATE)
	$(APT_INSTALL) google-chrome-stable google-talkplugin


terminator:
	if [ "0$(LSB_CODENAME)" == "0xenial" ]; then \
		sudo add-apt-repository -y ppa:gnome-terminator/nightly-gtk3; \
		$(APT_UPDATE); \
	fi;
	$(APT_INSTALL) terminator


oracle-java:
	sudo add-apt-repository -y ppa:webupd8team/java
	$(APT_UPDATE)
	$(APT_INSTALL) oracle-java8-installer oracle-java8-set-default


java:
	$(APT_INSTALL) openjdk-9-jdk openjdk-9-doc


virtualbox: $(DOWNLOADS_DIR)
	echo "deb http://download.virtualbox.org/virtualbox/debian $(UBUNTU_CODENAME) contrib" | \
		sudo tee /etc/apt/sources.list.d/virtualbox.list
	wget -q -O - https://www.virtualbox.org/download/oracle_vbox_2016.asc | \
		sudo apt-key add -
	$(APT_UPDATE)
	$(APT_INSTALL) virtualbox-5.2
	cd $(DOWNLOADS_DIR)                                                                                                     && \
	wget -c http://download.virtualbox.org/virtualbox/5.2.6/Oracle_VM_VirtualBox_Extension_Pack-5.2.6-120293.vbox-extpack && \
	sudo vboxmanage extpack install --replace `ls -1 *.vbox-extpack`


VAGRANT_PKG = vagrant_$(VAGRANT_VER)_x86_64.deb
vagrant: $(DOWNLOADS_DIR)
	cd $(DOWNLOADS_DIR)                                                                         && \
	wget https://releases.hashicorp.com/vagrant/$(VAGRANT_VER)/$(VAGRANT_PKG) -O $(VAGRANT_PKG) && \
	sudo dpkg -i $(VAGRANT_PKG)


vscode: $(DOWNLOADS_DIR)
	cd $(DOWNLOADS_DIR)                                                                    && \
	wget https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable -O vscode.deb && \
	sudo dpkg -i vscode.deb


sublime3: $(DOWNLOADS_DIR)
	cd $(DOWNLOADS_DIR)                                                                          && \
	wget https://download.sublimetext.com/sublime-text_build-3126_amd64.deb -O sublime-text3.deb && \
	sudo dpkg -i sublime-text3.deb


franz:
	sudo apt-get install gconf2
	cd $(DOWNLOADS_DIR) && \
	wget https://github.com/meetfranz/franz/releases/download/v$(FRANZ_VER)/franz_$(FRANZ_VER)_amd64.deb \
		-O franz.deb && \
	sudo dpkg -i franz.deb


/usr/share/fonts/opentype/scp:
	sudo mkdir -p /usr/share/fonts/opentype
	sudo git clone https://github.com/adobe-fonts/source-code-pro.git \
		/usr/share/fonts/opentype/scp


/usr/share/fonts/opentype/FiraCode:
	cd /tmp && \
	git clone https://github.com/tonsky/FiraCode.git && \
	sudo mv FiraCode/distr/otf /usr/share/fonts/opentype/FiraCode


/usr/share/fonts/truetype/go-fonts:
	cd /tmp && rm -rf image && \
	git clone https://go.googlesource.com/image && \
	sudo mv image/font/gofont/ttfs /usr/share/fonts/truetype/go-fonts

/usr/share/fonts/truetype/YosemiteSanFrancisco:
	cd /tmp && rm -rf YosemiteSanFranciscoFont && \
	git clone https://github.com/supermarin/YosemiteSanFranciscoFont.git && \
	sudo mkdir /usr/share/fonts/truetype/YosemiteSanFranciscoFont && \
	sudo mv YosemiteSanFranciscoFont/*.ttf /usr/share/fonts/truetype/YosemiteSanFranciscoFont


fonts: /usr/share/fonts/opentype/scp /usr/share/fonts/opentype/FiraCode /usr/share/fonts/truetype/go-fonts /usr/share/fonts/truetype/YosemiteSanFrancisco
	sudo fc-cache -f -v
	$(APT_INSTALL) \
		fonts-inconsolata \
		fonts-fantasque-sans \
		fonts-jura \
		ttf-mscorefonts-installer


tmux-cssh:
	sudo wget https://raw.githubusercontent.com/dennishafemann/tmux-cssh/master/tmux-cssh -O /usr/local/bin/tmux-cssh
	sudo chmod +x /usr/local/bin/tmux-cssh


curl:
	$(APT_INSTALL) curl


misc:
	$(APT_INSTALL) \
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
		sqlite3 \
		powertop \
		sysfsutils \
		sysstat


INTELLIJ_TARBALL = ideaIC-$(INTELLIJ_VER).tar.gz
INTELLIJ_DIR = /opt/ideaIC
intellij: $(DOWNLOADS_DIR)
	wget -c https://download.jetbrains.com/idea/$(INTELLIJ_TARBALL) -O $(DOWNLOADS_DIR)/$(INTELLIJ_TARBALL)
	sudo rm -rf $(INTELLIJ_DIR) && sudo mkdir -p $(INTELLIJ_DIR)
	sudo tar xvzf $(DOWNLOADS_DIR)/$(INTELLIJ_TARBALL) --strip 1 -C $(INTELLIJ_DIR)
	cat files/IDEA.desktop | sudo tee /usr/share/applications/IDEA.desktop


i3:
	/usr/lib/apt/apt-helper download-file \
		http://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2017.01.02_all.deb \
		$(DOWNLOADS_DIR)/keyring.deb \
		SHA256:4c3c6685b1181d83efe3a479c5ae38a2a44e23add55e16a328b8c8560bf05e5f
	$(APT_INSTALL) $(DOWNLOADS_DIR)/keyring.deb 
	echo "deb http://debian.sur5r.net/i3/ $(LSB_CODENAME) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
	$(APT_UPDATE)  
	$(APT_INSTALL) i3 feh arandr lxappearance rofi compton


ansible:
	echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" | sudo tee /etc/apt/sources.list.d/ansible.list
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
	$(APT_UPDATE)
	$(APT_INSTALL) ansible


shutter:
	$(APT_INSTALL) shutter


handbrake:
	if [ "0$(LSB_CODENAME)" == "0xenial" ]; then \
		sudo add-apt-repository ppa:stebbins/handbrake-releases -y; \
		$(APT_UPDATE); \
	fi;
	$(APT_INSTALL) handbrake


ffmpeg:
	$(APT_INSTALL) ffmpeg


vlc:
	$(APT_INSTALL) vlc browser-plugin-vlc


mkvtoolnix:
	wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | sudo apt-key add -
	echo "deb http://mkvtoolnix.download/ubuntu/$(LSB_CODENAME)/ ./" | sudo tee /etc/apt/sources.list.d/bunkus.org.list
	$(APT_UPDATE)
	$(APT_INSTALL) mkvtoolnix mkvtoolnix-gui mediainfo-gui


nodejs:
	curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
	$(APT_INSTALL) nodejs


yarn:
	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
	$(APT_UPDATE)
	$(APT_INSTALL) yarn 


glances:
	$(APT_INSTALL) glances


clipit:
	$(APT_INSTALL) clipit


gimp:
	$(APT_INSTALL) gimp


gmic: gimp
	wget -c http://gmic.eu/files/prerelease_linux/gmic_ubuntu_$(LSB_CODENAME)_amd64.deb -O $(DOWNLOADS_DIR)/gmic.deb
	sudo apt-get install libopencv-videoio3.1 libqt5xml5 -y
	sudo dpkg -i $(DOWNLOADS_DIR)/gmic.deb


dolphin:
	sudo apt-add-repository -y ppa:dolphin-emu/ppa
	$(APT_UPDATE)
	$(APT_INSTALL) dolphin-emu 


topicons:
	$(APT_INSTALL) gnome-shell-extension-top-icons-plus


nmap:
	$(APT_INSTALL) nmap


opera:
	echo 'deb https://deb.opera.com/opera-stable/ stable non-free' | sudo tee /etc/apt/sources.list.d/opera-stable.list
	wget -qO- https://deb.opera.com/archive.key | sudo apt-key add -
	$(APT_UPDATE)
	$(APT_INSTALL) opera-stable


all: bash docker golang git vim chrome terminator java virtualbox vagrant vscode sublime3 franz fonts tmux-cssh curl misc intellij i3 ansible shutter monitor_wakeup_fix handbrake ffmpeg vlc mkvtoolnix nodejs yarn glances clipit gmic topicons nmap opera
