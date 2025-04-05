$host = "redfield.tech"
$image = "bento/ubuntu-20.04"

machines = {
  :provisioner => {
    :hostname => "provisioner",
    :ip => "10.0.10.2",
    :role => "puppet_server",
    :cpu => 2,
    :ram => 2048,
  },
  :master => {
    :hostname => "k8s-master",
    :ip => "10.0.10.3",
    :role => "puppet_agent",
    :cpu => 2,
    :ram => 2048,
  },
  :worker => {
    :hostname => "k8s-worker",
    :ip => "10.0.10.4",
    :role => "puppet_agent",
    :cpu => 8,
    :ram => 8096,
  }
}

def setup_node(node, machine)
  node.vm.hostname = machine[:hostname]
  node.vm.network "private_network", ip: machine[:ip]
  node.vm.provider "vmware_desktop" do |vm|
    vm.memory = machine[:ram]
    vm.cpus = machine[:cpu]
  end
end

def provision_ansible(node, machine, server)
  playbook = "#{machine[:role]}.yml"

  extra_vars = {
    "puppet_password" => ENV['PUPPET_API_KEY'],
    "server_ip" => server[:ip],
    "gateway_ip" => "10.0.10.1",
    "certname" => "#{machine[:hostname]}.#{$host}"
  }

  if machine[:role] == "puppet_server"
    extra_vars["java_heap_size"] = "1g"
  else
    extra_vars["server_certname"] = "#{server[:hostname]}.#{$host}"
  end

  node.vm.provision "ansible_local" do |ansible|
    ansible.provisioning_path = "/vagrant/ansible"
    ansible.playbook = "./playbooks/#{playbook}"
    ansible.inventory_path = "./inventory.yml"
    ansible.config_file = "./ansible.cfg"
    ansible.limit = machine[:role]
    ansible.extra_vars = extra_vars
  end
end

Vagrant.configure("2") do |config|
  config.vm.box = $image

  machines.each do |name, machine|
    config.vm.define machine[:hostname] do |node|
      setup_node(node, machine)
      provision_ansible(node, machine, machines[:provisioner])
    end
  end
end
