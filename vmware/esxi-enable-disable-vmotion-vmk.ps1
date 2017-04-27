
# Enable vmotion on vmk1 disable on vmk0
Get-Cluster SMP | Get-VMHost | Get-VMHostNetworkAdapter -Name vmk0 | Set-VMHostNetworkAdapter -VMotionEnabled $false -Confirm:$false
Get-Cluster SMP | Get-VMHost | Get-VMHostNetworkAdapter -Name vmk1 | Set-VMHostNetworkAdapter -VMotionEnabled $true -Confirm:$false
