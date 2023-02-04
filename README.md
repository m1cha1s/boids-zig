# boids-zig

## How to build
```bash
# Clone the repo
git clone https://github.com/m1cha1s/boids-zig.git
cd boids-zig
# Get all submodules
git sumbmodule update --init
cd libs/raylib
git sumbmodule update --init
cd ../..
# To build
zig build
# To run
zig build run
```
If it fails it may mean that you lack some Raylib requirements. Instructions on what to install are [here](https://github.com/raysan5/raylib)