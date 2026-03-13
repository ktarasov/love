#!/usr/bin/bash
zig build -Doptimize=ReleaseSmall -Dtarget=x86_64-linux-gnu -p zig-out/x86_64-linux && zip -j zig-out/x86_64-linux-gnu.zip zig-out/x86_64-linux/bin/love
zig build -Doptimize=ReleaseSmall -Dtarget=x86-linux-gnu -p zig-out/x86-linux-gnu && zip -j zig-out/x86-linux-gnu.zip zig-out/x86-linux-gnu/bin/love
zig build -Doptimize=ReleaseSmall -Dtarget=x86_64-windows-gnu -p zig-out/x86_64-windows && zip -j zig-out/x86_64-windows-gnu.zip zig-out/x86_64-windows/bin/love.exe
# zig build -Doptimize=ReleaseSmall -Dtarget=x86-windows-gnu -p zig-out/x86-windows-gnu && zip -j zig-out/x86-windows-gnu.zip zig-out/x86-windows-gnu/bin/love.exe
zig build -Doptimize=ReleaseSmall -Dtarget=x86_64-macos-none -p zig-out/x86_64-macos && zip -j zig-out/x86_64-macos.zip zig-out/x86_64-macos/bin/love
zig build -Doptimize=ReleaseSmall -Dtarget=aarch64-macos-none -p zig-out/aarch64-macos && zip -j zig-out/aarch64-macos.zip zig-out/aarch64-macos/bin/love