Ever hassled around needing to create a certain number of bridges and interfaces to be used on your PC for VM's in VirtualBox or some other hypervisor?
You can use mininet which is an awsome tool but I needed something very quick and very dirty.

This script basically creates an X amount of bridges with each an Y amount of interfaces attached to it.
This allows you to spawn VM's in virtualbox very quickly and attach these interface to them. 

I needed this primaryly to simulate network environments for certain cloud stacks and SDS storage solutions like Ceph.

For now it does what I want. Planning to extend it a bit so that VM's are automatically created and attached to these interfaces.
Modifications and improvements are most welcome.

Cheers,
Erwin

