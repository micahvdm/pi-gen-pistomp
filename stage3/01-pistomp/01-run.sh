#!/bin/bash

echo "pi-Stomp files"

# ssh logo splash
install -m 666 files/display-pistomp-logo ${ROOTFS_DIR}/etc/update-motd.d/
chmod +x ${ROOTFS_DIR}/etc/update-motd.d/display-pistomp-logo

on_chroot << EOF

# data dir
mkdir -p /home/${FIRST_USER_NAME}/data/user-files
mkdir -p /home/${FIRST_USER_NAME}/data/config
mkdir -p /usr/mod/scripts
mkdir -p "/home/${FIRST_USER_NAME}/data/user-files/Speaker Cabinets IRs"
mkdir -p "/home/${FIRST_USER_NAME}/data/user-files/Reverb IRs"
mkdir -p "/home/${FIRST_USER_NAME}/data/user-files/Audio Loops"
mkdir -p "/home/${FIRST_USER_NAME}/data/user-files/Audio Recordings"
mkdir -p "/home/${FIRST_USER_NAME}/data/user-files/Audio Samples"
mkdir -p "/home/${FIRST_USER_NAME}/data/user-files/Audio Tracks"
mkdir -p "/home/${FIRST_USER_NAME}/data/user-files/MIDI Clips"
mkdir -p "/home/${FIRST_USER_NAME}/data/user-files/MIDI Songs"
mkdir -p "/home/${FIRST_USER_NAME}/data/user-files/Hydrogen Drumkits"
mkdir -p "/home/${FIRST_USER_NAME}/data/user-files/SF2 Instruments"
mkdir -p "/home/${FIRST_USER_NAME}/data/user-files/SFZ Instruments"
mkdir -p "/home/${FIRST_USER_NAME}/data/user-files/Amplifier Profiles"
mkdir -p "/home/${FIRST_USER_NAME}/data/user-files/Aida DSP Models"
mkdir -p "/home/${FIRST_USER_NAME}/data/user-files/NAM Models"

install -m 644 /home/${FIRST_USER_NAME}/pi-stomp/util/config_templates/default_config.yml /home/${FIRST_USER_NAME}/data/config/
install -m 644 /home/${FIRST_USER_NAME}/pi-stomp/util/config_templates/default-hardware-descriptor.json /home/${FIRST_USER_NAME}/data/config/

# Pedalboards
rm -rf /home/${FIRST_USER_NAME}/data/.pedalboards
git clone https://github.com/TreeFallSound/pi-stomp-pedalboards.git /home/${FIRST_USER_NAME}/data/.pedalboards
ln -s /home/${FIRST_USER_NAME}/data/.pedalboards /home/${FIRST_USER_NAME}/.pedalboards

# Services
ln -sf /lib/systemd/system/mod-ala-pi-stomp.service /etc/systemd/system/multi-user.target.wants

chown -R ${FIRST_USER_NAME}:${FIRST_USER_NAME} /usr/lib/pistomp-wifi

# Plugins
mkdir -p /home/${FIRST_USER_NAME}/tmp
pushd /home/${FIRST_USER_NAME}/tmp
wget https://www.treefallsound.com/downloads/lv2plugins.tar.gz
tar -zxf lv2plugins.tar.gz -C /home/${FIRST_USER_NAME}/
ln -s /home/${FIRST_USER_NAME}/.lv2 /home/${FIRST_USER_NAME}/data/.lv2
popd
rm -rf /home/${FIRST_USER_NAME}/tmp

EOF

# rc.local
bash -c "sed -i 's/exit 0//' ${ROOTFS_DIR}/etc/rc.local"
cat >> ${ROOTFS_DIR}/etc/rc.local <<EOF
logger --priority info --tag rc.local "rc.local start..."
sudo iw dev wlan0 set power_save off
if test -f "/var/lib/alsa/asound.state"
then
    logger --priority info --tag rc.local "restoring asound.state"
    sudo alsactl --no-ucm restore -f /var/lib/alsa/asound.state
fi
(sleep 10;/usr/lib/pistomp-wifi/wifi_check.sh) &
logger --priority info --tag rc.local "rc.local completed successfully"
exit 0
EOF

# Version info
software_version=$(sudo git --work-tree ${ROOTFS_DIR}/home/pistomp/pi-stomp --git-dir ${ROOTFS_DIR}/home/pistomp/pi-stomp/.git describe --dirty="*" --always)
build_tag=$(git --work-tree $BASE_DIR --git-dir $BASE_DIR/.git describe --dirty="*" --always)
build_date=$(date +"%y%m%d")
printf '{"build-tag": "%s", "build-date": "%s", "software-version": "%s"}' $build_tag $build_date $software_version > ${ROOTFS_DIR}/home/pistomp/.osbuild

