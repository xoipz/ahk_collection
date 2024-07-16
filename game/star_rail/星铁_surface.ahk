#SingleInstance force
#Persistent
#NoEnv

;====Init====
Func.RunInAdmin()
; StarRail.Opengame()
Db.init()
Db.tip()

;====Location====
class Loc{
    static Tip = {x:0,y:0}
    static Option = {x:1775,y:1160} ;第一个选项的位置
    static Msg2 = {x:1917,y:1063} ;任务弹出短信的位置
    static Msg = {x:978,y:775} ;短信的位置
}

;====DataBase====
class Db {
    static Length:=0
    static cArray:=[] ;字符保存
    static sArray:=[] ;字段保存
    static Array:=[] ;开关保存

    ;储存池初始化
    init(){
        Db.add("0","跳过")
        Db.add("9","短信")
        Db.add("8","弹出短信")
        Db.add("En","禁用热键")
        Suspend,On
    }

    ;添加数据
    add(key,name){
        Db.cArray[Db.Length] := key
        Db.sArray[Db.Length] := name
        Db.Array[Db.Length] := 0
        Db.Length++
    }

    ;查找索引
    find(char){
        for index,element in Db.cArray{
            if(char == element){
                return index
            }
        }
    }

    ;打开提示
    tip(){
        tipopen:=0
        str:=" "
        for index,element in Db.Array{
            En:=Db.Array[index]
            if(En) {
                tipopen:=1
            }
            str.= En ? " " . Db.sArray[index] . " " : " -" . Db.cArray[index] . "- "
        }
        x:=Loc.Tip.x
        y:=Loc.Tip.y
        ToolTip %str% ,%x%,%y%
        if(!tipopen){
            sleep 1000
            ToolTip
        }
    }

    ;关闭tip
    closeTip(){
        ToolTip
    }

}

;====StarRail Methon====
class StarRail {
    ;星铁主程序是否运行
    ; TODO:这里会检测到unity类型的游戏
    srMainIsRun(){
        return Func.isRun("UnityWndClass")
    }

    ;判断星铁是否为焦点
    isActive(){
        return WinActive("ahk_exe StarRail.exe")
    }

    ;打开SnapHutao
    Opengame(){
        ysHelp:=StarRail.ysHelpIsRun()
        if(!ysHelp){
            run C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command "Start-Process shell:AppsFolder\60568DGPStudio.SnapHutao_ebfp3nyc27j86!App -verb runas
        }
    }
}

;====Mutu====
class Mutu{
}

;====View====
class View{
}

;====Global Methon====
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
    RAlt::
        Suspend,off
        num:=Db.find("En")
        Db.Array[num] := false
        Db.tip()
    return

    ;跳过对话
    0::
        num:=Db.find("0")
        Db.Array[num]:=!Db.Array[num]
        Db.tip()
        if(Db.Array[num])
            SetTimer,R_lable,200
        else
            SetTimer,R_lable,Off
    return

    R_lable:
        num:=Db.find("0")
        if(!Db.Array[num]){
            SetTimer,R_lable,Off
            Db.tip()
        }else if(StarRail.isActive()){
            x:=Loc.Option.x
            y:=Loc.Option.y
            Click, %x%,%y%
        }
    return

    ;短信
    9::
        num:=Db.find("9")
        Db.Array[num]:=!Db.Array[num]
        Db.tip()
        if(Db.Array[num])
            SetTimer,night_lable,200
        else
            SetTimer,night_lable,Off
    return

    night_lable:
        num:=Db.find("9")
        if(!Db.Array[num]){
            SetTimer,night_lable,Off
            Db.tip()
        }else if(StarRail.isActive()){
            x:=Loc.Msg.x
            y:=Loc.Msg.y
            Click, %x%,%y%
        }
    return

    ;任务弹出短信
    8::
        num:=Db.find("8")
        Db.Array[num]:=!Db.Array[num]
        Db.tip()
        if(Db.Array[num])
            SetTimer,eight_lable,200
        else
            SetTimer,eight_lable,Off
    return

    eight_lable:
        num:=Db.find("8")
        if(!Db.Array[num]){
            SetTimer,eight_lable,Off
            Db.tip()
        }else if(StarRail.isActive()){
            x:=Loc.Msg2.x
            y:=Loc.Msg2.y
            Click, %x%,%y%
        }
    return

    w_state := true

    RButton::
        if w_state {
            Send, {w down}
            Sleep, 10
            Send, {ShiftDown}
            Send, {ShiftUp}
            w_state := false
        }else{
            Send, {w up}
            w_state := true
        }
    return

    MButton:: ; 鼠标中键的热键指令
        Send, {Alt down} ; 如果 Alt 键目前是按下的，松开它
    return

    !MButton:: ; Alt + 鼠标右键的热键指令
        Send, {Alt up} ; 如果 Alt 键目前未被按下，按下它
        Sleep, 10
        Send, {CtrlDown}
        Send, {CtrlUp}
    return