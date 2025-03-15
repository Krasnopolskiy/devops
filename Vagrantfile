$host = "redfield.tech"
$image = "bento/ubuntu-20.04"
$ram = 2048
$cpu = 2

machines = {
  :provisioner => {
    :hostname => "provisioner",
    :ip => "10.0.10.2",
    :role => "puppet_server"
  },
  :master => {
    :hostname => "k8s-master",
    :ip => "10.0.10.3",
    :role => "puppet_agent"
  },
  :worker1 => {
    :hostname => "k8s-worker1",
    :ip => "10.0.10.4",
    :role => "puppet_agent"
  },
  :worker2 => {
    :hostname => "k8s-worker2",
    :ip => "10.0.10.5",
    :role => "puppet_agent"
  }
}

def setup_node(node, machine)
  node.vm.hostname = machine[:hostname]
  node.vm.network "private_network", ip: machine[:ip]
  node.vm.provider "vmware_desktop" do |vm|
    vm.memory = $ram
    vm.cpus = $cpu
  end
end

def provision_ansible(node, machine, server_ip)
  playbook = "#{machine[:role]}.yml"

  extra_vars = {
    "puppet_password" => ENV['PUPPET_API_KEY']
  }
  
  if machine[:role] == "puppet_server"
    extra_vars["certname"] = "puppet.#{$host}"
    extra_vars["server_ip"] = machine[:ip]
    extra_vars["java_heap_size"] = "1g"
  else
    extra_vars["certname"] = "#{machine[:hostname]}.#{$host}"
    extra_vars["puppet_server"] = "puppet.#{$host}"
    extra_vars["puppet_server_ip"] = server_ip
  end

  node.vm.provision "ansible_local", run: "never" do |ansible|
    ansible.provisioning_path = "/vagrant/provision/ansible"
    ansible.playbook = "playbooks/#{playbook}"
    ansible.inventory_path = "inventory.yml"
    ansible.config_file = "ansible.cfg"
    ansible.limit = machine[:role]
    ansible.extra_vars = extra_vars
  end
end

Vagrant.configure("2") do |config|
  config.vm.box = $image

  config.vm.synced_folder "provision/ansible", "/vagrant/provision/ansible"

  machines.each do |name, machine|
    config.vm.define machine[:hostname] do |node|
      setup_node(node, machine)
      provision_ansible(node, machine, machines[:provisioner][:ip])
    end
  end

  config.trigger.after :up do |trigger|
    trigger.info = "Running provisioners on all machines..."
    machines.each do |name, machine|
      trigger.run = {inline: "vagrant provision #{machine[:hostname]}"}
    end
  end
end
