#!/bin/bash

## uncomment the following lines to launch the three machines

./launch_borie.sh
./launch_republique.sh
./launch_wacken.sh

#ssh -A borie 
#nomad job run projet-cloud-virt/conf_nomad_consul/conf-nomad.hcl

