Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "grupo10-eventos"
  config.vm.network "private_network", ip: "192.168.20.10", netmask: "255.255.255.0"

  config.vm.provider "virtualbox" do |virtualbox|
    virtualbox.name = "redes-computadores-grupo10"
    virtualbox.memory = 2048
    virtualbox.cpus = 2
  end

  config.vm.provision "shell", inline: <<-SHELL
    set -eux
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y docker.io docker-compose
    systemctl enable --now docker
    usermod -aG docker vagrant
    cd /vagrant
    docker-compose up -d --build
  SHELL
end
