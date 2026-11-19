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

    apt update
    apt install -y ca-certificates curl

    install -m 0755 -d /etc/apt/keyrings

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      -o /etc/apt/keyrings/docker.asc

    chmod a+r /etc/apt/keyrings/docker.asc

    cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: jammy
Components: stable
Architectures: amd64
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    apt update

    apt install -y \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin

    systemctl enable --now docker

    usermod -aG docker vagrant
  SHELL

  # DNS dos dois servicos na rede privada do Grupo 10.
  config.vm.provision "dns-grupo10", type: "shell", inline: <<~'GRUPO10_DNS'
    #!/usr/bin/env bash
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive

    if [[ ! -x /usr/sbin/dnsmasq ]]; then
      apt-get update
      apt-get install -y dnsmasq-base
    fi

    staging_dir=$(mktemp -d)
    trap 'rm -rf -- "$staging_dir"' EXIT
    cat > "$staging_dir/grupo10-dns.conf" <<'DNSMASQ_CONFIG'
    listen-address=192.168.20.10
    bind-dynamic
    no-resolv
    no-hosts
    local=/eventos.local/
    host-record=eventos.local,192.168.20.10
    host-record=blog.eventos.local,192.168.20.10
    DNSMASQ_CONFIG

    cat > "$staging_dir/grupo10-dns.service" <<'SYSTEMD_UNIT'
    [Unit]
    Description=DNS do laboratorio Grupo 10 Eventos
    Wants=network-online.target
    After=network-online.target

    [Service]
    ExecStart=/usr/sbin/dnsmasq --keep-in-foreground --conf-file=/etc/grupo10-dns.conf
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target
    SYSTEMD_UNIT

    /usr/sbin/dnsmasq --test --conf-file="$staging_dir/grupo10-dns.conf"
    install -m 0644 "$staging_dir/grupo10-dns.conf" /etc/grupo10-dns.conf
    install -m 0644 "$staging_dir/grupo10-dns.service" /etc/systemd/system/grupo10-dns.service
    systemctl daemon-reload
    systemctl enable grupo10-dns.service
    systemctl restart grupo10-dns.service
    systemctl is-active --quiet grupo10-dns.service
  GRUPO10_DNS
end
