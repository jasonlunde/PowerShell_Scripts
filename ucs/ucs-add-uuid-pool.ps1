Start-UcsTransaction
$mo = Get-UcsOrg -Level root  | Add-UcsUuidSuffixPool -AssignmentOrder "sequential" -Descr "" -Name "UUID-Pool" -PolicyOwner "local" -Prefix "derived"
$mo_1 = $mo | Add-UcsUuidSuffixBlock -From "0000-000000000001" -To "0000-000000000015"
Complete-UcsTransaction