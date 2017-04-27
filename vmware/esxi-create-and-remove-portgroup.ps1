
# Creates port-group on vswitch0 with specified name and vlan id, on all hosts in the cluster
Get-Cluster SMP | Get-VMHost | Get-VirtualSwitch -Name “vSwitch0” | New-VirtualPortGroup -Name “vce-esxi-vmotion” -VLanId 106

# Removes a virtual port group
Get-Cluster SMP | Get-VMHost | Get-VirtualSwitch -Name "vSwitch0" | Get-VirtualPortGroup -Name vce-esxi-vmotion | Remove-VirtualPortGroup -Confirm:$false
