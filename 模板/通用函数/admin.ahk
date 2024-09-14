
;提升脚本为管理员权限
RunInAdmin(){
    ;如果脚本未提升，请以管理员身份重新启动并终止当前实例:
    if not (A_IsAdmin or RegExMatch(DllCall("GetCommandLine","str")," /restart(?!\S)")){
        try ;致脚本以管理员身份重新启动
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
        ExitApp
    }
}


