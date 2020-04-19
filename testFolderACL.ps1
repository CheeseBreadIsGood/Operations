## Lets create Everyone rights to fine and modify CoalMine, Just add to the three folders only the rights to CoalMine
$FolderPathArray = @('C:\NoobehIT','C:\NoobehIT\ServerSetup','C:\NoobehIT\ServerSetup\CoalMine') #Ad Everyone to these Folders, so malware can find CoalMine
Foreach($FolderPath in $FolderPathArray){ 
$ACL = Get-Acl $FolderPath
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    'Everyone', #Identity
    'Modify', # Rights
    'None',   #inheritance  This folder only - None
    'None',   #propagation  NoPropagateInherit (the ACE is not propagated to any current child objects)
    'Allow')  #type set for everyone modify rights to folder
$ACL.AddAccessRule($AccessRule)  # Now add the new rule to the temp ACL object, but it is not set back onto the system yet.
Set-Acl $FolderPath -AclObject $ACL  #set it and forget it.
#########################################################################################endregion
}
