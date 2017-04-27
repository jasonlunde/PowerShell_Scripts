
#Command Line Parameters
param(
	[string]$UCSM	# IP Address(s) or Hostname(s).  If multiple entries, separate by commas
)

#Clear the screen
clear-host

#Log into the UCS System(s)
$multilogin = Set-UcsPowerToolConfiguration -SupportMultipleDefaultUcs $true
Write-Output ""
Write-Output "Logging into: $UCSM"
Connect-Ucs -name $UCSM 

function List-Vlans
{
    #This process Lists the VLANS on the UCS System(s)
    Get-UCSVlan | Select-Object Name,Id | Sort-Object Id
}

List-Vlans

pause

Disconnect-Ucs