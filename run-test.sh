#!/usr/bin/env bash

# pass any arg to run in headless mode
extraargs=""
rmtmprun() { sudo rm ./run.sh; }
[ -f nixos.qcow2 ] && sudo rm nixos.qcow2
nix build .#nixosConfigurations.test.config.system.build.vm --show-trace || exit 1
cp ./result/bin/run-nixos-vm ./run.sh
trap rmtmprun EXIT
sudo chmod 500 run.sh
# yeah so the bin that nixos generates fails (err pipewire missing symbol), i guess because i've installed qemu through home-manager
# enjoy the hackiness
if [ "$1" != "" ]; then
	sed -i "s/exec .* -cpu max/exec qemu-system-x86_64 -cpu host -nographic/" run.sh
	sed -i "s/-m 1024/-m 10G -enable-kvm/" run.sh
	sed -i "s/-smp 1/-smp $(nproc)/" run.sh
else
	sed -i "s/exec .* -cpu max/exec qemu-system-x86_64 -cpu max/" run.sh
fi
./run.sh
