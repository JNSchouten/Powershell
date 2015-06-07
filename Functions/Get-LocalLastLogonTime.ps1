function Get-LocalLastLogonTime {
    param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)][string[]] $ComputerName,
    [Parameter(Mandatory=$true)][string[]] $UserName)
 
    begin {
        $SelectSplat = @{
            Property = @('ComputerName','UserName','LastLogin','Error')
        }
    }
 
    process {
        foreach ($Computer in $ComputerName) {
            if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                foreach ($User in $UserName) {
                    $ObjectSplat = @{
                        ComputerName = $Computer
                        UserName = $User
                        Error = $null
                        LastLogin = $null
                    }
                    $CurrentUser = $null
                    $CurrentUser = try {([ADSI]"WinNT://$computer/$user")} catch {}
                    if ($CurrentUser.Properties.LastLogin) {
                        $ObjectSplat.LastLogin = try {
                                            [datetime](-join $CurrentUser.Properties.LastLogin)
                                        } catch {
                                            -join $CurrentUser.Properties.LastLogin
                                        }
                    } elseif ($CurrentUser.Properties.Name) {
                    } else {
                        $ObjectSplat.Error = 'User not found'
                    }
                    New-Object -TypeName PSCustomObject -Property $ObjectSplat | Select-Object @SelectSplat
                }
            } else {
                $ObjectSplat = @{
                    ComputerName = $Computer
                    Error = 'Ping failed'
                }
                New-Object -TypeName PSCustomObject -Property $ObjectSplat | Select-Object @SelectSplat
            }
        }
    }
} 
