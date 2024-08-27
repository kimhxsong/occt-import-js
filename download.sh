#!/bin/bash

# Exit on error
set -e

# Create a directory named 'downloads' if it doesn't already exist
# -p flag ensures that no error is raised if the directory already exists
# Then, change the current working directory to the newly created 'downloads' directory
mkdir -p downloads && cd ./downloads

# Define installation and source directories based on the current working directory
CURRENT_DIR=$(pwd)

# Define URLs
TCL_URL="http://prdownloads.sourceforge.net/tcl/tcl8.6.14-src.tar.gz"
TK_URL="http://prdownloads.sourceforge.net/tcl/tk8.6.14-src.tar.gz"
FREETYPE_URL="https://download.savannah.gnu.org/releases/freetype/freetype-2.13.3.tar.gz"
TBB_URL="https://github.com/oneapi-src/oneTBB/archive/refs/tags/v2021.5.0.tar.gz"
FREEIMAGE_URL="https://sourceforge.net/projects/freeimage/files/Source%20Distribution/3.18.0/FreeImage3180.zip"
VTK_URL="https://vtk.org/files/release/9.3/VTK-9.3.1.tar.gz"

# Define download and extraction paths
TCL_SRC_DIR="$CURRENT_DIR/tcl_source"
TK_SRC_DIR="$CURRENT_DIR/tk_source"
FREETYPE_SRC_DIR="$CURRENT_DIR/freetype_source"
TBB_SRC_DIR="$CURRENT_DIR/tbb_source"
FREEIMAGE_SRC_DIR="$CURRENT_DIR/freeimage_source"
VTK_SRC_DIR="$CURRENT_DIR/vtk_source"

# Create directories
mkdir -p $TCL_SRC_DIR $TK_SRC_DIR $FREETYPE_SRC_DIR $TBB_SRC_DIR $FREEIMAGE_SRC_DIR $VTK_SRC_DIR

# Download and extract Tcl
echo "Downloading and extracting Tcl..."
wget $TCL_URL -O $CURRENT_DIR/tcl-src.tar.gz
tar -xzf $CURRENT_DIR/tcl-src.tar.gz -C $TCL_SRC_DIR --strip-components=1

# Download and extract Tk
echo "Downloading and extracting Tk..."
wget $TK_URL -O $CURRENT_DIR/tk-src.tar.gz
tar -xzf $CURRENT_DIR/tk-src.tar.gz -C $TK_SRC_DIR --strip-components=1

# Download and extract FreeType
echo "Downloading and extracting FreeType..."
wget $FREETYPE_URL -O $CURRENT_DIR/freetype-src.tar.gz
tar -xzf $CURRENT_DIR/freetype-src.tar.gz -C $FREETYPE_SRC_DIR --strip-components=1

# Download and extract TBB
echo "Downloading and extracting TBB..."
wget $TBB_URL -O $CURRENT_DIR/tbb-src.tar.gz
tar -xzf $CURRENT_DIR/tbb-src.tar.gz -C $TBB_SRC_DIR --strip-components=1

# Download and extract FreeImage
echo "Downloading and extracting FreeImage..."
wget $FREEIMAGE_URL -O $CURRENT_DIR/freeimage.zip
unzip $CURRENT_DIR/freeimage.zip -d $FREEIMAGE_SRC_DIR

# Download and extract VTK
echo "Downloading and extracting VTK..."
wget $VTK_URL -O $CURRENT_DIR/vtk-src.tar.gz
tar -xzf $CURRENT_DIR/vtk-src.tar.gz -C $VTK_SRC_DIR --strip-components=1

# Download Emscripten
git clone https://github.com/emscripten-core/emsdk
cd emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh

echo "All sources downloaded and extracted successfully."
