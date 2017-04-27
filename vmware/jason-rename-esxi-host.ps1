$vcenterName = "r471-vc6.ctc.lab.vce.com"
$clusterName = "SMP"
$esxName = "r471-host10.ctc.lab.vce.com"
$newName = "c1k1-host10"
$newDN = "c1k1-host10.ctc.lab.vce.com"
$esxUser = "root"
$esxPswd = "1vBlock9!"

Connect-VIServer -Server $vcenterName
Get-VMHost -Name $esxName | Set-VMHost -State Disconnected -Confirm:$false | 
Remove-VMHost -Confirm:$false
Disconnect-VIServer -Server $vcenterName -Confirm:$false

Connect-VIServer -Server $esxName -User $esxUser -Password $esxPswd
$esxcli = Get-EsxCli -VMHost $esxName
$esxcli.system.hostname.set($null,$newName,$null)
Get-AdvancedSetting -Entity $esxName -Name 'Misc.PreferredHostName' | Set-AdvancedSetting -Value $newName -Confirm:$false
Write-Host "Rebooting"
Restart-VMHost -force

do {
sleep 60
Connect-VIServer -Server $newDN -User $esxUser -Password $esxPswd
$ServerState = (Get-VMHost $newDN).ConnectionState
Write-Host "Waiting for Reboot …"
}
while ($ServerState -ne "Connected")
Write-Host "newName is back up...and Boom goes the dynamite"
Disconnect-VIServer -Server $esxName -Confirm:$false

Connect-VIServer -Server $vcenterName
$cluster = Get-Cluster -Name $clusterName
Add-VMHost -Name $newDN -Location $cluster -User $esxUser -Password $esxPswd -Force -Confirm:$false