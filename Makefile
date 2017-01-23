KERNEL_VER := $(shell uname -r)
DOWNLOADS  := ~/Downloads/.bootstrap


downloads_dir:
	mkdir -p $(DOWNLOADS)


docker:
	sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
	echo deb https://apt.dockerproject.org/repo ubuntu-xenial main | sudo tee /etc/apt/sources.list.d/docker.list
	sudo apt-get update
	sudo apt-get install -y linux-image-extra-$(shell uname -r)
	sudo apt-get install -y docker-engine


GO_VER := 1.8rc2
TARBALL := go$(GO_VER).linux-amd64.tar.gz

golang: downloads_dir
	rm -rf ~/.go
	curl https://storage.googleapis.com/golang/${TARBALL} -o $(DOWNLOADS)/$(TARBALL)
	tar xvzf $(DOWNLOADS)/$(TARBALL) -C $(DOWNLOADS)
	mv $(DOWNLOADS)/go ~/.go
