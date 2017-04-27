
#Attempt to put vmk1 into the new port-group
$vmotion_portgroup = "VCESYS-ESX-L3VMOTION"
$vds = "DVswitch01-A"
Write-Host "Migrating VMK1 to " $vmotion_portgroup
$dvportgroup = Get-VDPortgroup -name $vmotion_portgroup -VDSwitch $vds
$vmk = Get-Cluster SMP | Get-VMHost | Get-VMHostNetworkAdapter -Name vmk1
Set-VMHostNetworkAdapter -PortGroup $dvportgroup -VirtualNic $vmk -confirm:$false | Out-Null
