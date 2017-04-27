#This will configure a network core dump on all hosts in vCenter. We could get more specific by adding a 'get-cluster'
#identifying a specific host by name to test. 

$dumpip = "10.3.216.31"
foreach($vmhost in Get-VMHost){
    $esxcli = Get-EsxCli -VMHost $vmhost.Name
    $esxcli.system.coredump.network.set($null,"vmk0",$null,"10.3.216.31",6500)
    $esxcli.system.coredump.network.set($true)
    $esxcli.system.coredump.network.get()
}