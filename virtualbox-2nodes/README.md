## Vagrant 2-nodes

Lab deploy with 2 nodes. One for compute and another for control (not recommended).
 - Compute: Recommended memory: 1 GB
 - Controller ("named Openstack on Vagrantfile"): Recommended memory: 6 GB

Min. configuration using multinode Kolla.

we use Vagrant to build and provision VMs (controller, compute and deploy). Deploy one is only used to install Kolla-ansible Openstack and all the dependencies needed to build OpenStack with the 2-nodes

We use terraform to test and provision Openstack creating new networks, routers, VMs...
