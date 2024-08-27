#!/bin/bash

# Define the build directory
BUILD_DIR="build"

# Remove the build directory if it exists
if [ -d "$BUILD_DIR" ]; then
  echo "Removing build directory..."
  rm -rf "$BUILD_DIR"
else
  echo "Build directory does not exist."
fi

# Remove CMake related files if they exist
echo "Removing CMake related files..."
rm -f CMakeFiles/ CMakeCache.txt Makefile cmake_install.cmake CMakeLists.txt.user CMakeLists.txt.timestamp CTestTestfile.cmake

echo "Cleanup completed."
