# provision lab openstack using victor login/pass
provider "openstack" {
 user_name = "labuser"
 tenant_name = "lab"
 password = "labpassword"
 auth_url = "http://192.168.50.68:5000/v3"
 domain_id = "default"
}

# security group
resource "openstack_networking_secgroup_v2" "test-network-secgroup" {
  name        = "vtest-network-secgroup"
  description = "victor test Network security group"
}

resource "openstack_networking_secgroup_rule_v2" "test-secgroup-ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.test-network-secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "test-secgroup-icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.test-network-secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "test-secgroup-iperf-tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5001
  port_range_max    = 5001
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.test-network-secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "test-secgroup-iperf-udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 5001
  port_range_max    = 5001
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.test-network-secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "test-secgroup-iperf3-tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5201
  port_range_max    = 5201
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.test-network-secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "test-secgroup-iperf3-udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 5201
  port_range_max    = 5201
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.test-network-secgroup.id}"
}

# create a dedicated network
resource "openstack_networking_network_v2" "cluster-network" {
  name = "master-cluster-network"
  admin_state_up = "true"
}

# add a subnetwork associated to the network
resource "openstack_networking_subnet_v2" "cluster-network-subnet" {
  name = "cluster-network-subnet"
  network_id = "${openstack_networking_network_v2.cluster-network.id}"
  cidr = "192.168.190.0/24"
  ip_version = 4
  dns_nameservers = ["192.168.50.253"]
}

# add a router specific for our new ISP
resource "openstack_networking_router_v2" "cluster-network-router" {
  region = ""
  name = "cluster-network-router"
  admin_state_up = "true"
  external_network_id = "b6d69518-3af5-40c1-b43b-95954f034ae4"
}

# associate router 
resource "openstack_networking_router_interface_v2" "cluster-network-intf" {
  region = ""
  router_id = "${openstack_networking_router_v2.cluster-network-router.id}"
  subnet_id = "${openstack_networking_subnet_v2.cluster-network-subnet.id}"
}

# create a floating IP
resource "openstack_compute_floatingip_v2" "cluster-network-fip" {
  region = ""
  pool = "public1"
}

resource "openstack_compute_floatingip_associate_v2" "cluster_network-fip-associate" {
  floating_ip = "${openstack_compute_floatingip_v2.cluster-network-fip.address}"
  instance_id = "${openstack_compute_instance_v2.cluster-master.id}"
  wait_until_associated = true

  # we install ansible support in the target VM
  provisioner "remote-exec" {
     connection {
       type     = "ssh"
       host     = "${openstack_compute_floatingip_v2.cluster-network-fip.address}"
       user     = "ubuntu"
       private_key = "${file("/home/labuser/.ssh/id_rsa")}"
     }
    
     inline = [
     "sudo apt-get -qy update",
     "sudo apt-get -qy install iperf iperf3 ansible"
     ]
   }
}

resource "openstack_compute_instance_v2" "cluster-master" {
  depends_on = ["openstack_networking_subnet_v2.cluster-network-subnet"]
  region = ""
  name = "cluster_master"
  image_name = "ubuntu16.04"
  flavor_name = "m1.small" # minimal size for this Ubuntu image (>2GB)
  key_pair = "iptnuc7"
  security_groups = ["test-network-secgroup"]

  network = {
    name = "${openstack_networking_network_v2.cluster-network.name}"
  }

}

# instanciate our ubuntu 16.04
resource "openstack_compute_instance_v2" "cluster_slaves" {
  depends_on = ["openstack_networking_subnet_v2.cluster-network-subnet"]
  region = ""
  name = "nodo-${count.index}"
  image_name = "ubuntu16.04"
  flavor_name = "m1.small" # minimal size for this Ubuntu image (>2GB)
  key_pair = "iptnuc7"
  security_groups = ["test-network-secgroup"]
  count = 10

  network = {
    name = "${openstack_networking_network_v2.cluster-network.name}"
  }

}
