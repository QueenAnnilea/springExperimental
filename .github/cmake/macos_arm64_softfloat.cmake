# .github/cmake/macos_arm64_softfloat.cmake
# v2: Clear existing flags before setting to avoid duplicates.
#
# CMake Toolchain file for building on macOS ARM64 (Apple Silicon)
# with streflop forced into software float mode.

# Set the target system
set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_SYSTEM_PROCESSOR arm64)

# Set the target architecture for Apple platforms
set(CMAKE_OSX_ARCHITECTURES arm64 CACHE STRING "Build architecture for macOS" FORCE)

# Set compiler flags
# Force STREFLOP_SOFT mode. Clear existing flags first to avoid duplication.
set(CMAKE_C_FLAGS "-DSTREFLOP_SOFT" CACHE STRING "C Flags" FORCE)
set(CMAKE_CXX_FLAGS "-DSTREFLOP_SOFT" CACHE STRING "C++ Flags" FORCE)

# Set path for Homebrew dependencies (adjust if necessary)
set(CMAKE_PREFIX_PATH "/opt/homebrew;/opt/homebrew/opt/sdl2;/opt/homebrew/opt/devil;/opt/homebrew/opt/minizip;/opt/homebrew/opt/libogg;/opt/homebrew/opt/libvorbis;/opt/homebrew/opt/fontconfig" CACHE STRING "Prefix path for Homebrew")
set(CMAKE_FIND_FRAMEWORK LAST)
set(CMAKE_FIND_APPBUNDLE LAST)

message(STATUS "Using Toolchain: macOS ARM64 with Streflop SoftFloat (v2)")
