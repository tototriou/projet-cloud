#
# Ansible managed
#

# Group name
datacenter = "aristide-briand"

# Save the persistent data to /opt/nomad
data_dir = "/opt/nomad"

# Allow clients to connect from any interface
bind_addr = "0.0.0.0"

advertise {
  # We explicitely advertise the IP on the vxlan interface
  http = "172.16.1.25"
  rpc = "172.16.1.25"
  serf = "172.16.1.25"
}

# This node is a server, and expects to be the only server in the cluster
server {
  enabled = true
  bootstrap_expect = 3
}

# This node is not running jobs
client {
    enabled = true
    network_interface = "vxlan100"
}

# Connect to the local Consul agent
consul {
  address = "127.0.0.1:8500"
}
