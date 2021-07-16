#Persistent
SetTimer, Check4popups ;It will check every 250 ms
;MsgBox TrackType
Return

;-------------------------------------------------------------------------------
Check4popups: ; auto-close the popup window
;-------------------------------------------------------------------------------


    If WinExist("Calculator ahk_exe win32calc.exe")
        {
            WinClose   
            TrackType = "Notepad was it"
            ;MsgBox TrackType
            Return 
        }

    If WinExist("Untitled - Paint ahk_exe mspaint.exe")
        {
            WinClose   
            TrackType = "Notepad was it"
            ;MsgBox TrackType
            Return 
        }

    If WinExist("Warning ahk_class MauuiMessage") ;This is themes changed
        {
            WinClose   
            TrackType = "Notepad was it"
            ;MsgBox "Theme is Changed"
            Return 
	    ;Kill QB
	    ;Kill C:\Program Files (x86)\IRISXtract\Import\Import.exe
	    ;KILL C:\Program Files (x86)\IRISXtract\Export\Export.exe
	    ;KILL C:\Program Files (x86)\IRISXtract\Analyze\bin\Analyze.exe

	    ;RUN C:\Program Files (x86)\IRISXtract\Import\Import.exe
	    ;RUN C:\Program Files (x86)\IRISXtract\Export\Export.exe
	    ;RUN C:\Program Files (x86)\IRISXtract\Analyze\bin\Analyze.exe
        }

    If WinExist("Bank Feeds In Use")
        {
            WinClose   
            TrackType = "Notepad was it"
            ;MsgBox "Bank Feed in use"
            Return 
	    ;Kill QB
	    ;Kill C:\Program Files (x86)\IRISXtract\Import\Import.exe
	    ;KILL C:\Program Files (x86)\IRISXtract\Export\Export.exe
	    ;KILL C:\Program Files (x86)\IRISXtract\Analyze\bin\Analyze.exe

	    ;RUN C:\Program Files (x86)\IRISXtract\Import\Import.exe
	    ;RUN C:\Program Files (x86)\IRISXtract\Export\Export.exe
	    ;RUN C:\Program Files (x86)\IRISXtract\Analyze\bin\Analyze.exe
        }

    If WinExist("Feature in use")
        {
            WinClose   
            TrackType = "Notepad was it"
            ;MsgBox "Feature In use"
            Return 
	    ;Kill QB
	    ;Kill C:\Program Files (x86)\IRISXtract\Import\Import.exe
	    ;KILL C:\Program Files (x86)\IRISXtract\Export\Export.exe
	    ;KILL C:\Program Files (x86)\IRISXtract\Analyze\bin\Analyze.exe

	    ;RUN C:\Program Files (x86)\IRISXtract\Import\Import.exe
	    ;RUN C:\Program Files (x86)\IRISXtract\Export\Export.exe
	    ;RUN C:\Program Files (x86)\IRISXtract\Analyze\bin\Analyze.exe
        }

    If WinExist("QuickBooks Desktop Login")
        {
            WinClose   
            TrackType = "Notepad was it"
            ;MsgBox "QuickBooks Desktop Login"
            Return 
	    ;Kill QB
	    ;Kill C:\Program Files (x86)\IRISXtract\Import\Import.exe
	    ;KILL C:\Program Files (x86)\IRISXtract\Export\Export.exe
	    ;KILL C:\Program Files (x86)\IRISXtract\Analyze\bin\Analyze.exe

	    ;RUN C:\Program Files (x86)\IRISXtract\Import\Import.exe
	    ;RUN C:\Program Files (x86)\IRISXtract\Export\Export.exe
	    ;RUN C:\Program Files (x86)\IRISXtract\Analyze\bin\Analyze.exe
        }

Return

;-------------------------------------------------------------------------------
;LogFile(name) ; Write a single line in log file
;-------------------------------------------------------------------------------

;FormatTime, CurrentDateTime,, yyyy-MM-dd HH:mm 
;FileAppend,  ====`r`n %CurrentDateTime% , C:\SCRIPTS\LOGS\AutoHotKeyLogs.txt 