cd /workspace/occt-import-js

emcmake cmake -B build_wasm -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release .
emmake make -C build_wasm

mkdir -p /workspace/occt-import-js/dist

cp /workspace/build_wasm/Release/occt-import-js.js /workspace/dist/occt-import-js.js
cp /workspace/build_wasm/Release/occt-import-js.wasm /workspace/dist/occt-import-js.wasm
