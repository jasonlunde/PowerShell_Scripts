31..33 | Foreach-Object {
$esxName = "r471-host$_.ctc.lab.vce.com"
$newName = "c1k1-host$_"
Connect-VIServer -Server $esxName -User root -Password 1vBlock9!
$esxcli = Get-EsxCli -VMHost $esxName
$esxcli.system.hostname.set($null,$newName,$null)
Get-AdvancedSetting -Entity $esxName -Name 'Misc.PreferredHostName' | Set-AdvancedSetting -Value $newName -Confirm:$false
Restart-VMHost -force
}
