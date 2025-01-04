#SingleInstance force
#Persistent
#NoEnv

; 该代码适用于
; 2560 x 1600 无边框

;====Init====
Func.RunInAdmin()
Db.init()
Db.tip()

;====位置相关函数====
class Loc{
    static Del = {x:1867,y:316}
    static Lock = {x:1869,y:240}

}

;====星铁相关函数====
class StarRail {
    ;星铁主程序是否运行
    xtMainIsRun(){
        return Func.isRun("UnityWndClass")
    }

    ;判断星铁是否为焦点
    isActive(){
        return WinActive("ahk_exe StarRail.exe")
    }
}

;====基础函数====
class Func{
    ;判断程序是否运行
    isRun(program){
        WinGet,programs,PID,ahk_class %program%
        return programs
    }

    ;获取坐标xy处的色值
    GetColor(x,y){
        PixelGetColor,color,x,y,RGB
        StringLeft color,color,10
        return color
    }

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

}

;==按键映射==

!p::ExitApp ;强制退出
return

#IfWinActive ahk_exe StarRail.exe
    ;禁用所有的热键和热字串.（打字用）
    ~Enter::
        Suspend,On
        num:=Db.find("En")
        Db.Array[num] := true
        Db.tip()
        sleep 1000
        if(Db.Array[num] == true){
            Db.closeTip()
        }
    return

    ;启用所有的热键和热字串.（打字用）
    RCtrl::
        Suspend,off
        num:=Db.find("En")
        Db.Array[num] := false
        Db.tip()
    return

    RAlt::
        Suspend,off
        num:=Db.find("En")
        Db.Array[num] := false
        Db.tip()
    return

    ;锁定
    z::
        if (StarRail.isActive()) {
            ; 记录当前位置
            MouseGetPos, curX, curY ; 获取当前鼠标位置并存储到 curX 和 curY 变量中

            ; 点击锁定位置
            x:=Loc.Lock.x
            y := Loc.Lock.y
            Click, %x%, %y%
            sleep 100

            ; 返回之前的位置
            MouseMove, %curX%, %curY% ; 返回之前的鼠标位置
        }
    return

    ; 解锁
    c::
        if (StarRail.isActive()) {
            ; 记录当前位置
            MouseGetPos, curX, curY ; 获取当前鼠标位置并存储到 curX 和 curY 变量中

            ; 点击锁定位置
            x:=Loc.Del.x
            y := Loc.Del.y
            Click, %x%, %y%
            sleep 100

            ; 返回之前的位置
            MouseMove, %curX%, %curY% ; 返回之前的鼠标位置
        }
    return
