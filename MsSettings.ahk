#Requires AutoHotkey v1.1.36+
#Include %A_ScriptDir%
#Include .\lib\getThreadLocalInputSettings.ahk
#Include .\lib\OSVersion.ahk
#Include .\lib\setWindowPlacement.ahk
#Include .\lib\winGetWhichMonitor.ahk
#Include .\vendor\UIA_Interface.ahk ;  Tested with https://github.com/Descolada/UIAutomation/blob/047e9ebf040c4e4a609a27bce26ab35a13dde95c/Lib/UIA_Interface.ahk
;==============================================================
; MsSettings — ms-settings launcher & UIAutomation-based navigation helpers
;
; GitHub: https://github.com/SevenKeyboard/ms-settings
; Author: SevenKeyboard Ltd. (2025)
; License: MIT License
;==============================================================
class VersionManager_MsSettings
{
    static _ := VersionManager_MsSettings._init()
    _init()    {
        global
        MSSETTINGS_VERSION := "2.0.0"
        if (!this._verCheck(GETTHREADLOCALINPUTSETTINGS_VERSION, "1.0.0"))
            throw exception("getThreadLocalInputSettings version 1.x is required (minimum 1.0.0).")
        if (!this._verCheck(OSVERSION_VERSION, "2.0.0"))
            throw exception("OSVersion version 2.x is required (minimum 2.0.0).")
        if (!this._verCheck(SETWINDOWPLACEMENT_VERSION, "1.0.0"))
            throw exception("setWindowPlacement version 1.x is required (minimum 1.0.0).")
        if (!this._verCheck(WINGETWHICHMONITOR_VERSION, "1.0.1"))
            throw exception("setWindowPlacement version 1.x is required (minimum 1.0.1).")
        return true
    }
    _verCheck(byRef actual, required)    {
        if !isSet(actual)
            return false
        actualMajor     := strSplit(actual, ".",, 2)[1]
        requiredMajor   := strSplit(required, ".",, 2)[1]
        if (actualMajor !== requiredMajor)
            return false
        return verCompare(actual, ">=" required)
    }
}
class MsSettings
{
    class Typing
    {
        run(byRef el:="", newMon:=0, maximize:=false)    {
            return MsSettings.run("typing", el,newMon,maximize)
        }
        runAdvancedKeyboardSettings(byRef el)    {
            if (!isObject(el))
                return false
            switch (OSVersion.WIN)
            {
                default:            return false
                case "WIN_10":
                    try    {
                        ;  3000ms
                        while (A_Index<=30) && !(btnEl:=el.findFirstBy("AutomationId=SystemSettings_Keyboard_Additional_Settings_DeviceTyping_HyperlinkButton"))
                            sleep 100
                        if (!btnEl)
                            return false
                        return btnEl.click()
                    }  catch  {
                        btnEl:=""
                        return false
                    }
                case "WIN_11":
                    try    {
                        ;  3000ms
                        while (A_Index<=30) && !(btn1El:=el.findFirstBy("AutomationId=SystemSettings_Keyboard_Additional_Settings_DeviceTyping_ButtonEntityItem"))
                            sleep 100
                        if (!btn1El)
                            return false
                        if !(btn2El:=btn1El.findFirstBy("AutomationId=EntityItemButton"))
                            return false
                        return btn2El.click()
                    }  catch  {
                        btn2El:=""
                        btn1El:=""
                        return false
                    }
            }
        }
        findThreadLocalInputSettingsCheckbox(byRef el, byRef cbEl:="")    {
            cbEl:=""
            if (!isObject(el))
                return false
            try    {
                ;  7000ms
                while (A_Index<=70) && !(cbEl:=el.findFirstBy("AutomationId=SystemSettings_Keyboard_InputLanguageSwitching_CheckBox"))
                    sleep 100
                return (!!cbEl)
            }  catch  {
                cbEl:=""
            }
        }
        setThreadLocalInputSettings(byRef cbEl, opt:="", sefFocus:=true)    {
            if (!isObject(cbEl))
                return false
            try    {
                if (sefFocus)    {
                    loop    {
                        sendInput % "{Tab}"
                        sleep 50
                    }  until (cbEl.HasKeyboardFocus || 8<A_Index)
                }
                if (opt!="" && getThreadLocalInputSettings()!=opt)
                    cbEl.click()
                return true
            }  catch  {
                cbEl:=""
                return false
            }
        }
    }
    class Keyboard
    {
        run(byRef el:="", newMon:=0, maximize:=false)    {
            return MsSettings.run("keyboard", el,newMon,maximize)
        }
        showAddProfileListView(byRef el, langName:="")    {
            if (!isObject(el))
                return false
            switch (OSVersion.WIN)
            {
                default:            return false
                case "WIN_10":
                    try    {
                        ;---------------------------------
                        ;  4000ms
                        while (A_Index<=10) && !(btnEl:=el.findFirstBy("AutomationId=SystemSettings_Language_Add_Profile_Language_Dialog_HyperlinkButton"))
                            sleep 400
                        if (!btnEl)
                            return false
                        btnEl.click()
                        ;---------------------------------
                        ;  800ms
                        if (langName!="")    {
                            while (A_Index<=2) && !(editEl:=el.findFirstBy("AutomationId=SystemSettings_Language_Add_Profile_Language_Dialog_DisplayStringValue"))
                                sleep 400
                            if (!editEl)
                                return false
                            editEl.setValue(langName)
                            sleep 400
                            sendEvent % "+{End}"
                        }
                        return true
                    }  catch  {
                        editEl:=""
                        btnEl:=""
                        return false
                    }
                case "WIN_11":
                    try    {
                        ;---------------------------------
                        ;  4000ms
                        while (A_Index<=10) && !(btnEl:=el.findFirstBy("AutomationId=SystemSettings_Language_Add_Profile_Language_Dialog_Button"))
                            sleep 400
                        if (!btnEl)
                            return false
                        btnEl.click()
                        ;---------------------------------
                        ;  800ms
                        if (langName!="")    {
                            while (A_Index<=2) && !(editEl:=el.findFirstBy("AutomationId=SystemSettings_Language_Add_Profile_Language_Dialog_DisplayStringValue"))
                                sleep 400
                            if (!editEl)
                                return false
                            editEl.setValue(langName)
                            sleep 400
                            sendEvent % "+{End}"
                        }
                        return true
                    }  catch  {
                        editEl:=""
                        btnEl:=""
                        return false
                    }
            }
        }
    }
    /*
    waitClose(hWnd:=0)    {
        if (!hWnd)    {
            if !(hWnd:=winExist("ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe"))
                return false
        }
        ;  winWaitClose % "ahk_id " hWnd
        ;  return (!ErrorLevel)
        while (winExist("ahk_id " hWnd))    {
            critical Off
            sleep -1
        }
        return true
    }
    */
    run(url:="", byRef el:="", newMon:=0, maximize:=false)    {
        global UIA
        static SW_MAXIMIZE:=3, SW_RESTORE:=9
        el:=""
        ;---------------------------------
        hWnd:=winExist("ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
        run % "ms-settings:" url,, UseErrorLevel
        if (ErrorLevel || !isObject(UIA))
            return false
        ;---------------------------------
        hWnd:=0
        switch
        {
            case (hWnd):
                sleep 200
                winWait % "ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe",, 0.8
                if (!ErrorLevel)
                    hWnd:=winExist()
                ;  winWaitClose % "ahk_id " hWnd,, 0.8
                ;  hWnd:=winExist("ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
            default:
                winWait % "ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe",, 0.8
                if (!ErrorLevel)
                    hWnd:=winExist()
        }
        if (!hWnd)
            return false
        ;---------------------------------
        try    {
            ;  1800ms
            while (A_Index<=18) && !(el:=UIA.elementFromHandle(hWnd))
                sleep 100
            if (!el)
                return false
            switch
            {
                default:
                    monMatch:=false
                    sysGet monWA, MonitorWorkArea
                case (newMon):
                    if (newMon==-1)    {
                        newMon:= currMon:= winGetWhichMonitor(hWnd)
                        monMatch:=true
                    }  else  {
                        currMon:=winGetWhichMonitor(hWnd)
                        monMatch:=(currMon==newMon)
                    }
                    sysGet monWA, MonitorWorkArea, % newMon
            }
            w:=floor((monWARight-monWALeft)*0.75), h:=floor((monWABottom-monWATop)*0.75), x:=floor(monWALeft+(monWARight-monWALeft-w)/2), y:=floor(monWATop+(monWABottom-monWATop-h)/2)
            mbs:={}
            mbs.showCmd:=(maximize?SW_MAXIMIZE:SW_RESTORE)
            mbs.rcNormalPosition:={}
            mbs.rcNormalPosition.left:=x, mbs.rcNormalPosition.top:=y, mbs.rcNormalPosition.right:=x+w, mbs.rcNormalPosition.bottom:=y+h
            if (maximize && !monMatch)    {
                winGet minMax, MinMax, % "ahk_id " hWnd
                if (minMax)
                    winRestore % "ahk_id " hWnd
            }
            loop % (monMatch?1:2)
                setWindowPlacement(hWnd, mbs)
            return format("{:d}",hWnd)
        }  catch  {
            el:=""
            return false
        }
    }
}