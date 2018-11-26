# vagrant-lab-openstack
Some Vagrantfiles to build various version of Openstack. We focus on the Rocky release, using the containers based version (Kolla) to speedup deployment.

## virtualbox-based, all-in-one lab

This lab uses a single VM to host a complete Openstack install. 

## virtualbox-based, 3 nodes 

This lab uses a 3 VMs to host an Openstack with 2 controllers and one compute node.

## libvirt-based, 2 nodes 

This lab uses 2 VMs using libvirt as hypervisor to host an Openstack with 1 controllers and one compute node. 

Note: Due to high requirements this could not work properly if you do not meet the minimum req.:
 - Controller node (named "Openstack"): 6GB memory
 - Compute node (named "Compute01"): 1 GB
 - Deploy: 500 MB
 
