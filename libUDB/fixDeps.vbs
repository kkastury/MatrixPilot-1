' fixDeps.vbs
' 
' Work around an MPLab bug in dependency checking by comparing file modification dates
' for 2 files, and updating the 2nd file's mod date if it's older.
' 
' Add the following command as your Pre-Build Step in your MPLab project file
' This is in Project -> Build Options... -> Project -> Custom Build
' 
' cscript "$(ProjectDir)..\libUDB\fixDeps.vbs" "$(ProjectDir)options.h" "$(ProjectDir)..\libUDB\fixDeps.h"


Dim srcPath
Dim destPath
srcPath = WScript.Arguments.Item(0)
destPath = WScript.Arguments.Item(1)

Dim path, file, recentDate, recentFile
Set recentFile = Nothing

Set objFSO = Createobject ("Scripting.FileSystemObject")

For Each file in objFSO.GetFolder(srcPath).Files
	WScript.Echo file
	If (recentFile is Nothing) Then
		Set recentFile = file
	ElseIf (file.DateLastModified > recentFile.DateLastModified) Then
		Set recentFile = file
	End If
Next

If recentFile is Nothing Then
	WScript.Echo "no recent files"
Else
	WScript.Echo "Recent file is " & recentFile.Name & " " & recentFile.DateLastModified
End If

If (Not objFSO.FileExists(destPath)) Then
	WriteDestFile(destPath)
Else
'	Set objSrcFile = objFSO.GetFile(srcPath & "\options.h")
	Set objSrcFile = objFSO.GetFile(recentFile)
	Set objDestFile = objFSO.GetFile(destPath)
	If (objSrcFile.DateLastModified > objDestFile.DateLastModified) Then
		WriteDestFile(destPath)
	End If
End If

Sub WriteDestFile(path)
	Set F = objFSO.OpenTextFile(path, 2, True)
	F.Write "// This file is autogenerated at build time by libUDB/fixDeps.vbs" & vbCr & vbLf
	F.Write "#define LIBUDB_FIX_DEPS" & vbCr & vbLf
	F.Close
	WScript.Echo "updated module: " & path
End Sub

