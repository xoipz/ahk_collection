CoordMode,Mouse,Screen	;全局获取模式（鼠标坐标）
SetMouseDelay, 100
#MaxHotkeysPerInterval 200
#NoEnv

;在任务栏中，win键滑动亮度调整，其他地方为声音调整
~WheelUp:: ;滚轮上划
    if(ExistisShell()=true){
        MouseGetPos, xpos
        if (xpos<0 or xpos>=70)
            Send,{Volume_Up}{Volume_Up}
        else
            MoveBrightness(5)
    }
return

~WheelDown:: ;滚轮下划
    if(ExistisShell()=true){
        MouseGetPos, xpos
        if ((xpos<0 or xpos>=70))
            Send,{Volume_Down}{Volume_Down}
        else
            MoveBrightness(-5)
    }
return

~MButton:: ;滚轮中键
    if (ExistisShell()=true)
        Send,{Volume_Mute}
return

GetutoolsColor(now){
    if(now==5)
        return 0
    liste:=110+now*60
    PixelGetColor , color, 55, liste , RGB ;将(x, y)的颜色用RGB的格式储存在color里
    StringRight color, color, 10	;将color的右10位保存到color
    if(color==0XFDB745)
        return now
    else
        return GetutoolsColor(now+1)
}

;获取坐标xy处的色值
GetColor(x,y){
    PixelGetColor,color,x,y,RGB
    StringLeft color,color,10
return color
}

#IfWinActive ahk_class Shell_TrayWnd 
A:: ;A：上一首歌
    Send {Media_Prev}
    ToolTip,- 上一首歌 -,0, 0
    SetTimer, RemoveToolTip, -1000
return

D:: ;D：下一首歌
    Send {Media_Next}
    ToolTip,- 下一首歌 -,0, 0
    SetTimer, RemoveToolTip, -1000
return

space:: ;空格：暂停与开始
    Send {Media_Play_Pause}
    ToolTip,- 暂停与开始 -,0, 0
    SetTimer, RemoveToolTip, -1000
return

W:: ;W：喜欢该歌曲
    Send {Ctrl Down}{Alt Down}p{Alt Up}{Ctrl Up}
    ToolTip,- 收藏 -,0, 0
    SetTimer, RemoveToolTip, -1000
return

q:: ;任务框点击q 隐藏、显示桌面图标！
    HideOrShowDesktopIcons()
return

;隐藏、显示桌面图标
HideOrShowDesktopIcons(){
    ControlGet, class, Hwnd,, SysListView321, ahk_class Progman
    If class =
        ControlGet, class, Hwnd,, SysListView321, ahk_class WorkerW

    If DllCall("IsWindowVisible", UInt,class)
        WinHide, ahk_id %class%
    Else
        WinShow, ahk_id %class%
}

e:: ;任务框点击e弹出声音合成器
    WinGet,winpid,PID,ahk_class #32770
    if(winpid)
        Process, Close , %winpid%
    else{
        run,SndVol.exe
    }
return

;判断焦点
Existclass(class){
    MouseGetPos,,,win
    WinGet,winid,id,%class%
    if win = %winid%
        Return,1
    else
        Return,0
}

;判断是否在任务栏
ExistisShell(){
Return (Existclass("ahk_class Shell_TrayWnd") or Existclass("ahk_class Shell_SecondaryTrayWnd"))
}

;提示定时消失
RemoveToolTip:
    ToolTip
return

;调节亮度
MoveBrightness(IndexMove){
    VarSetCapacity(SupportedBRightness, 256, 0)
    VarSetCapacity(SupportedBRightnessSize, 4, 0)
    VarSetCapacity(BRightnessSize, 4, 0)
    VarSetCapacity(BRightness, 3, 0)

    hLCD := DllCall("CreateFile", Str, "\\.\LCD"
    , UInt, 0x80000000 | 0x40000000 ;Read | Write
    , UInt, 0x1 | 0x2 ; File Read | File Write
    , UInt, 0
    , UInt, 0x3 ; open any existing file
    , UInt, 0
    , UInt, 0)

    if hLCD != -1
    {
        DevVideo := 0x00000023, BuffMethod := 0, Fileacces := 0
        NumPut(0x03, BRightness, 0, "UChar") ; 0x01 = Set AC, 0x02 = Set DC, 0x03 = Set both
        NumPut(0x00, BRightness, 1, "UChar") ; The AC bRightness level
        NumPut(0x00, BRightness, 2, "UChar") ; The DC bRightness level
        DllCall("DeviceIoControl"
        , UInt, hLCD
        , UInt, (DevVideo<<16 | 0x126<<2 | BuffMethod<<14 | Fileacces) ; IOCTL_VIDEO_QUERY_DISPLAY_BRIGHTNESS
        , UInt, 0
        , UInt, 0
        , UInt, &Brightness
        , UInt, 3
        , UInt, &BrightnessSize
        , UInt, 0)

        DllCall("DeviceIoControl"
        , UInt, hLCD
        , UInt, (DevVideo<<16 | 0x125<<2 | BuffMethod<<14 | Fileacces) ; IOCTL_VIDEO_QUERY_SUPPORTED_BRIGHTNESS
        , UInt, 0
        , UInt, 0
        , UInt, &SupportedBrightness
        , UInt, 256
        , UInt, &SupportedBrightnessSize
        , UInt, 0)

        ACBRightness := NumGet(BRightness, 1, "UChar")
        ACIndex := 0
        DCBRightness := NumGet(BRightness, 2, "UChar")
        DCIndex := 0
        BufferSize := NumGet(SupportedBRightnessSize, 0, "UInt")
        MaxIndex := BufferSize-1

        loop, %BufferSize%{
            ThisIndex := A_Index-1
            ThisBRightness := NumGet(SupportedBRightness, ThisIndex, "UChar")
            if ACBRightness = %ThisBRightness%
                ACIndex := ThisIndex
            if DCBRightness = %ThisBRightness%
                DCIndex := ThisIndex
        }

        if DCIndex >= %ACIndex%
            BRightnessIndex := DCIndex
        else
            BRightnessIndex := ACIndex

        BRightnessIndex += IndexMove

        if BRightnessIndex > %MaxIndex%
            BRightnessIndex := MaxIndex

        if BRightnessIndex < 0
            BRightnessIndex := 0

        TempLight := Floor(BRightnessIndex / MaxIndex *100)	;以提示方式显示当前亮度 修改 by shinyship
        CoordMode, ToolTip
        ToolTip,----- 亮度：%TempLight% -----,0, 0
        SetTimer, RemoveToolTip, -1000

        NewBRightness := NumGet(SupportedBRightness, BRightnessIndex, "UChar")
        NumPut(0x03, BRightness, 0, "UChar") ; 0x01 = Set AC, 0x02 = Set DC, 0x03 = Set both
        NumPut(NewBRightness, BRightness, 1, "UChar") ; The AC bRightness level
        NumPut(NewBRightness, BRightness, 2, "UChar") ; The DC bRightness level

        DllCall("DeviceIoControl"
        , UInt, hLCD
        , UInt, (DevVideo<<16 | 0x127<<2 | BuffMethod<<14 | Fileacces) ; IOCTL_VIDEO_SET_DISPLAY_BRIGHTNESS
        , UInt, &Brightness
        , UInt, 3
        , UInt, 0
        , UInt, 0
        , UInt, 0
        , Uint, 0)

        DllCall("CloseHandle", UInt, hLCD)
    }
}

#IfWinActive ahk_class Shell_SecondaryTrayWnd 
A:: ;A：上一首歌
    Send {Media_Prev}
    ToolTip,- 上一首歌 -,0, 0
    SetTimer, RemoveToolTip, -1000
return

D:: ;D：下一首歌
    Send {Media_Next}
    ToolTip,- 下一首歌 -,0, 0
    SetTimer, RemoveToolTip, -1000
return

space:: ;空格：暂停与开始
    Send {Media_Play_Pause}
    ToolTip,- 暂停与开始 -,0, 0
    SetTimer, RemoveToolTip, -1000
return

W:: ;W：喜欢该歌曲
    Send {Ctrl Down}{Alt Down}p{Alt Up}{Ctrl Up}
    ToolTip,- 收藏 -,0, 0
    SetTimer, RemoveToolTip, -1000
return

q:: ;任务框点击q 隐藏、显示桌面图标！
    HideOrShowDesktopIcons()
return