CoordMode, Mouse, Screen  ; 全局获取模式（鼠标坐标）
SetMouseDelay, 100
#MaxHotkeysPerInterval 200
#NoEnv

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

; F3 映射到 Win+Tab
$F3::
Send {LWin down}
Sleep 1
Send {Tab}
Sleep 1
Send {LWin up}
return