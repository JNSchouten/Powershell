$version    = "0.2"

#region Diagnostic & variables
$global:testRun = $false  # Set to $true to run without actions
$global:debug   = $false  # Set to $true for verbose output

$usr ="gas2"

$DFSroot = "\\DM100.local\TSProfiles$"
$TSprofile1 = "\\vbwnlfs009\tsprofiles011$"
$TSprofile2 = "\\vbwnlfs010\tsprofiles021$"
$TSprofile = $TSprofile2
$drive1 = (New-Object -com scripting.filesystemobject).getdrive("$TSprofile1")
$drive2 = (New-Object -com scripting.filesystemobject).getdrive("$TSprofile2")
if ($drive1.freespace -le $drive2.freespace) {
    # set least used drive
    $TSprofile = $TSprofile1
}

#Get user properties
$user = Get-ADUser $usr -Properties ScriptPath,Enabled

if ($user.Enabled) {
    write-host "User is enabled"
    #Set users Citrix loginscript
    if ($user.ScriptPath -ne "Logon.cmd") {
        Set-ADUser $user.SamAccountName -ScriptPath Logon.cmd -WhatIf:$testRun
        write-host "Citrix Loginscript set"
    } else {
        write-host "Citrix Loginscript already set"
    }
    #Check TSProfile
    if (Test-Path "$DFSroot\$($user.SamAccountName)") {
        Write-Host "TSProfile already set"
        $acl = Get-Acl $dfsTarget
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($user.SamAccountName,'FullControl','ContainerInherit, ObjectInherit', 'None',"Allow")
        $acl.SetAccessRule($AccessRule)
        $acl | Set-Acl "$TSprofile2\$($user.SamAccountName)" -WhatIf:$testRun
    } else {
        Write-Host "Use $tsprofile"
        $dfsTarget = "$TSprofile\$($user.SamAccountName)"
        Write-Host $dfsTarget
        $dfsPath = "$DFSroot\$($user.SamAccountName)"
        Write-Host $dfsPath
        $dfsPriv = '"DLG_MGT_Manage TSProfiles":RX "DLG_MGT_Modify TSProfiles":RX "DLG_MGT_View TSProfiles":RX "dm100\' + $user.SamAccountName + '":RX Protect Replace'
        If (Test-Path $dfsTarget){
            Write-Host "Home folder exists"
        } else {
            Write-Host "Create Home folder"
            New-Item -Path $TSprofile -Name $user.SamAccountName -ItemType "directory" -WhatIf:$testRun
        }
        $acl = Get-Acl $dfsTarget
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($user.SamAccountName,'FullControl','ContainerInherit, ObjectInherit', 'None',"Allow")
        $acl.SetAccessRule($AccessRule)
        $acl | Set-Acl $dfsTarget -WhatIf:$testRun
        If (Test-Path dfsTarget) {
            Write-Host "TSProfile exists"
        } else {
            Write-Host "Create TSProfile"
            # Create DFSn
            New-DfsnFolder -Path $dfsPath -TargetPath $dfsTarget -State 'Online' -TargetState 'Online' -WhatIf:$testRun
            Start-Process -FilePath "c:\windows\system32\dfsutil.exe" -ArgumentList "property SD grant $dfsPath $dfsPriv" -WhatIf:$testRun
        }
    }
} else {
    write-host "user is disabled; cleanup"
    $dfsTarget = $null
    #Set users Citrix loginscript
    if ($null -eq $user.ScriptPath ) {
        Set-ADUser $user.SamAccountName -ScriptPath $null -WhatIf:$testRun
        write-host "Citrix Loginscript removed"
    }
    #Check TSProfile
    if (!(Test-Path "$DFSroot\$($user.SamAccountName)")) {
        Write-Host "Remove TSProfile"
        $dfsTarget = Get-DfsnFolder -Path "$DFSroot\$($user.SamAccountName)" | Select-Object -ExpandProperty TargetPath
        Remove-DfsnFolder -Path "$DFSroot\$($user.SamAccountName)" -Force:$true -WhatIf:$testRun
    }
    If (Test-Path $dfsTarget){
        Write-Host "Remove home folder"
        if (Test-Path $dfsPath) {
            Write-Host "Home folder exists"
            
        }
    }

}
