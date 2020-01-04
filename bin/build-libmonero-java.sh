#!/bin/sh

#EMCC_DEBUG=1 


# Make libmonero-java.dylib
mkdir -p ./build &&
cd build && 
cmake .. && 
cmake --build . && 
make .