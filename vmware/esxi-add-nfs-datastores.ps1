#This adds the our groups common datastores to all hosts within the identified clusters. If the host already
#has the datastore(s) you will get an error, but no big deal there.

get-cluster SMP | get-vmhost | New-Datastore -NFS -Name NFS1 -Path /NFS1 -nfshost 10.3.129.100
get-cluster SMP | get-vmhost | New-Datastore -NFS -Name NFS2 -Path /NFS2 -nfshost 10.3.129.100
get-cluster SMP | get-vmhost | New-Datastore -NFS -Name NFS3 -Path /NFS3 -nfshost 10.3.129.100
get-cluster SMP | get-vmhost | New-Datastore -NFS -Name VCE -Path /CIFS -nfshost 10.3.129.100 -ReadOnly
