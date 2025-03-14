$host = "redfield.tech"
$image = "bento/ubuntu-20.04"
$ram = 2048
$cpu = 2

provisioner = {
    :hostname => "provisioner",
    :ip => "10.0.10.2",
    :ram => $ram,
    :cpu => $cpu,
}

master = {
  :hostname => "k8s-master",
  :ip => "10.0.10.3",
  :ram => $ram,
  :cpu => $cpu,
}

worker = {
  :hostname => "k8s-worker",
  :ip => "10.0.10.4",
  :ram => $ram,
  :cpu => $cpu,
}

def setup_node(node, machine)
  node.vm.hostname = machine[:hostname]
  node.vm.network "private_network", ip: machine[:ip]
  node.vm.provider "vmware_desktop" do |vm|
    vm.memory = machine[:ram]
    vm.cpus = machine[:cpu]
  end
end

Vagrant.configure("2") do |config|
  config.vm.box = $image

  config.vm.define provisioner[:hostname] do |node|
    setup_node(node, provisioner)
    node.vm.provision "shell", inline: "rm -rf /home/vagrant/provision/server/"
    node.vm.provision "file", source: "./provision/server/", destination: "/home/vagrant/"
    node.vm.provision "shell", inline: <<-SHELL
      python3 /home/vagrant/server/install.py \
        --password #{ENV['PUPPET_API_KEY']} \
        --certname puppet.#{$host} \
        --java-heap 1g \
        --puppet-src /home/vagrant/server/environments
    SHELL
  end

  [master, worker].each do |machine|
    config.vm.define machine[:hostname] do |node|
      setup_node(node, machine)
      node.vm.provision "file", source: "./provision/agent/", destination: "/home/vagrant/"
      node.vm.provision "shell", inline: <<-SHELL
        python3 /home/vagrant/agent/install.py \
          --password #{ENV['PUPPET_API_KEY']} \
          --certname #{machine[:hostname]}.#{$host} \
          --server puppet.#{$host} \
          --server-ip #{provisioner[:ip]}
      SHELL
    end
  end
end
