#include "CocoaEventQueue.h"
#import <Cocoa/Cocoa.h>

namespace xwin
{
void EventQueue::update()
{
    // Update Application
    NSApplication* nsApp = NSApp;

    // 先根据当前活动窗口的内容区域尺寸，合成一次 Resize 事件（如有变化）。
    // 这样在 macOS 上拖动窗口改变大小时，也能得到统一的 xwin::EventType::Resize。
    {
        static NSSize sLastContentSize = {0, 0};
        NSWindow* window = [nsApp keyWindow];
        if (!window)
        {
            window = [nsApp mainWindow];
        }
        if (window)
        {
            NSRect contentRect = [window contentRectForFrameRect:[window frame]];
            NSSize contentSize = contentRect.size;
            if (sLastContentSize.width != contentSize.width ||
                sLastContentSize.height != contentSize.height)
            {
                sLastContentSize = contentSize;
                Event resizeEvent(
                    ResizeData(static_cast<unsigned>(contentSize.width),
                               static_cast<unsigned>(contentSize.height),
                               false));
                mQueue.push(resizeEvent);
            }
        }
    }
    @autoreleasepool
    {
        NSEvent* nsEvent = nil;
        do
        {
            nsEvent = [nsApp nextEventMatchingMask:NSEventMaskAny untilDate:nil inMode:NSDefaultRunLoopMode dequeue:YES];
            if (!nsEvent)
            {
                break;
            }

            Event curEvent;
            switch (nsEvent.type)
            {
                case NSEventTypeSystemDefined:
                    break;

                case NSEventTypeKeyDown:
                case NSEventTypeKeyUp:
                {
                    // 目前项目里键盘在 mac 侧没用到，先保持为空实现。
                    break;
                }

                case NSEventTypeLeftMouseDown:
                    curEvent = Event(
                        MouseInputData(
                            MouseInput::Left, ButtonState::Pressed,
                            ModifierState(nsEvent.modifierFlags & NSEventModifierFlagControl,
                                          nsEvent.modifierFlags & NSEventModifierFlagOption,
                                          nsEvent.modifierFlags & NSEventModifierFlagShift,
                                          nsEvent.modifierFlags & NSEventModifierFlagCommand)));
                    break;

                case NSEventTypeLeftMouseUp:
                    curEvent = Event(
                        MouseInputData(
                            MouseInput::Left, ButtonState::Released,
                            ModifierState(nsEvent.modifierFlags & NSEventModifierFlagControl,
                                          nsEvent.modifierFlags & NSEventModifierFlagOption,
                                          nsEvent.modifierFlags & NSEventModifierFlagShift,
                                          nsEvent.modifierFlags & NSEventModifierFlagCommand)));
                    break;

                case NSEventTypeRightMouseDown:
                    curEvent = Event(
                        MouseInputData(
                            MouseInput::Right, ButtonState::Pressed,
                            ModifierState(nsEvent.modifierFlags & NSEventModifierFlagControl,
                                          nsEvent.modifierFlags & NSEventModifierFlagOption,
                                          nsEvent.modifierFlags & NSEventModifierFlagShift,
                                          nsEvent.modifierFlags & NSEventModifierFlagCommand)));
                    break;

                case NSEventTypeRightMouseUp:
                    curEvent = Event(
                        MouseInputData(
                            MouseInput::Right, ButtonState::Released,
                            ModifierState(nsEvent.modifierFlags & NSEventModifierFlagControl,
                                          nsEvent.modifierFlags & NSEventModifierFlagOption,
                                          nsEvent.modifierFlags & NSEventModifierFlagShift,
                                          nsEvent.modifierFlags & NSEventModifierFlagCommand)));
                    break;

                // 其它鼠标按键（包括中键）——用于中键缩放等操作
                case NSEventTypeOtherMouseDown:
                case NSEventTypeOtherMouseUp:
                {
                    MouseInput button = MouseInput::Button4;
                    // mac 上 buttonNumber: 2 通常是中键
                    if (nsEvent.buttonNumber == 2)
                    {
                        button = MouseInput::Middle;
                    }
                    else if (nsEvent.buttonNumber == 3)
                    {
                        button = MouseInput::Button4;
                    }
                    else if (nsEvent.buttonNumber == 4)
                    {
                        button = MouseInput::Button5;
                    }

                    ButtonState state = (nsEvent.type == NSEventTypeOtherMouseDown)
                                            ? ButtonState::Pressed
                                            : ButtonState::Released;

                    curEvent = Event(
                        MouseInputData(
                            button, state,
                            ModifierState(nsEvent.modifierFlags & NSEventModifierFlagControl,
                                          nsEvent.modifierFlags & NSEventModifierFlagOption,
                                          nsEvent.modifierFlags & NSEventModifierFlagShift,
                                          nsEvent.modifierFlags & NSEventModifierFlagCommand)));
                    break;
                }

                case NSEventTypeMouseMoved:
                case NSEventTypeLeftMouseDragged:
                case NSEventTypeRightMouseDragged:
                case NSEventTypeOtherMouseDragged:
                {
                    NSPoint mouseLocation = [nsEvent locationInWindow];
                    curEvent = Event(
                        MouseMoveData(
                            static_cast<unsigned>(mouseLocation.x),
                            static_cast<unsigned>(mouseLocation.y),
                            static_cast<unsigned>(mouseLocation.x),
                            static_cast<unsigned>(mouseLocation.y),
                            static_cast<int>(nsEvent.deltaX),
                            static_cast<int>(nsEvent.deltaY)));
                    break;
                }

                case NSEventTypeScrollWheel:
                {
                    double delta = [nsEvent scrollingDeltaY];
                    curEvent = Event(
                        MouseWheelData(
                            delta,
                            ModifierState(nsEvent.modifierFlags & NSEventModifierFlagControl,
                                          nsEvent.modifierFlags & NSEventModifierFlagOption,
                                          nsEvent.modifierFlags & NSEventModifierFlagShift,
                                          nsEvent.modifierFlags & NSEventModifierFlagCommand)));
                    break;
                }

                default:
                    break;
            }
            if(curEvent.type != EventType::None)
            {
                mQueue.push(curEvent);
            }
            
            [NSApp sendEvent:nsEvent];
        }
        while (nsEvent);
        
    }
    [nsApp updateWindows];
}

const Event& EventQueue::front()
{
    return mQueue.front();
}

void EventQueue::pop()
{
    mQueue.pop();
}

bool EventQueue::empty()
{
    return mQueue.empty();
}


}
