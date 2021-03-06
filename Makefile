BOOT2DOCKER_VERSION := 1.8.1

B2D_ISO_FILE := boot2docker.iso
B2D_ISO_URL := https://github.com/boot2docker/boot2docker/releases/download/v$(BOOT2DOCKER_VERSION)/boot2docker.iso
B2D_ISO_CHECKSUM := 7e231d3c33e08f08b604fdc9a557b64b

all: parallels virtualbox

virtualbox:	clean-virtualbox build-virtualbox test-virtualbox

parallels: clean-parallels build-parallels test-parallels

$(B2D_ISO_FILE):
	curl -L -o ${B2D_ISO_FILE} ${B2D_ISO_URL}

$(PRL_B2D_ISO_FILE):
	curl -L -o ${PRL_B2D_ISO_FILE} ${PRL_B2D_ISO_URL}

build-virtualbox: $(B2D_ISO_FILE)
	packer build -parallel=false -only=virtualbox-iso \
		-var 'B2D_ISO_FILE=${B2D_ISO_FILE}' \
		-var 'B2D_ISO_CHECKSUM=${B2D_ISO_CHECKSUM}' \
		template.json

build-parallels: $(B2D_ISO_FILE)
	packer build -parallel=false -only=parallels-iso \
		-var 'B2D_ISO_FILE=${B2D_ISO_FILE}' \
		-var 'B2D_ISO_CHECKSUM=${B2D_ISO_CHECKSUM}' \
		template.json

clean-virtualbox:
	rm -f *_virtualbox.box $(B2D_ISO_FILE)

clean-parallels:
	rm -f *_parallels.box $(B2D_ISO_FILE)

test-virtualbox:
	@cd tests/virtualbox; bats --tap *.bats

test-parallels:
	@cd tests/parallels; bats --tap *.bats

.PHONY: all virtualbox parallels \
	clean-virtualbox build-virtualbox test-virtualbox \
	clean-parallels build-parallels test-parallels
