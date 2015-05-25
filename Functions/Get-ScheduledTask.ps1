function Get-ScheduledTask {
   [CmdletBinding()]
   param(
     [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
     [String[]]$ComputerName,

     [Parameter(Mandatory=$false)]
     [String[]]$RunAsUser,

     [Parameter(Mandatory=$false)]
     [String[]]$TaskName,

     [parameter(Mandatory=$false)]
     [alias("WS")]
     [switch]$WithSpace
   )

   Begin {
      $Script:Tasks = @()
   }

   Process {
      $schtask = schtasks.exe /query /s $ComputerName  /V /FO CSV | ConvertFrom-Csv
      Write-Verbose  "Getting scheduled Tasks from: $ComputerName"

      if ($schtask) {
         foreach ($sch in $schtask) {
            if ($sch."Run As User" -match "$($RunAsUser)" -and $sch.TaskName -match "$($TaskName)") {
               Write-Verbose  "$Computername ($sch.TaskName).replace('\','') $sch.'Run As User'"
               $sch  | Get-Member -MemberType Properties | ForEach -Begin {$hash=@{}} -Process {
                  If ($WithSpace) {
                     ($hash.($_.Name)) = $sch.($_.Name)
                  } Else {
                     ($hash.($($_.Name).replace(" ",""))) = $sch.($_.Name)
                  }
               } -End {
                  $script:Tasks += (New-Object -TypeName PSObject -Property $hash)
               }
            }
         }
      }
   } End {
      $Script:Tasks
   }
}
