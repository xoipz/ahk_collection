#SingleInstance force
#Persistent
#NoEnv

; 该代码适用于
; 1920 x 1080 无边框

;====初始化====
Func.RunInAdmin()
Db.init()
Db.tip()

;====位置相关函数====
; 1080
class Loc{
    static Tip={x:0,y:0} ;期望tip出现的位置
    static Option = {x:1302,y:804} ;第一个选项的位置
    static Pick1 = {x:1130,y:546} ;选择框出现时会出现的两个白点（分别对应只有1个和多个选择）
    static Pick2 = {x:1060,y:553} ;多个选择会出现鼠标
    static Trans = {x:1478,y:1003} ;点击传送：0xFFCC33
}

;====数据储存池====
class Db {
    static Length:=0
    static cArray:=[] ;字符保存
    static sArray:=[] ;字段保存
    static Array:=[] ;开关保存

    ;储存池初始化
    init(){
        Db.add("F","拾取")
        Db.add("U","跑步")
        Db.add("0","跳过")
        Db.add("9","打怪")
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

;====原神相关函数====
class Genshin {
    ;原神主程序是否运行
    ysMainIsRun(){
        return Func.isRun("UnityWndClass")
    }

    ;原神更新页面是否存在
    ysUpdateIsRun(){
        return Func.isRun("Qt5QWindowIcon")
    }

    ;原神辅助页面是否存在
    ysHelpIsRun(){
        return Func.isRun("WinUIDesktopWin32WindowClass")
    }

    ;判断原神是否为焦点
    isActive(){
        return WinActive("ahk_exe YuanShen.exe")
    }
}

;====交互相关函数====
class Mutu{
}

;====识别相关函数====
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

;===攻击函数==
class Attack{
    ;是否可以攻击: true:可以攻击
    isAttack(str){
        num:=Db.find(str)
        return (Db.Array[num] == true && Genshin.isActive())
    }

    ;换人 130ms
    changeP(num){
        sleep 30
        SendInput %num%
        sleep 140
    }

    ;短E 130ms
    ShortE(){
        sleep 30
        SendInput e
        sleep 100
    }

    ;长E 2130ms
    LongE(){
        sleep 30
        SendInput {e Down}
        Sleep 2000
        SendInput {e Up}
        sleep 100
    }

    ;平An次
    PA(num,str){
        index:=0
        while(index<num){
            if(Attack.isAttack(str)){
                Click
                sleep 300
            }
            index++
        }
    }

    ;大招 30ms
    Q(){
        sleep 30
        SendInput q
    }

}
;==按键映射==

!p::ExitApp ;强制退出
return

#IfWinActive ahk_exe YuanShen.exe
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

    ;F键自动拾取
    ~F::
        num:=Db.find("F")
        Db.Array[num]:=!Db.Array[num]
        Db.tip()
        if(Db.Array[num]){
            SetTimer,F_lable,100
        }else{
            SetTimer,F_lable,Off
        }
    return

    +F::
        num:=Db.find("F")
        Db.Array[num]:=!Db.Array[num]
        Db.tip()
        if(Db.Array[num])
            SetTimer,F_lable,100
        else
            SetTimer,F_lable,Off
    return

    F_lable:
        num:=Db.find("F")
        if(!Db.Array[num]){
            SetTimer,F_lable,Off
            Db.tip()
        }
        x1:=Loc.Pick1.x
        y1:=Loc.Pick1.y
        x2:=Loc.Pick2.x
        y2:=Loc.Pick2.y
        if(Func.GetColor(x1,y1)=="0xFFFFFF" or Func.GetColor(x2,y2)=="0xFFFFFF") and Genshin.isActive(){
            loop 5{
                SendInput f
                Sleep 20
                SendInput {WheelDown} ;下滑滚轮
                Sleep 20
            }
        }

        ;自动点击传送
        x1:=Loc.Trans.x
        y1:=Loc.Trans.y
        if(Func.GetColor(x1,y1)=="0xFFCC33") and Genshin.isActive() 
            Click %x1%,%y1%

        ; x2:=Loc.Concentrate.x
        ; y2:=Loc.Concentrate.y
        ; if(Func.GetColor(x2,y2)=="0x4A5366")
        ;     Click %x2%,%y2%
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
        }else if(Genshin.isActive()){
            x:=Loc.Option.x
            y:=Loc.Option.y
            Click, %x%,%y%
        }
    return

    ;9键打怪
    9::
        num:=Db.find("9")
        Db.Array[num]:=!Db.Array[num]
        Db.tip()
        if(Db.Array[num])
            SetTimer,9_lable,200
        else
            SetTimer,9_lable,Off
    return

    9_lable:
        num:=Db.find("9")
        if(!Db.Array[num]){
            SetTimer,9_lable,Off
            Db.tip()
        }
        if(Genshin.isActive()){
            ;钟离套盾 
            if(Attack.isAttack("9")){
                Attack.changeP(2)
                Attack.LongE()
                sleep 400
            }

            ;芙宁娜开e
            if(Attack.isAttack("9")){
                Attack.changeP(1)
                Attack.ShortE()
                sleep 1200
            }

            ;雷电开e
            if(Attack.isAttack("9")){
                Attack.changeP(3)
                Attack.ShortE()
                sleep 1000
            }

            ;瑶瑶短E
            if(Attack.isAttack("9")){
                Attack.changeP(4)
                Attack.ShortE()
                sleep 1200
            }

            sleep 1000
        }
    return

    ;U键长跑
    U::
        num:=Db.find("U")
        Db.Array[num]:=!Db.Array[num]
        Db.tip()
        SendInput {LShift Down}{w Down}
    return

    +U::
        num:=Db.find("U")
        Db.Array[num]:=!Db.Array[num]
        Db.tip()
        SendInput {LShift Up}{w Up}
    return



