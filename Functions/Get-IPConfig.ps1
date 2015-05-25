function Get-IPConfig {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$False,ValueFromPipeline=$True)]
		[string[]]$Computername="LocalHost",
      [Parameter(Mandatory=$False)][bool]$OnlyConnectedNetworkAdapters=$true
   )
   Begin {
      Write-Verbose "Initialize stuff in Begin block"
   }
   Process {
      gwmi -Class Win32_NetworkAdapterConfiguration -ComputerName $Computername | Where { $_.IPEnabled -eq $OnlyConnectedNetworkAdapters } | `
      Select-Object @{ Label="Name"; Expression= { $_.__SERVER }}, `
         IPEnabled, `
         @{ Label="NetConnectionID"; Expression= { $NicIndex=$_.Index;(gwmi Win32_NetworkAdapter -cn $Computername | Where { $_.Index -eq $NicIndex}).NetConnectionID }}, `
         Description, MACAddress, `
         @{Label='IPAddress';expression={$_.IPAddress}}, `
         @{Label='IPSubnet';expression={$_.IPSubnet}}, `
         @{Label='DefaultIPGateway';expression={$_.DefaultIPGateway}}, `
         @{Label='DNSServerSearchOrder';expression={$_.DNSServerSearchOrder}}, `
         DomainDNSRegistrationEnabled, `
         @{ Label="TcpipNetbiosOptions";Expression={switch ($_.TcpipNetbiosOptions) {0 {"Enable Netbios via DHCP"} 1 {"Enable Netbios"} 2 {"Disable Netbios"}}}}, `
         WINSEnableLMHostsLookup, WINSPrimaryServer, WINSSecondaryServer, DHCPEnabled, DHCPServer, `
      @{ Label="DHCP Lease Expires"; Expression= { [dateTime]$_.DHCPLeaseExpires }}, @{ Label="DHCP Lease Obtained"; Expression= { [dateTime]$_.DHCPLeaseObtained }}, `
      @{ Label="Jumbo Frames"; Expression = { Invoke-Command -cn $Computername {$guid=$args[0];(Get-ItemProperty (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\0*\' |where {$_.NetCfgInstanceID -eq $guid}).PSPath)."*JumboPacket" } -ArgumentList $_.SettingID }}
   }
   End {
      Write-Verbose "Final work in End block"
   }
}
