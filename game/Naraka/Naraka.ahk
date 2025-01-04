#SingleInstance force
#Persistent
#NoEnv

Func.RunInAdmin()
Db.init()
Db.tip()



class Loc{
    static Tip={x:0,y:0} 
}


class Db {
    static Length:=0
    static cArray:=[] 
    static sArray:=[] 
    static Array:=[] 

    
    init(){
        Db.add("K","jump")
        Db.add("En","禁用热键")
        Suspend,On
    }
    
    add(key,name){
        Db.cArray[Db.Length] := key
        Db.sArray[Db.Length] := name
        Db.Array[Db.Length] := 0
        Db.Length++
    }

    
    find(char){
        for index,element in Db.cArray{
            if(char == element){
                return index
            }
        }
    }

    
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

    
    closeTip(){
        ToolTip
    }
}


class Naraka {
    
    isActive(){
        return WinActive("ahk_class UnityWndClass") && WinActive("ahk_exe NarakaBladepoint.exe")
    }
}


class Func{
    
    isRun(program){
        WinGet,programs,PID,ahk_class %program%
        return programs
    }

    
    GetColor(x,y){
        PixelGetColor,color,x,y,RGB
        StringLeft color,color,10
        return color
    }

    
    RunInAdmin(){
        
        if not (A_IsAdmin or RegExMatch(DllCall("GetCommandLine","str")," /restart(?!\S)")){
            try 
            if A_IsCompiled
                Run *RunAs "%A_ScriptFullPath%" /restart
            else
                Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
            ExitApp
        }
    }
}



!p::ExitApp 
return

;#IfWinActive ahk_class NarakaBladepoint.exe
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

    
    RCtrl::
        Suspend,off
        num:=Db.find("En")
        Db.Array[num]:=0
        Db.tip()
    return

    RAlt::
        Suspend,off
        num:=Db.find("En")
        Db.Array[num]:=0
        Db.tip()
    return

    
    
    End::
        num:=Db.find("K")
        Db.Array[num]:=!Db.Array[num]
        Db.tip()
        if(Db.Array[num])
            SetTimer,K_lable,200
        else
            SetTimer,K_lable,Off
    return

    K_lable:
        num:=Db.find("K")
        if(!Db.Array[num]){
            SetTimer,K_lable,Off
            Db.tip()
        } 
        else if (Naraka.isActive()) {
            if (Db.Array[num]) {
                Send {Space}
            }
            Sleep 700
            if (Db.Array[num]) {
                Send {Space}
            }
            Sleep 700
            if (Db.Array[num]) {
                Send c
            }
            Sleep 700
        }
    return

    ; 胡桃打药
    Home::
        num:=Db.find("K")
        Db.Array[num]:=!Db.Array[num]
        Db.tip()
        if(Db.Array[num])
            SetTimer,K_lable,200
        else
            SetTimer,K_lable,Off
    return

    K_lable:
        num:=Db.find("K")
        if(!Db.Array[num]){
            SetTimer,K_lable,Off
            Db.tip()
        } 
        else if (Naraka.isActive()) {
            if (Db.Array[num]) {
                Send {Space}
            }
            Sleep 700
            if (Db.Array[num]) {
                Send {Space}
            }
            Sleep 700
            if (Db.Array[num]) {
                Send c
            }
            Sleep 700
        }
    return