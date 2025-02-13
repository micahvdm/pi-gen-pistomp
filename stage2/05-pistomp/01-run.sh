#!/bin/bash

install -m 644 files/services/*.service ${ROOTFS_DIR}/lib/systemd/system/

echo "Creating folders and services"
on_chroot << EOF

mkdir -p /home/${FIRST_USER_NAME}/data

ln -sf /lib/systemd/system/ttymidi.service /etc/systemd/system/multi-user.target.wants
ln -sf /lib/systemd/system/firstboot.service /etc/systemd/system/multi-user.target.wants

adduser --no-create-home --system --group jack
adduser ${FIRST_USER_NAME} jack --quiet
adduser ${FIRST_USER_NAME} audio --quiet
adduser root jack --quiet
adduser jack audio --quiet

EOF

