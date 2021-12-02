#Windows Server restart / shutdown history
Get-EventLog -LogName System |? {$_.EventID -in (6005,6006,6008,6009,1074,1076)} | ft TimeGenerated,EventId,Message -AutoSize –wrap