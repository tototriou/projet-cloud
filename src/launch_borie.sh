#!/bin/bash

ssh -A -t aristide-briand << EOF
    if [ $? -eq 0 ]; then
        echo "La connexion SSH est établie avec succès."
    else
        echo "Échec de la connexion SSH."
        exit 1
    fi
    rm -rf projet-cloud-virt
    git clone https://github.com/tototriou/projet-cloud.git
    sudo rm /etc/nomad.d/nomad.hcl
    sudo rm /etc/consul.d/consul.hcl
    sudo cp ~/projet-cloud/conf_nomad_consul/nomad_borie.hcl /etc/nomad.d/nomad.hcl
    sudo cp ~/projet-cloud/conf_nomad_consul/consul_borie.hcl /etc/consul.d/consul.hcl
    sudo systemctl restart consul
    sudo systemctl restart nomad
    echo "consul restart"
    consul join aristide-briand 
    echo "nomad restart"
    sudo systemctl restart nomad
    nomad server join aristide-briand
    exit
    echo -e "Done for Borie"
EOF