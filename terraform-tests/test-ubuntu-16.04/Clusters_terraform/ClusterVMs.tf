variable "nodes_num" {}

# provision lab openstack using victor login/pass
provider "openstack" {
 user_name = "labuser"
 tenant_name = "lab"
 password = "labpassword"
 auth_url = "http://192.168.50.68:5000/v3"
 domain_id = "default"
}

# provision SSH key for iptnuc7
resource "openstack_compute_keypair_v2" "iptnuc7" {
  name = "iptnuc7"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCt7Vu4D1e7Deh17JCDfpLDuZdWWaxN7cPx7LdJRyiXb12fqtb0DAWuHtDYRu14q7yAziK6cZiN6SaAytZu9xfj1g+Ma9fi0UQ9qxAI+XYbsGEhdpaT+4pyWluQItHga76T23wVx+Iioi6yaHK/9J1EWCzfXL0b8bDU+IFuNzRz+mduDtwE90RTp3xz59/yZtiMHBdLZCdSkgMOcdVIf8Usy80bdmM2nFWvMhtalYjyGWblXHPFb2m7eexpOqpiITJt3CXwS0CIvUzC+zDq8LnibcXE+hC0qJtHeJ/43hXFbTakiWCLczlCxsTJXzrg//StdNclYpOWEEuoTykbz3MJ v.calzado@outlook.com"
}

# push a ubuntu image
resource "openstack_images_image_v2" "ubuntu-xenial" {
  name   = "vubuntu16.04"
  image_source_url = "http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img"
  container_format = "bare"
  disk_format = "qcow2"
  visibility = "public"
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
resource "openstack_networking_network_v2" "test-network" {
  name = "cluster-network"
  admin_state_up = "true"
}

# add a subnetwork associated to the network
resource "openstack_networking_subnet_v2" "test-network-subnet" {
  name = "test-network-subnet"
  network_id = "${openstack_networking_network_v2.test-network.id}"
  cidr = "192.168.187.0/24"
  ip_version = 4
  dns_nameservers = ["192.168.50.253"]
}

# add a router specific for our new ISP
resource "openstack_networking_router_v2" "test-network-router" {
  region = ""
  name = "vtest-network-router"
  admin_state_up = "true"
  external_network_id = "b6d69518-3af5-40c1-b43b-95954f034ae4"
}

# associate router 
resource "openstack_networking_router_interface_v2" "test-network-intf" {
  region = ""
  router_id = "${openstack_networking_router_v2.test-network-router.id}"
  subnet_id = "${openstack_networking_subnet_v2.test-network-subnet.id}"
}

# create a floating IP
resource "openstack_compute_floatingip_v2" "test-network-fip" {
  region = ""
  pool = "public1"
}

# instanciate our ubuntu 16.04
resource "openstack_compute_instance_v2" "test-network-epc" {
  depends_on = ["openstack_networking_subnet_v2.test-network-subnet","openstack_images_image_v2.ubuntu-xenial"]
  region = ""
  name = "nodo-${count.index}"
  image_name = "vubuntu16.04"
  flavor_name = "m1.small" # minimal size for this Ubuntu image (>2GB)
  key_pair = "iptnuc7"
  security_groups = ["test-network-secgroup"]
  count = "${var.nodes_num}"

  network = {
    name = "${openstack_networking_network_v2.test-network.name}"
  }

}
