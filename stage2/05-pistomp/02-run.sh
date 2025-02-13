#!/bin/bash -e

echo "Installing MOD software"
on_chroot << EOF

mkdir -p /home/${FIRST_USER_NAME}/tmp
cd /home/${FIRST_USER_NAME}/tmp

wget http://download.drobilla.net/lilv-0.24.12.tar.bz2
tar xvf lilv-0.24.12.tar.bz2
cd lilv-0.24.12

./waf configure --prefix=/usr/local  --static --static-progs --no-shared --no-utils --no-bash-completion --pythondir=/usr/local/lib/python3.11/dist-packages
./waf build
./waf install
cd ..

EOF

