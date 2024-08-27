#!/bin/bash

# Exit on error
set -e

# Create a directory named 'downloads' if it doesn't already exist
# -p flag ensures that no error is raised if the directory already exists
# Then, change the current working directory to the newly created 'downloads' directory
mkdir -p downloads && cd ./downloads

# Define installation and source directories based on the current working directory
CURRENT_DIR=$(pwd)

TCL_SRC_DIR="$CURRENT_DIR/tcl_source"
TCL_INSTALL_DIR="$CURRENT_DIR/tcl_install"
TK_SRC_DIR="$CURRENT_DIR/tk_source"
TK_INSTALL_DIR="$CURRENT_DIR/tk_install"
FREETYPE_SRC_DIR="$CURRENT_DIR/freetype_source"
FREETYPE_INSTALL_DIR="$CURRENT_DIR/freetype_install"
FREEIMAGE_SRC_DIR="$CURRENT_DIR/freeimage_source"
FREEIMAGE_INSTALL_DIR="$CURRENT_DIR/freeimage_install"
VTK_SRC_DIR="$CURRENT_DIR/vtk_source"
VTK_INSTALL_PREFIX="$CURRENT_DIR/vtk_install"

# Install Tcl
echo "Installing Tcl..."
cd $TCL_SRC_DIR/unix
./configure --enable-gcc --enable-shared --enable-threads --enable-64bit  --prefix=$TCL_INSTALL_DIR 
make
make install

# Install Tk
echo "Installing Tk..."
cd $TK_SRC_DIR/unix
./configure --enable-gcc --enable-shared --enable-threads --with-tcl=$TCL_INSTALL_DIR/lib --prefix=$TK_INSTALL_DIR
make
make install

# Install FreeType
echo "Installing FreeType..."
cd $FREETYPE_SRC_DIR
./configure --prefix=$FREETYPE_INSTALL_DIR CFLAGS='-m64 -fPIC' CPPFLAGS='-m64 -fPIC'
make
make install

# Install TBB
echo "Installing TBB..."
TBB_ARCHIVE="$CURRENT_DIR/oneapi-tbb-2021.5.0-lin.tgz"
tar -xzf $TBB_ARCHIVE
TBB_INSTALL_DIR="$CURRENT_DIR/tbb_install"
cp -r oneapi-tbb-2021.5.0/* $TBB_INSTALL_DIR

# Install FreeImage
echo "Installing FreeImage..."
cd $FREEIMAGE_SRC_DIR/Source/OpenEXR/Imath
sed -i '60i#include <string.h>' ImathMatrix.h
cd $FREEIMAGE_SRC_DIR
# Modify Makefile if necessary
sed -i 's|DESTDIR ?= /|DESTDIR ?= $(DESTDIR)|' Makefile.gnu
sed -i 's|INCDIR ?= $(DESTDIR)/usr/include|INCDIR ?= $(DESTDIR)/include|' Makefile.gnu
sed -i 's|INSTALLDIR ?= $(DESTDIR)/usr/lib|INSTALLDIR ?= $(DESTDIR)/lib|' Makefile.gnu
sed -i 's|install  -m 644 -o root -g root $(HEADER) $(INCDIR)|install  -m 755 $(HEADER) $(INCDIR)|' Makefile.gnu
sed -i 's|install  -m 644 -o root -g root $(STATICLIB) $(INSTALLDIR)|install  -m 755 $(STATICLIB) $(INSTALLDIR)|' Makefile.gnu
sed -i 's|install  -m 644 -o root -g root $(SHAREDLIB) $(INSTALLDIR)|install  -m 755 $(SHAREDLIB) $(INSTALLDIR)|' Makefile.gnu
sed -i 's|ldconfig|#ldconfig|' Makefile.gnu
make
make DESTDIR=$FREEIMAGE_INSTALL_DIR install

# Clean temporary files for FreeImage
make clean

# Install VTK
echo "Installing VTK..."
cd $VTK_SRC_DIR
cmake -DCMAKE_INSTALL_PREFIX=$VTK_INSTALL_PREFIX .
make
make install

# Install Docker Engine
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Installation completed successfully."
