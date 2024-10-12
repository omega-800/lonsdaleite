#!/usr/bin/env bash

rmtmprun() { sudo rm ./run.sh; }
nix build .#test-vm
cp ./result/bin/run-nixos-vm ./run.sh
trap rmtmprun EXIT
sudo chmod 500 run.sh
# yeah so the bin that nixos generates fails (err pipewire missing symbol), i guess because i've installed qemu through home-manager. enjoy the hackiness
sed -i 's/exec .* -cpu max/exec qemu-system-x86_64 -cpu max/' run.sh
./run.sh
