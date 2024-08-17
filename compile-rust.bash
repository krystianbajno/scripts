#!/bin/bash

TARGETS=(
    "x86_64-pc-windows-gnu"      # Windows x64
    "i686-pc-windows-gnu"        # Windows x86
    "aarch64-pc-windows-msvc"    # Windows ARM (requires nightly)
    "x86_64-unknown-linux-gnu"   # Linux x64
    "i686-unknown-linux-gnu"     # Linux x86
    "armv7-unknown-linux-gnueabihf" # Linux ARM
    "x86_64-apple-darwin"        # macOS x64
    "i686-apple-darwin"          # macOS x86
    "aarch64-apple-darwin"       # macOS ARM
)

echo "Installing Rust targets..."
for TARGET in "${TARGETS[@]}"; do
    rustup target add "$TARGET"
done

install_toolchain() {
    case "$1" in
        "x86_64-pc-windows-gnu"|"i686-pc-windows-gnu")
            sudo apt-get install -y gcc-mingw-w64-x86-64 gcc-mingw-w64-i686
            ;;
        "aarch64-pc-windows-msvc")
            rustup toolchain install nightly
            rustup target add aarch64-pc-windows-msvc --toolchain nightly
            ;;
        "x86_64-unknown-linux-gnu"|"i686-unknown-linux-gnu")
            sudo apt-get install -y gcc
            ;;
        "armv7-unknown-linux-gnueabihf")
            sudo apt-get install -y gcc-arm-linux-gnueabihf
            ;;
        "x86_64-apple-darwin"|"i686-apple-darwin"|"aarch64-apple-darwin")
            sudo apt-get install -y clang llvm
            if [ ! -d "/opt/osxcross" ]; then
                git clone https://github.com/tpoechtrager/osxcross.git /opt/osxcross
                cd /opt/osxcross
                ./tools/get_dependencies.sh
                ./build.sh
                export PATH="/opt/osxcross/target/bin:$PATH"
                cd -
            fi
            ;;
        *)
            echo "No additional toolchain needed for $1"
            ;;
    esac
}

echo "Installing necessary toolchains..."
for TARGET in "${TARGETS[@]}"; do
    install_toolchain "$TARGET"
done

export MACOSX_DEPLOYMENT_TARGET=10.7

echo "Building project for all targets..."
for TARGET in "${TARGETS[@]}"; do
    echo "Building for $TARGET..."
    case "$TARGET" in
        "x86_64-pc-windows-gnu"|"i686-pc-windows-gnu")
            cargo build --release --target "$TARGET"
            ;;
        "aarch64-pc-windows-msvc")
            cargo +nightly build --release --target "$TARGET"
            ;;
        "x86_64-unknown-linux-gnu"|"i686-unknown-linux-gnu"|"armv7-unknown-linux-gnueabihf")
            cargo build --release --target "$TARGET"
            ;;
        "x86_64-apple-darwin"|"i686-apple-darwin"|"aarch64-apple-darwin")
            cargo build --release --target "$TARGET"
            ;;
        *)
            echo "Unsupported target: $TARGET"
            ;;
    esac
done

echo "All builds completed."
