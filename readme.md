<p align="center">
  <img src="docs/images/logo.svg" alt="Logo"/>
</p>

# CrossWindow

[![cmake-img]][cmake-url]
[![License][license-img]][license-url]
[![Travis Tests][travis-img]][travis-url]
[![Appveyor Tests][appveyor-img]][appveyor-url]
[![Coverage Tests][codecov-img]][codecov-url]

A basic cross platform system abstraction library for managing windows and performing OS tasks.

## Features

- 🌟 Simple Window, File Dialog, and Message Dialog Creation

- ⌨️ 🖱️ 👆 🎮 Basic Input (Keyboard, Mouse, Touch, and Gamepad)

- 👻 Platform specific features (Mac Transparency, Mobile Accelerometer, etc.)

- 💊 Unit Tests + Test Coverage ([Appveyor][appveyor-url] for **Windows**, [CircleCI][circleci-url] for **Android / MacOS / iOS**, [Travis][travis-url] for **Linux/Noop**)

- 😎 Well maintained C++ 11, with a promise to evolve as the standard evolves. (C++ Modules, Package Managers, etc.)

### Supported Platforms

- 🖼️ Windows (Win32<!--or UWP-->)

- 🍎 Mac (Cocoa)

- 📱 iOS (UIKit) *(Currently working, but missing some functionality)*

- 🐧 Linux *(Currently working, but missing some functionality)*

- 🤖 Android (In Progress)

- 🌐 WebAssembly *(Currently working, but missing some functionality)*

- ❌ Noop (Headless)


## Installation

First add the repo as a submodule in your dependencies folder such as `external/`:

```bash
cd external
git submodule add https://github.com/alaingalvan/crosswindow.git
```

Then in your `CMakeLists.txt` file, include the following:

```cmake
# ⬇ Add your dependency:
add_subdirectories(external/crosswindow)

# ❎ When creating your executable use CrossWindow's abstraction function:
xwin_add_executable(
    # Target
    ${PROJECT_NAME}
    # Source Files (make sure to surround in quotations so CMake treats it as a list)
    "${SOURCE_FILES}"
)

# 🔗 Link CrossWindow to your project:
target_link_libraries(
    ${PROJECT_NAME}
    CrossWindow
)
```

Fill out the rest of your `CMakeLists.txt` file with any other source files and dependencies you may have, then in your project root:

```bash
# 🖼️ To build your Visual Studio solution on Windows x64
cmake -B build -A x64

# 🍎 To build your XCode project On Mac OS for Mac OS
cmake -B build -G Xcode

# 📱 To build your XCode project on Mac OS for iOS / iPad OS / tvOS / watchOS
cmake -B build -G Xcode -DCMAKE_SYSTEM_NAME=iOS

# 🐧 To build your .make file on Linux
cmake -B build

# 🔨 Build on any platform:
cmake -B build --build
```

For WebAssembly you'll need to have [Emscripten](http://kripken.github.io/emscripten-site/docs/getting_started/downloads.html) installed. Assuming you have the SDK installed, do the following to build a WebAssembly project:

```bash
# 🌐 For WebAssembly Projects
mkdir webassembly
cd webassembly
cmake .. -DXWIN_OS=WASM -DCMAKE_TOOLCHAIN_FILE="$EMSDK/emscripten/1.38.1/cmake/Modules/Platform/Emscripten.cmake" -DCMAKE_BUILD_TYPE=Release

# Run emconfigure with the normal configure command as an argument.
$EMSDK/emscripten/emconfigure ./configure

# Run emmake with the normal make to generate linked LLVM bitcode.
$EMSDK/emscripten/emmake make

# Compile the linked bitcode generated by make (project.bc) to JavaScript.
#  'project.bc' should be replaced with the make output for your project (e.g. 'yourproject.so')
$EMSDK/emscripten/emcc project.bc -o project.js
```

For more information visit the [Emscripten Docs on CMake](https://kripken.github.io/emscripten-site/docs/compiling/Building-Projects.html#using-libraries).

For **Android Studio** you'll need to make a project, then edit your `build.gradle` file.

```groovy
// 🤖 To build your Android Studio project
android {
    ...
    externalNativeBuild {
        cmake {
            ...
            // Use the following syntax when passing arguments to variables:
            // arguments "-DVAR_NAME=ARGUMENT".
            arguments "-DXWIN_OS=ANDROID",
            // The following line passes 'rtti' and 'exceptions' to 'ANDROID_CPP_FEATURES'.
            "-DANDROID_CPP_FEATURES=rtti exceptions"
        }
    }
  buildTypes {...}

  // Use this block to link Gradle to your CMake build script.
  externalNativeBuild {
    cmake {...}
  }
}
```

for more information visit [Android Studio's docs on CMake](https://developer.android.com/ndk/guides/cmake).

## Usage

Then create a main delegate function `void xmain(int argc, const char** argv)` in a `.cpp` file in your project (for example "`XMain.cpp`") where you'll put your application logic:

```cpp
#include "CrossWindow/CrossWindow.h"

void xmain(int argc, const char** argv)
{
    // 🖼️ Create Window Description
    xwin::WindowDesc windowDesc;
    windowDesc.name = "Test";
    windowDesc.title = "My Title";
    windowDesc.visible = true;
    windowDesc.width = 1280;
    windowDesc.height = 720;

    bool closed = false;

    // 🌟 Initialize
    xwin::Window window;
    xwin::EventQueue eventQueue;

    if (!window.create(windowDesc, eventQueue))
    { return; }

    // 🏁 Engine loop
    bool isRunning = true;

    while (isRunning)
    {
        // ♻️ Update the event queue
        eventQueue.update();

        // 🎈 Iterate through that queue:
        while (!eventQueue.empty())
        {
            const xwin::Event& event = eventQueue.front();

            if (event.type == xwin::EventType::MouseMove)
            {
                const xwin::MouseData mouse = event.data.mouse;
            }
            if (event.type == xwin::EventType::Close)
            {
                window.close();
                isRunning = false;
            }

            eventQueue.pop();
        }
    }
}
```

This `xmain` function will be called from a *platform specific main function* that will be included in your main project by CMake. If you ever need to access something from the platform specific main function for whatever reason, you'll find it in `xwin::getXWinState()`.

For more examples visit the [Documentation](/docs) or try out the [examples](https://github.com/alaingalvan/crosswindow-demos).

## Development

Be sure to have [CMake](https://cmake.org) Installed.

| CMake Options | Description |
|:-------------:|:-----------:|
| `XWIN_TESTS` | Whether or not unit tests are enabled. Defaults to `OFF`, Can be `ON` or `OFF`. |
| `XWIN_API` | The OS API to use for window generation, defaults to `AUTO`, can be can be `NOOP`, `WIN32`<!--, `UWP`-->, `COCOA`, `UIKIT`, `XCB` <!--`XLIB`, `MIR`, `WAYLAND`-->, `ANDROID`, or `WASM`. |
| `XWIN_OS` | **Optional** - What Operating System to build for, functions as a quicker way of setting target platforms. Defaults to `AUTO`, can be `NOOP`, `WINDOWS`, `MACOS`, `LINUX`, `ANDROID`, `IOS`, `WASM`. If your platform supports multiple apis, the final api will be automatically set to CrossWindow defaults ( `WIN32` on Windows, `XCB` on Linux ). If `XWIN_API` is set this option is ignored. |


First install [Git](https://git-scm.com/downloads), then open any terminal such as [Hyper](https://hyper.is/) in any folder and type:

```bash
# 🐑 Clone the repo
git clone https://github.com/alaingalvan/crosswindow.git --recurse-submodules

# 💿 go inside the folder
cd crosswindow

# 👯 If you forget to `recurse-submodules` you can always run:
git submodule update --init

```

From there we'll need to set up our build files. Be sure to have the following installed:

- [CMake](https://cmake.org/)

- An IDE such as [Visual Studio](https://visualstudio.microsoft.com/downloads/), [XCode](https://developer.apple.com/xcode/), or a compiler such as [GCC](https://gcc.gnu.org/).

Then type the following in your terminal from the repo folder:

```bash
# 🖼️ To build your Visual Studio solution on Windows x64
cmake -B build -A x64 -DXWIN_TESTS=ON

# 🍎 To build your XCode project on Mac OS
cmake -B build -G Xcode -DXWIN_TESTS=ON

# 🐧 To build your .make file on Linux
cmake -B build -DXWIN_TESTS=ON

# 🔨 Build on any platform:
cmake -B build --build
```

Whenever you add new files to the project, run `cmake ..` from your solution/project folder `/build/`, and if you edit the `CMakeLists.txt` file be sure to delete the generated files and run Cmake again.

## License

CrossWindow is licensed as either **MIT** or **Apache-2.0**, whichever you would prefer.

[cmake-img]: https://img.shields.io/badge/cmake-3.6-1f9948.svg?style=flat-square
[cmake-url]: https://cmake.org/
[license-img]: https://img.shields.io/:license-mit-blue.svg?style=flat-square
[license-url]: https://opensource.org/licenses/MIT
[travis-img]: https://img.shields.io/travis/alaingalvan/CrossWindow.svg?style=flat-square&logo=travis
[travis-url]: https://travis-ci.org/alaingalvan/CrossWindow
[appveyor-img]: https://img.shields.io/appveyor/ci/alaingalvan/CrossWindow.svg?style=flat-square&logo=windows
[appveyor-url]: https://ci.appveyor.com/project/alaingalvan/crosswindow
[circleci-img]: https://img.shields.io/circleci/project/github/alaingalvan/CrossWindow.svg?style=flat-square&logo=appveyor
[circleci-url]: https://circleci.com/gh/alaingalvan/CrossWindow
[codecov-img]: https://img.shields.io/codecov/c/github/alaingalvan/CrossWindow.svg?style=flat-square
[codecov-url]: https://codecov.io/gh/alaingalvan/CrossWindow
