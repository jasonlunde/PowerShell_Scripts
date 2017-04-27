
#Command Line Parameters
param(
	[string]$UCSM,	# IP Address(s) or Hostname(s)
	[string]$vlan, 	#for now enter a single vlan
	[string]$name 	#enter a vlan name
)

#Clear the screen
clear-host

#Log into the UCS System(s)
$multilogin = Set-UcsPowerToolConfiguration -SupportMultipleDefaultUcs $true
Write-Output ""
Write-Output "Logging into: $UCSM"
Connect-Ucs -name $UCSM 

#This process add a VLAN to the selected UCS Systems
Start-UcsTransaction
Get-UcsLanCloud | Add-UcsVlan -CompressionType "included" -DefaultNet "no" -Id $vlan -McastPolicyName "" -Name $name -PubNwName "" -Sharing "none"
Complete-UcsTransaction
Write-Output "Done adding VLAN"

pause

Disconnect-Ucs