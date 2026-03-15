#pragma once

#include <cstdint>

#include "../Common/EventQueue.h"
#include "../Common/Init.h"
#include "../Common/WindowDesc.h"

#include <xcb/xcb.h>

namespace xwin
{
/**
 * XCB windows are pretty straight forward and easy, simple virtual function
 * calls:
 *
 * https://xcb.freedesktop.org/manual/group__XCB__Core__API.html
 */
class Window
{
public:
    Window();

    // Initialize this window with the XCB API.
    bool create(const WindowDesc& desc, EventQueue& eventQueue);

    void close();

    // Native window handle for bgfx/OpenGL (xcb_window_t as void*)
    void* getNativeWindow() const { return reinterpret_cast<void*>(static_cast<uintptr_t>(mXcbWindowId)); }

    // DPI/scale factor (X11 typically 1.0; use for consistency with Win32/Cocoa)
    float getBackingScaleFactor() const { return 1.0f; }

  protected:
    xcb_connection_t* mConnection = nullptr;
    xcb_screen_t* mScreen = nullptr;
    unsigned mXcbWindowId = 0;
    unsigned mDisplay = 0;
};
}
