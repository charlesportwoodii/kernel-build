# Linux Kernel Builds

This repository contains build scripts to build the mainline Linux kernel for debian with various patches and configurations. Kernel is built on TravisCI and are deployed to https://apt.erianna.com/kernel. See [Travis CI](https://travis-ci.com/charlesportwoodii/kernel-build) for a list of build variants.

This repository primarily exists to automate builds for Ubuntu + VFIO for my personal use, but can easily be adapted to your needs.

This script will automatically build for kerenl version 5.4 and 5.5.

## Usage

In general, you can build a clean kernel amd64 kernel by running the following command, replacing the kernel version in the `VERSION` string:

```
VERSION=5.4.24 make
```

Cross platform builds can be done by changing the `ARCH` shell variable to any valid kernel architecture.

### Patches

Place patches in the `<version>/debian/patches/<dir>` directory then specify that directory in the `PATCHES` shell variable.

For example, to build with the default ubuntu mainline patches + VFIO FLR patches included with the repository:

```
PATCHES="ubuntu vfio" VERSION=5.4.24 make
```