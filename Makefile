SHELL := /bin/sh

RELEASEVER?=1
VERSION?=5.4.24

NPROCS:=1
OS:=$(shell uname -s)

ifeq ($(OS),Linux)
	NPROCS:=$(shell grep -c ^processor /proc/cpuinfo)
endif

reverse = $(if $(1),$(call reverse,$(wordlist 2,$(words $(1)),$(1)))) $(firstword $(1))

STRINGVER:=$(shell python ./ver.py --toStringVer $$VERSION)
BUILDVER:=$(shell echo $$VERSION | rev | cut -d'.' -f2- | rev)
PATCHVER:=$(shell python ./ver.py --toSemVer $$RELEASEVER | cut -d'.' -f2- | rev | sed 's/\./-/g')
VARIANTSTR:=$(shell echo $$PATCHES | sed 's/ /_/g')

PATCHDIRS:=$(foreach dir,$(PATCHES),$(wildcard $(BUILDVER)/$(DIST)/patches/$(dir)))
DSTPATCH:=$(foreach patch,$(PATCHDIRS),$(wildcard $(patch)/*.patch))
TARGETPATCHES:=$(sort $(foreach file,$(notdir $(DSTPATCH)),linux-$(VERSION)/$(file)))

default: clean $(TARGETPATCHES) ## Builds the Linux kernel for $VERSION and $RELEASEVER with $PATCHES
	$(MAKE) -C linux-$(VERSION) olddefconfig
	$(MAKE) -C linux-$(VERSION) -j$(NPROCS) ARCH=$(ARCH) deb-pkg

clean: ## Cleans up any downloaded or generated files
	rm -rf linux-*

.PHONY: help
help:	## Lists all available commands and a brief description.
	@grep -E '^[a-zA-Z/_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: $(DSTPATCH)
$(DSTPATCH):
	cp $@ linux-$(VERSION)

$(TARGETPATCHES): linux-$(VERSION) $(DSTPATCH) ## Applies the specified patches
	cd linux-$(VERSION) && patch -p1 <$(notdir $@)

linux-$(VERSION)/.config: linux-$(VERSION) ## Configures and patches the .config file
	cp $(BUILDVER)/$(DIST)/.config linux-$(VERSION)/.config
	echo "CONFIG_LOCALVERSION=\"-$(STRINGVER)-$(PATCHVER)-$(VARIANTSTR)\"" | tee -a linux-$(VERSION)/.config

linux-$(VERSION):  ## Extracts the kernel
	wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$(VERSION).tar.xz
	tar -xf linux-$(VERSION).tar.xz