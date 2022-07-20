#!/usr/bin/bash

# adds your rsa public key to the authorized keys to enable pwd-less
ports=(2222 2223 2224)
rsa_pub=$(cat ~/.ssh/id_rsa.pub)
for port in ${ports[@]}; do
	ssh -p $port ubuntu@localhost "echo $rsa_pub >> ~/.ssh/authorized_keys"
done
