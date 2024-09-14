; 提升脚本为管理员权限
RunInAdmin(){
    ; 如果脚本未提升，请以管理员身份重新启动并终止当前实例:
    if not (A_IsAdmin or RegExMatch(DllCall("GetCommandLine","str")," /restart(?!\S)")){
        try ; 致脚本以管理员身份重新启动
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
        ExitApp
    }
}
RunInAdmin()


#a::
    ; 获取所有可见的窗口
    WinGet, id, List, , , Program Manager

    Loop, %id%
    {
        this_id := id%A_Index%
        WinGetTitle, title, ahk_id %this_id%
        if (title) ; 确保有标题才关闭
        {
            ; 关闭窗口，发送消息 WM_CLOSE (0x10)
            PostMessage, 0x112, 0xF060,,, ahk_id %this_id%
        }
    }
Return
