#SingleInstance force
#Persistent
#NoEnv

; 该代码适用于
; 2560 x 1600 无边框原神

;====初始化====
Func.RunInAdmin()
;Genshin.Opengame()
Db.init()
Db.tip()

; 全屏位置函数
class Loc{
    static Tip={x:0,y:0} ;期望tip出现的位置
    static Eye = {x:276,y:27} ;游戏内的眼睛图标（暂时没有使用的函数）
    static Pick1 = {x:1505,y:807} ;选择框出现时会出现的两个白点（分别对应只有1个和多个选择）
    static Pick2 = {x:1414,y:818} ;多个选择会出现鼠标
    static Trans = {x:1959,y:1507} ;点击传送：0xFFCC33
    static Option = {x:1728,y:1219} ;第一个选项的位置
    static Concentrate = {x:525,y:649} ;浓缩树脂的位置
    ;钓鱼
    static fish1 = {x:898,y:215} ;鱼是否上钩的位置
    static fish2 = {x1:710,x2:1211,i:148,y:160} ;方格块
    static fish3 = {x:1741,y:1029} ;换鱼饵的右键

    ;升级圣遗物
    static quickInsertion = {x:1737,y:766} ;点击快捷放入
    static upgrade = {x:1753,y:1030} ;点击升级
    static upgradeEnter = {x:970,y:830} ;点击确定
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
        Db.add("7","升级圣遗物")
        ; Db.add("Y","解控")
        Db.add("[","钓鱼")
        Db.add("0","跳过")
        ; Db.add("G","宵钟")
        Db.add("6","临时")
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

    ;打开SnapHutao
    Opengame(){
        ysHelp:=Genshin.ysHelpIsRun()
        if(!ysHelp){
            run C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command "Start-Process shell:AppsFolder\60568DGPStudio.SnapHutao_wbnnev551gwxy!App -verb runas
        }
    }
}

;====交互相关函数====
class Mutu{
}

;====识别相关函数====
class View{
    ;检查是否出现对话框0：没有眼睛标志1：有眼睛标志，是对话框
    ptolk(){
        return Func.GetColor(Loc.Eye.x,Loc.Eye.y)=="0xFFFFFF"
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

;===攻击函数==
class Attack{
    ;是否可以攻击: true:可以攻击
    isAttack(str){
        num:=Db.find(str)
        return (Db.Array[num] == true && WinActive("ahk_exeYuanShen.exe"))
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

        x2:=Loc.Concentrate.x
        y2:=Loc.Concentrate.y
        if(Func.GetColor(x2,y2)=="0x4A5366")
            Click %x2%,%y2%
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

    ; ;G键凑四
    ; G::
    ;     num:=Db.find("G")
    ;     Db.Array[num]:=!Db.Array[num]
    ;     Db.tip()
    ;     if(Db.Array[num])
    ;         SetTimer,G_lable,200
    ;     else
    ;         SetTimer,G_lable,Off
    ; return

    ; G_lable:
    ;     num:=Db.find("G")
    ;     if(!Db.Array[num]){
    ;         SetTimer,G_lable,Off
    ;         Db.tip()
    ;     }
    ;     if(Genshin.isActive()){
    ;         ;钟离套盾 
    ;         if(Attack.isAttack("G")){
    ;             Attack.changeP(1)
    ;             Attack.LongE()
    ;             sleep 400
    ;         }

    ;         ;芙宁娜开e
    ;         if(Attack.isAttack("G")){
    ;             Attack.changeP(2)
    ;             Attack.ShortE()
    ;             sleep 1200
    ;         }

    ;         ;神子开e
    ;         if(Attack.isAttack("G")){
    ;             Attack.changeP(3)
    ;             Attack.ShortE()
    ;             sleep 600
    ;             Attack.ShortE()
    ;             sleep 600
    ;             Attack.ShortE()
    ;             sleep 1200
    ;         }

    ;         ;瑶瑶短E
    ;         if(Attack.isAttack("G")){
    ;             Attack.changeP(4)
    ;             Attack.ShortE()
    ;             sleep 1200
    ;         }

    ;         sleep 1000
    ;     }
    ; return

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

    ;[键钓鱼
    [::
        num:=Db.find("[")
        Db.Array[num]:=!Db.Array[num]
        Db.tip()
        if(Db.Array[num])
            SetTimer,X_lable,50
        else
            SetTimer,X_lable,Off
    return

    X_lable:
        num:=Db.find("[")
        if(!Db.Array[num]){
            SetTimer,X_lable,Off
            Db.tip()
        }
        if(Genshin.isActive()){

            ;《Location》进度条的三个点
            x1:=Loc.fish2.x1
            x2:=Loc.fish2.x2
            i:=Loc.fish2.i
            y:=Loc.fish2.y
            PixelSearch Xzs,,x1,i,x2,i,0xFFFFC0,1,FastRGB ;确定I型标志：从左向右判断（x,y）
            PixelSearch Xzo,,x2,y,x1,y,0xFFFFC0,1,FastRGB ;确定右边距：从右向左判断（x,y）

            x1:=Loc.fish3.x
            y1:=Loc.fish3.y

            ;判断是否为吊杆状态
            if(Func.GetColor(x1,y1)=="0xFFE82C"){
                sleep 5000
                if(Func.GetColor(x1,y1) == "0xFFE82C"){
                    Click
                    sleep 2000
                }
            }

            x1:=Loc.fish1.x
            y1:=Loc.fish1.y
            ;判断鱼是否上钩
            if(Func.GetColor(x1,y1)=="0xFFFFFF"){
                sleep 20
                if(Func.GetColor(x1,y1) == "0xFFFFFF"){
                    Click
                    sleep 50
                }
            }

            ;保持间距
            if(Xzo-Xzs>30){
                SendInput {LButton down}
                Sleep 50
                SendInput {LButton up}
            }
        }
    return

    ;7键凑升级圣遗物
    7::
        num:=Db.find("7")
        Db.Array[num]:=!Db.Array[num]
        Db.tip()
        if(Db.Array[num])
            SetTimer,7_lable,200
        else
            SetTimer,7_lable,Off
    return

    7_lable:
        num:=Db.find("7")
        if(!Db.Array[num]){
            SetTimer,7_lable,Off
            Db.tip()
        }

        if(Db.Array[num]){

            x:=Loc.quickInsertion.x
            y:=Loc.quickInsertion.y
            Click, %x%,%y%
        }

        Sleep 20

        if(Db.Array[num]){
            x:=Loc.upgrade.x
            y:=Loc.upgrade.y
            Click, %x%,%y%
        }

        Sleep 3000

        if(Db.Array[num]){
            x:=Loc.upgradeEnter.x
            y:=Loc.upgradeEnter.y
            Click, %x%,%y%
        }
    return

    ;6键临时
    6::
        num:=Db.find("6")
        Db.Array[num]:=!Db.Array[num] 
        Db.tip()
        if(Db.Array[num])
            SetTimer,6_lable,200
        else
            SetTimer,6_lable,Off
    return

    6_lable:
        num:=Db.find("6")
        if(!Db.Array[num]){
            SetTimer,6_lable,Off
            Db.tip()
        }

        if(Db.Array[num]){
            SendInput {a Down}
            Sleep 100
            SendInput {a Up}
            Click
            Sleep 300
        }

        if(Db.Array[num]){
            SendInput {a Down}
            Sleep 100
            SendInput {a Up}
            Click
            Sleep 300
        }

        if(Db.Array[num]){
            SendInput {a Down}
            Sleep 100
            SendInput {a Up}
            Click
            Sleep 300
        }

        if(Db.Array[num]){
            SendInput {a Down}
            Sleep 100
            SendInput {a Up}
            Click
            Sleep 300
        }

        if(Db.Array[num]){
            SendInput {d Down}
            Sleep 100
            SendInput {d Up}
            Click
            Sleep 300
        }

        if(Db.Array[num]){
            SendInput {d Down}
            Sleep 100
            SendInput {d Up}
            Click
            Sleep 300
        }

        if(Db.Array[num]){
            SendInput {d Down}
            Sleep 100
            SendInput {d Up}
            Click
            Sleep 300
        }

        if(Db.Array[num]){
            SendInput {d Down}
            Sleep 100
            SendInput {d Up}
            Click
            Sleep 300
        }

        ; if(Db.Array[num]){
        ; }
    return