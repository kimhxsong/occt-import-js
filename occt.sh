#!/bin/bash

# Exit on error
set -e

# Define URL and file paths
OCCT_URL="https://github.com/Open-Cascade-SAS/OCCT/archive/refs/tags/V7_8_0.tar.gz"
OCCT_TAR="V7_8_0.tar.gz"
OCCT_SRC_DIR="occt_source"

# Create directory for OCCT source files
mkdir -p $OCCT_SRC_DIR

# Download the OCCT source tarball
echo "Downloading OCCT source from $OCCT_URL..."
wget $OCCT_URL -O $OCCT_TAR

# Extract the downloaded tarball
echo "Extracting $OCCT_TAR..."
tar -xzf $OCCT_TAR -C $OCCT_SRC_DIR --strip-components=1

# Clean up
echo "Cleaning up..."
rm $OCCT_TAR

echo "OCCT source downloaded and extracted successfully."
