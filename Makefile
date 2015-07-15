TOP:=$(shell cd ..; pwd)

GCC_VERSION ?=4.9.3
BINUTILS_VERSION ?=2.24
NEWLIB_VERSION ?=2.2.0-1
GDB_VERSION ?=7.9.1

GMP_VERSION ?=6.0.0a
MPFR_VERSION ?=3.1.3
MPC_VERSION ?=1.0.3

# because sometime the extracted directory does not match the file name
GMP_EXTRACTED_VERSION=6.0.0


NEWLIB_URL=ftp://sourceware.org/pub/newlib
GCC_URL=ftp://ftp.gnu.org/gnu/gcc
BINUTILS_URL=ftp://ftp.gnu.org/gnu/binutils
GDB_URL=ftp://ftp.gnu.org/gnu/gdb

# gmp-6.0.0a.tar.bz2
GMP_URL=https://gmplib.org/download/gmp
MPFR_URL=http://www.mpfr.org/mpfr-current
MPC_URL=ftp://ftp.gnu.org/gnu/mpc

DOWNLOADED_SOFTWARES?=$(TOP)/downloaded
EXTRACTED_SOFTWARES?=$(TOP)/extracted
BUILD_DIR?=$(TOP)/build

PREFIX?=$(HOME)/local
TARGET?=arm-none-eabi

export PATH :=$(PREFIX)/bin/:$(PATH)


BINUTILS_CONFIG= --prefix=$(PREFIX) \
--target=$(TARGET) \
--enable-interwork \
--enable-multilib \
--with-gnu-as \
--with-gnu-ld \
--disable-nls \
--disable-werror


GCC_BOOTSTRAP_CONFIG= --target=${TARGET} \
--prefix=${PREFIX} \
--enable-interwork \
--enable-multilib \
--enable-languages="c,c++" \
--with-newlib \
--without-headers \
--disable-shared \
--with-system-zlib \
--with-gnu-as \
--with-gnu-ld \
--disable-nls


NEWLIB_CONFIG= --target=${TARGET} \
--prefix=${PREFIX} \
--enable-interwork \
--enable-multilib \
--with-gnu-as \
--with-gnu-ld \
--disable-nls \
--enable-target-optspace \
--enable-newlib-reent-small \
--enable-newlib-io-c99-formats \
--enable-newlib-io-long-long \
--disable-newlib-supplied-syscalls


GCC_PASS2_CONFIG=--target=${TARGET} \
--prefix=${PREFIX} \
--enable-interwork \
--enable-multilib \
--enable-languages="c,c++" \
--with-newlib \
--disable-shared \
--with-system-zlib \
--with-gnu-as \
--with-gnu-ld \
-with-headers=$(EXTRACTED_SOFTWARES)/newlib-$(NEWLIB_VERSION)/newlib/libc/include \
--disable-nls 



get_gcc:
	mkdir -p $(DOWNLOADED_SOFTWARES)
	wget $(GCC_URL)/gcc-$(GCC_VERSION)/gcc-$(GCC_VERSION).tar.gz -O$(DOWNLOADED_SOFTWARES)/gcc-$(GCC_VERSION).tar.gz


get_binutils:
	mkdir -p $(DOWNLOADED_SOFTWARES)
	wget $(BINUTILS_URL)/binutils-$(BINUTILS_VERSION).tar.gz -O$(DOWNLOADED_SOFTWARES)/binutils-$(BINUTILS_VERSION).tar.gz

get_gdb:
	mkdir -p $(DOWNLOADED_SOFTWARES)
	wget $(GDB_URL)/gdb-$(GDB_VERSION).tar.gz -O$(DOWNLOADED_SOFTWARES)/gdb-$(GDB_VERSION).tar.gz


get_newlib:
	mkdir -p $(DOWNLOADED_SOFTWARES)
	wget $(NEWLIB_URL)/newlib-$(NEWLIB_VERSION).tar.gz -O$(DOWNLOADED_SOFTWARES)/newlib-$(NEWLIB_VERSION).tar.gz


get_gmp:
	mkdir -p $(DOWNLOADED_SOFTWARES)
	wget $(GMP_URL)/gmp-$(GMP_VERSION).tar.bz2 -O$(DOWNLOADED_SOFTWARES)/gmp-$(GMP_VERSION).tar.bz2

get_mpfr:
	mkdir -p $(DOWNLOADED_SOFTWARES)
	wget $(MPFR_URL)/mpfr-$(MPFR_VERSION).tar.gz -O$(DOWNLOADED_SOFTWARES)/mpfr-$(MPFR_VERSION).tar.gz

get_mpc:
	mkdir -p $(DOWNLOADED_SOFTWARES)
	wget $(MPC_URL)/mpc-$(MPC_VERSION).tar.gz -O$(DOWNLOADED_SOFTWARES)/mpc-$(MPC_VERSION).tar.gz


###############################################################################
#########  Binutils Build/Installation ########################################
###############################################################################

#.phony  get_mpc
extract_binutils:
	mkdir -p $(EXTRACTED_SOFTWARES)	
	tar xvzf $(DOWNLOADED_SOFTWARES)/binutils-$(BINUTILS_VERSION).tar.gz --directory $(EXTRACTED_SOFTWARES)	

configure_binutils:
	mkdir -p $(BUILD_DIR)/binutils
	cd  $(BUILD_DIR)/binutils  && $(EXTRACTED_SOFTWARES)/binutils-$(BINUTILS_VERSION)/configure  $(BINUTILS_CONFIG)

build_binutils:
	make -C $(BUILD_DIR)/binutils all

install_binutils:
	make -C $(BUILD_DIR)/binutils install


###############################################################################
#########  GCC bootstrap  Build/Installation ##################################
###############################################################################

extract_gcc:
	mkdir -p $(EXTRACTED_SOFTWARES)	
	tar xvzf $(DOWNLOADED_SOFTWARES)/gcc-$(GCC_VERSION).tar.gz --directory $(EXTRACTED_SOFTWARES)	

extract_gmp:
	mkdir -p $(EXTRACTED_SOFTWARES)
	tar xvjf $(DOWNLOADED_SOFTWARES)/gmp-$(GMP_VERSION).tar.bz2 --directory $(EXTRACTED_SOFTWARES)

extract_mpfr:
	mkdir -p $(EXTRACTED_SOFTWARES)
	tar xvzf $(DOWNLOADED_SOFTWARES)/mpfr-$(MPFR_VERSION).tar.gz --directory $(EXTRACTED_SOFTWARES)

extract_mpc:
	mkdir -p $(EXTRACTED_SOFTWARES)
	tar xvzf $(DOWNLOADED_SOFTWARES)/mpc-$(MPC_VERSION).tar.gz --directory $(EXTRACTED_SOFTWARES)


create_lib_links:
	rm -f $(EXTRACTED_SOFTWARES)/gcc-$(GCC_VERSION)/gmp
	rm -f $(EXTRACTED_SOFTWARES)/gcc-$(GCC_VERSION)/mpfr
	rm -f $(EXTRACTED_SOFTWARES)/gcc-$(GCC_VERSION)/mpc
	ln -s $(EXTRACTED_SOFTWARES)/gmp-$(GMP_EXTRACTED_VERSION) $(EXTRACTED_SOFTWARES)/gcc-$(GCC_VERSION)/gmp
	ln -s $(EXTRACTED_SOFTWARES)/mpfr-$(MPFR_VERSION) $(EXTRACTED_SOFTWARES)/gcc-$(GCC_VERSION)/mpfr
	ln -s $(EXTRACTED_SOFTWARES)/mpc-$(MPC_VERSION) $(EXTRACTED_SOFTWARES)/gcc-$(GCC_VERSION)/mpc


configure_gcc_boot:
	mkdir -p $(BUILD_DIR)/gcc
	cd  $(BUILD_DIR)/gcc  && $(EXTRACTED_SOFTWARES)/gcc-$(GCC_VERSION)/configure  $(GCC_BOOTSTRAP_CONFIG)

build_gcc_boot:
	make -C $(BUILD_DIR)/gcc all-gcc

install_gcc_boot:
	make -C $(BUILD_DIR)/gcc install-gcc

###############################################################################
#########  Newlib         Build/Installation ##################################
###############################################################################

extract_newlib:
	mkdir -p $(EXTRACTED_SOFTWARES)	
	tar xvzf $(DOWNLOADED_SOFTWARES)/newlib-$(NEWLIB_VERSION).tar.gz --directory $(EXTRACTED_SOFTWARES)	

configure_newlib:
	mkdir -p $(BUILD_DIR)/newlib
	cd  $(BUILD_DIR)/newlib  && $(EXTRACTED_SOFTWARES)/newlib-$(NEWLIB_VERSION)/configure  $(NEWLIB_CONFIG)

build_newlib:
	make -C $(BUILD_DIR)/newlib all

install_newlib:
	make -C $(BUILD_DIR)/newlib install


###############################################################################
#########  GCC final      Build/Installation ##################################
###############################################################################

cleanup_gcc_pass2:
	cd $(BUILD_DIR)/gcc && make distclean

configure_gcc_pass2:
	mkdir -p $(BUILD_DIR)/gcc
	cd  $(BUILD_DIR)/gcc  && $(EXTRACTED_SOFTWARES)/gcc-$(GCC_VERSION)/configure  $(GCC_PASS2_CONFIG)

build_gcc_pass2:
	make -C $(BUILD_DIR)/gcc

install_gcc_pass2:
	make -C $(BUILD_DIR)/gcc install

help:
	echo "To be done..."
