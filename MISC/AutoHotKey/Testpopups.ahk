#Persistent
SetTimer, Check4popups ;It will check every 250 ms
;MsgBox TrackType
Return

;-------------------------------------------------------------------------------
Check4popups: ; auto-close the popup window
;-------------------------------------------------------------------------------
    If WinExist("Untitled - Notepad ahk_exe Notepad.exe")
        {
            WinClose   
            TrackType = "Notepad was it"
            ;MsgBox TrackType
            Return 
        }

    If WinExist("Calculator ahk_exe ApplicationFrameHost.exe")
        {
            WinClose   
            TrackType = "Notepad was it"
            ;MsgBox TrackType
            Return 
        }

    If WinExist("Alarms & Clock")
        {
            WinClose   
            TrackType = "Notepad was it"
            ;MsgBox TrackType
            Return 
        }

    If WinExist("Calculator ahk_exe ApplicationFrameHost.exe")
        {
            WinClose   
            TrackType = "Notepad was it"
            ;MsgBox TrackType
            Return 
        }

Return

;-------------------------------------------------------------------------------
;LogFile(name) ; Write a single line in log file
;-------------------------------------------------------------------------------

;FormatTime, CurrentDateTime,, yyyy-MM-dd HH:mm 
;FileAppend,  ====`r`n %CurrentDateTime% , C:\SCRIPTS\LOGS\AutoHotKeyLogs.txt 