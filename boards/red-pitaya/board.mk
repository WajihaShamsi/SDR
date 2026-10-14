# Linux and U-boot
ZYNQ_TYPE ?= zynq

UBOOT_VERSION ?= 2017.2

LINUX_VERSION ?= 2017.2

DTREE_VERSION ?= 2017.2

UBOOT_TAG := koheron-red-pitaya-v$(UBOOT_VERSION)
LINUX_TAG := koheron-v$(LINUX_VERSION)-kernel-module-fix-dma
DTREE_TAG := xilinx-v$(DTREE_VERSION)

UBOOT_URL := https://github.com/Koheron/u-boot-xlnx/archive/$(UBOOT_TAG).tar.gz
LINUX_URL := https://github.com/Koheron/linux-xlnx/archive/$(LINUX_TAG).tar.gz
DTREE_URL := https://github.com/Xilinx/device-tree-xlnx/archive/$(DTREE_TAG).tar.gz
