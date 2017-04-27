<#

.SYNOPSIS
	This script allows you to log into a UCSM domain and it will collect all of the WWPNs and WWNNs for each created Service Profile in the UCS Domain and write that information to an Excel document.

.DESCRIPTION
	This script allows you to log into a UCSM domain and it will collect all of the WWPNs and WWNNs for each created Service Profile in the UCS Domain and write that information to an Excel document.

.EXAMPLE
	Get-UcsWwpn.ps1
	This script can be run without any command line parameters.  User will be prompted for all parameters and options required

.EXAMPLE
	Get-UcsWwpn.ps1 -ucs "1.2.3.4" -ucred
	-ucs -- UCS Manager IP or Host Name -- Example: "1.2.3.4" or "myucs" or "myucs.domain.local" or "1.2.3.4,5.6.7.8" or "myucs1,myucs2" or "myucs1.domain.local,myucs2.domain.local"
	-ucred -- UCS Manager Credential Switch -- Adding this switch will immediately prompt you for your UCSM username and password
	All parameters are optional and any skipped will be prompted for during execution
	The only prompts that will always be presented to the user will be for User Names and Passwords
	
.EXAMPLE
	Get-UcsWwpn.ps1 -ucs "1.2.3.4" -saved "myucscred.csv" -skiperrors
	-ucs -- UCS Manager IP or Host Name -- Example: "1.2.3.4" or "myucs" or "myucs.domain.local" or "1.2.3.4,5.6.7.8" or "myucs1,myucs2" or "myucs1.domain.local,myucs2.domain.local"
	-savedcred -- UCSM credentials file -- Example: -savedcred "myucscred.csv"
		To create a credentials file: $credential = Get-Credential ; $credential | select username,@{Name="EncryptedPassword";Expression={ConvertFrom-SecureString $_.password}} |Export-CSV -NoTypeInformation .\myucscred.csv
		Make sure the password file is located in the same folder as the script
	-skiperrors -- Tells the script to skip any prompts for errors and continues with 'y'
	All parameters are optional and any skipped will be prompted for during execution
	The only prompts that will always be presented to the user will be for User Names and Passwords

.NOTES
	Author: Joe Martin
	Email: joemar@cisco.com
	Company: Cisco Systems, Inc.
	Version: v0.4.02
	Date: 7/11/2014
	Disclaimer: Code provided as-is.  No warranty implied or included.  This code is for example use only and not for production

.INPUTS
	UCSM IP Address(s) or Hostname(s)
	UCSM Username and Password
	UCSM Credentials Filename

.OUTPUTS
	Microsoft Excel spreadsheet
	
.LINK
	http://communities.cisco.com/people/joemar/content

#>

#Command Line Parameters
param(
	[string]$UCSM,				# IP Address or Hostname
	[switch]$UCREDENTIALS,		# UCSM Credentials
	[string]$SAVEDCRED,			# Saved UCSM Credentials.  To create do: $credential = Get-Credential ; $credential | select username,@{Name="EncryptedPassword";Expression={ConvertFrom-SecureString $_.password}} | Export-CSV -NoTypeInformation .\myucscred.csv
	[switch]$SKIPERROR			# Skip any prompts for errors and continues with 'y'
)

#Clear the screen
clear-host

Write-Output "Script Running..."
Write-Output ""

#Tell the user what the script does
Write-Output "This script allows you to log into a UCSM domain and it will collect all of the"
Write-Output "WWPNs and WWNNs for each created Service Profile in the UCS Domain and write that"
Write-Output "information to an Excel document."
Write-Output ""
Write-Output "This script requires Excel, PowerTool, PowerShell v3 or above and network access to your UCS"
Write-Output ""
Write-Output "This script supports configurations with dual vHBAs, single vHBAs on either the A or B fabric"
Write-Output "but it does NOT support a solution where you mix these. ie: Some have dual and some have one."
Write-Output ""

#Gather any credentials requested from command line
if ($UCREDENTIALS)
	{
		Write-Output "Enter UCSM Credentials"
		Write-Output ""
		$cred = Get-Credential -Message "Enter UCSM Credentials"
	}

#Change directory to the script root
cd $PSScriptRoot

#Check to see if credential files exists
if ($SAVEDCRED)
	{
		if ((Test-Path $SAVEDCRED) -eq $false)
			{
				Write-Output ""
				Write-Output "Your credentials file $SAVEDCRED does not exist in the script directory"
				Write-Output "	Exiting..."
				Disconnect-Ucs
				exit
			}
	}

#Do not show errors in script
$ErrorActionPreference = "SilentlyContinue"
#$ErrorActionPreference = "Stop"
#$ErrorActionPreference = "Continue"
#$ErrorActionPreference = "Inquire"

#Verify PowerShell Version for script support
$PSVersion = $psversiontable.psversion
$PSMinimum = $PSVersion.Major
if ($PSMinimum -ge "3")
	{
	}
else
	{
		Write-Output "This script requires PowerShell version 3 or above"
		Write-Output "Please update your system and try again."
		Write-Output "You can download PowerShell updates here:"
		Write-Output "	http://search.microsoft.com/en-us/DownloadResults.aspx?rf=sp&q=powershell+4.0+download"
		Write-Output "If you are running a version of Windows before 7 or Server 2008R2 you need to update to be supported"
		Write-Output "		Exiting..."
		Disconnect-Ucs
		exit
	}

#Load the UCS PowerTool
Write-Output "Checking Cisco PowerTool"
$PowerToolLoaded = $null
$Modules = Get-Module
$PowerToolLoaded = $modules.name
if ( -not ($Modules -like "ciscoUcsPs"))
	{
		Write-Output "	Loading Module: Cisco UCS PowerTool Module"
		Import-Module ciscoUcsPs
		$Modules = Get-Module
		if ( -not ($Modules -like "ciscoUcsPs"))
			{
				Write-Output ""
				Write-Output "	Cisco UCS PowerTool Module did not load.  Please correct his issue and try again"
				Write-Output "		Exiting..."
				exit
			}
		else
			{
				Write-Output "	PowerTool is Loaded"
			}
	}
else
	{
		Write-Output "	PowerTool is Loaded"
	}

#Define UCS Domain(s)
Write-Output ""
Write-Output "Connecting to UCSM"
Write-Output "	Enter UCS system IP or Hostname"
if ($UCSM -ne "")
	{
		$myucs = $UCSM
	}
else
	{
		$myucs = Read-Host "Enter UCS system IP or Hostname"
	}
if (($myucs -eq "") -or ($myucs -eq $null) -or ($Error[0] -match "PromptingException"))
	{
		Write-Output ""
		Write-Output "You have provided invalid input."
		Write-Output "	Exiting..."
		Disconnect-Ucs
		exit
	}
else
	{
		Disconnect-Ucs
	}

#Test that UCSM is IP Reachable via Ping
Write-Output ""
Write-Output "Testing reachability to UCSM"
$ping = new-object system.net.networkinformation.ping
$results = $ping.send($myucs)
if ($results.Status -ne "Success")
	{
		Write-Output "	Can not access UCSM $myucs by Ping"
		Write-Output ""
		Write-Output "It is possible that a firewall is blocking ICMP (PING) Access.  Would you like to try to log in anyway?"
		if ($SKIPERROR)
			{
				$Try = "y"
			}
		else
			{
				$Try = Read-Host "Would you like to try to log in anyway? (Y/N)"
			}
		if ($Try -ieq "y")
			{
				Write-Output ""
				Write-Output "Trying to log in anyway!"
				Write-Output ""
			}
		elseif ($Try -ieq "n")
			{
				Write-Output ""
				Write-Output "You have chosen to exit"
				Write-Output "	Exiting..."
				Disconnect-Ucs
				exit
			}
		else
			{
				Write-Output ""
				Write-Output "You have provided invalid input.  Please enter (Y/N) only."
				Write-Output "	Exiting..."
				Disconnect-Ucs
				exit
			}			
	}
else
	{
		Write-Output "	Successfully pinged UCSM: $myucs"
	}
	
#Allow Logins to single or multiple UCSM systems
$multilogin = Set-UcsPowerToolConfiguration -SupportMultipleDefaultUcs $false

#Log into UCSM
Write-Output ""
Write-Output "Logging into UCSM"
Write-Output "	Provide UCSM login credentials"

#Verify PowerShell Version to pick prompt type
$PSVersion = $psversiontable.psversion
$PSMinimum = $PSVersion.Major
if (!$UCREDENTIALS)
	{
		if (!$SAVEDCRED)
			{
				if ($PSMinimum -ge "3")
					{
						Write-Output "	Enter your UCSM credentials"
						$cred = Get-Credential -Message "UCSM(s) Login Credentials" -UserName "admin"
					}
				else
					{
						Write-Output "	Enter your UCSM credentials"
						$cred = Get-Credential
					}
			}
		else
			{
				$CredFile = import-csv $SAVEDCRED
				$Username = $credfile.UserName
				$Password = $credfile.EncryptedPassword
				$cred = New-Object System.Management.Automation.PsCredential $Username,(ConvertTo-SecureString $Password)			
			}
	}
$myCon = Connect-Ucs $myucs -Credential $cred
if (($myucs | Measure-Object).count -ne ($myCon | Measure-Object).count) 
	{
	#Exit Script
	Write-Output "		Error Logging into UCS.  Make sure your user has login rights the UCS system and has the proper role/privledges to use this tool..."
	Write-Output "			Exiting..."
	Disconnect-Ucs
	exit
	}
else
	{
	Write-Output "		Login Successful"
	}

$devicealiasfileA = $PSScriptRoot + "\device-alias-mdsA.txt"
$devicealiasfileB = $PSScriptRoot + "\device-alias-mdsB.txt"
$fcaliasfileA = $PSScriptRoot + "\fc-alias-mdsA.txt"
$fcaliasfileB = $PSScriptRoot + "\fc-alias-mdsB.txt"




#Gather vHBA Information
Write-Output ""
Write-Output "Collecting information from UCSM"
$AllvHBAsA = Get-UcsVhba  | where {($_.Addr -ine "derived") -and ($_.SwitchID -eq "A")}
$AllvHBAsB = Get-UcsVhba  | where {($_.Addr -ine "derived") -and ($_.SwitchID -eq "B")}

#Put vHBA Info into a Hash Table
if ($AllvHBAsA.count -ne 0)
	{
		$vHBAInfo = @{"ServiceProfile" = $AllvHBAsA.Dn; "WWPNa" = $AllvHBAsA.Addr; "WWPNb" = $AllvHBAsB.Addr; "WWNN" = $AllvHBAsA.NodeAddr}
	}
elseif ($AllvHBAsB.Count -ne 0)
	{
		$vHBAInfo = @{"ServiceProfile" = $AllvHBAsB.Dn; "WWPNa" = $AllvHBAsA.Addr; "WWPNb" = $AllvHBAsB.Addr; "WWNN" = $AllvHBAsB.NodeAddr}
	}
	
#Check to see if any service profiles have vHBAs
if ($vHBAInfo.ServiceProfile -eq $null)
	{
		Write-Output ""
		Write-Output "	No Service Profiles configured with vHBAs"
		Write-Output "		Please correct and run this script again"
		Write-Output "			Exiting..."
		Disconnect-Ucs
		exit
	}
else
	{
		Write-Output "	Information collected"
	}

#Reset Loop Counter
$Loop = 0

#Determine how many Service Profiles there are that have vHBAs
$LoopMax = ($vHBAInfo.ServiceProfile).Count

#Local Display Output Header
Write-Output ""
Write-Output "Building shit...please wait"
Write-Output ""
Write-Output "Service Profile                 WWPN for Fabric A         WWPN for Fabric B         WWNN"
Write-Output "---------------                 -----------------         -----------------         ----"

if ($LoopMax -ne 0)
	{
		do 
			{	
				#Format the Service profile name to remove the header and footer info
				$ServiceProfileFull = $vHBAInfo.ServiceProfile[$Loop] -match "/ls-(?<content>.*)/fc-"
				if ($ServiceProfileFull -eq $true)
					{
						$ServiceProfile = $matches['content']
					}
				else
					{
						$ServiceProfile = " "
					} 
				$WWPNa = $vHBAInfo.WWPNa[$Loop]
				$WWPNb = $vHBAInfo.WWPNb[$Loop]
				$WWNN = $vHBAInfo.WWNN[$Loop]
				
				#Puts content into specific Excel cells
                                if ($Loop -eq 0)
					{
						Write-Output "device-alias database" | Out-File -LiteralPath $devicealiasfileA -Append
						Write-Output "device-alias name $ServiceProfile-vHBA1 pwwn $WWPNa" | Out-File -LiteralPath $devicealiasfileA -Append
						Write-Output "device-alias database" | Out-File -LiteralPath $devicealiasfileB -Append
						Write-Output "device-alias name $ServiceProfile-vHBA2 pwwn $WWPNb" | Out-File -LiteralPath $devicealiasfileB -Append
					}
				else
					{
						Write-Output "device-alias name $ServiceProfile-vHBA1 pwwn $WWPNa" | Out-File -LiteralPath $devicealiasfileA -Append
						Write-Output "device-alias name $ServiceProfile-vHBA1 pwwn $WWPNb" | Out-File -LiteralPath $devicealiasfileB -Append
					}
				
				#Create screen output
				$output1 = $ServiceProfile+"                                                                "
				$output2 = $WWPNa+"                                                                "
				$output3 = $WWPNb+"                                                                "
				$output4 = $WWNN+"                                                                "

				#Display output to screen
				$Display = $output1.Substring(0,32)+$output2.Substring(0,26)+$output3.Substring(0,26)+$output4.Substring(0,26)
				Write-Output $Display
		
				#Increment Counters
				$Loop += 1
				$ColumnLoop += 1
			}
		while ($Loop -lt $LoopMax)
		Write-Output "	DONE"
		
		Write-Output "device-alias commit" | Out-File -LiteralPath $devicealiasfileA -Append
		Write-Output "device-alias commit" | Out-File -LiteralPath $devicealiasfileB -Append
	}

#Save the Excel file
Write-Output ""
$date = Get-Date
$DateFormat = [string]$date.Month+"-"+[string]$Date.Day+"-"+[string]$date.year+"_"+[string]$date.Hour+"-"+[string]$date.Minute+"-"+[string]$date.Second
$file = $PSScriptRoot + "\UCS WWPN Collector for "+$mycon.ucs+"_"+$DateFormat+".xlsx"
Write-Output "The Excel file will be created as: $file"
Write-Output "	Saving Excel File...Please wait..."
$Workbook.SaveAs($file)
Write-Output "		Complete"

#Close the Excel file
Write-Output ""
Write-Output "Closing Excel Spreadsheet"
$Workbook.Close()

#Exit Excel
Write-Output ""
Write-Output "Exiting Excel"
$Excel.Quit()

#Exit the Script
Write-Output ""
Write-Output "Script Complete"
Write-Output "	Exiting"
Disconnect-Ucs
exit