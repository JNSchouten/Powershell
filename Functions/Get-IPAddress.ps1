function Get-IPAddress {
  param   (
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [String[]]$Name
  )
  
  process
  { $Name | ForEach-Object { try { [System.Net.DNS]::GetHostByName($_) } catch { } }}
}
