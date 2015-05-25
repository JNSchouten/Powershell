function Get-Hostname {
  param   (
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [String[]]$IP
  )
  
  process
  { $IP | ForEach-Object { try { [System.Net.DNS]::GetHostbyAddress($_) | Select-Object Hostname,@{Label='Aliases';expression={$_.Aliases}},@{Label='AddressList';expression={$_.AddressList}}  } catch { } }}
}
