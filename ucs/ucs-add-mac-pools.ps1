## Add a MAC pool A to the root organization
Start-UcsTransaction
$mo = Get-UcsOrg -Level root  | Add-UcsMacPool -AssignmentOrder "default" -Descr "" -Name "MAC-Pool-A" -PolicyOwner "local"
$mo_1 = $mo | Add-UcsMacMemberBlock -From "00:25:B5:0A:00:00" -To "00:25:B5:0A:00:FF"
Complete-UcsTransaction


## Add a MAC pool B to the root organization
Start-UcsTransaction
$mo = Get-UcsOrg -Level root  | Add-UcsMacPool -AssignmentOrder "default" -Descr "" -Name "MAC-Pool-B" -PolicyOwner "local"
$mo_1 = $mo | Add-UcsMacMemberBlock -From "00:25:B5:0B:00:00" -To "00:25:B5:0B:00:FD"
Complete-UcsTransaction


## Add a MAC pool A to the RTP sub-organization
Start-UcsTransaction
$mo = Get-UcsOrg -Level root | Get-UcsOrg -Name "RTP" -LimitScope | Add-UcsMacPool -AssignmentOrder "default" -Descr "" -Name "MAC-Pool-A" -PolicyOwner "local"
$mo_1 = $mo | Add-UcsMacMemberBlock -From "00:25:B5:AA:00:00" -To "00:25:B5:AA:00:FD"
Complete-UcsTransaction


## Add a MAC pool A to the R471 sub-sub-organization
Start-UcsTransaction
$mo = Get-UcsOrg -Level root | Get-UcsOrg -Name "RTP" -LimitScope | Get-UcsOrg -Name "R471" -LimitScope | Add-UcsMacPool -AssignmentOrder "default" -Descr "" -Name "MAC-Pool-A" -PolicyOwner "local"
$mo_1 = $mo | Add-UcsMacMemberBlock -From "00:25:B5:AA:0A:00" -To "00:25:B5:AA:0A:FD"
Complete-UcsTransactionq


## Deletes a MAC Pool A from the sub-sub-organization
Get-UcsOrg -Level root | Get-UcsOrg -Name "RTP" -LimitScope | Get-UcsOrg -Name "R471" -LimitScope | Get-UcsMacPool -Name "MAC-Pool-A" -LimitScope | Remove-UcsMacPool