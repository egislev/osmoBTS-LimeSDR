#!/bin/bash
build ()	{
    echo -n "Running configure ... "
    ./configure -silent
    echo -n "Done.\nRunning make ..."
    make -j4 --silent
    echo "Done"
    make install
    ldconfig
    cd ..
}
if [ "$EUID" -ne 0 ]
  then echo "Please run this script as root !"
  exit
fi
echo -n "Install required packages ? (internet connection required) [y/n] : "
read a
if [ "$a" != "${a#[Yy]}" ] ;then
#sudo add-apt-repository universe
#ubuntu 18
    apt install build-essential libtool libortp-dev dahdi-source libsctp-dev shtool autoconf automake git-core pkg-config make gcc cmake libusb-1.0-0-dev libpcsclite-dev libtalloc-dev libortp-dev libsctp-dev libmnl-dev libdbi-dev libdbd-sqlite3 libsqlite3-dev sqlite3 libc-ares-dev  libfftw3-dev gnutls-dev libgtp-dev
#libgnutls-dev #ubuntu 16
fi
echo -n "Extract source code ? [y/n] : "
read a
if [ "$a" != "${a#[Yy]}" ] ;then
    echo "Extracting libosmocore.tgz ..."
    tar -xf libosmocore.tgz
    echo "Extracting libosmo-abis.tgz ..."
    tar -xf libosmo-abis.tgz
    echo "Extracting libosmo-netif.tgz ..."
    tar -xf libosmo-netif.tgz
    echo "Extracting libosmo-sccp.tgz ..."
    tar -xf libosmo-sccp.tgz
    echo "Extracting osmo-pcu.tgz ..."
    tar -xf osmo-pcu.tgz
    echo "Extracting osmo-sgsn.tgz ..."
    tar -xf osmo-sgsn.tgz
    echo "Extracting osmo-ggsn.tgz ..."
    tar -xf osmo-ggsn.tgz
    echo "Extracting osmo-bsc.tgz ..."
    tar -xf osmo-bsc.tgz
    echo "Extracting osmo-bts.tgz ..."
    tar -xf osmo-bts.tgz
    echo "Extracting osmo-hlr.tgz ..."
    tar -xf osmo-hlr.tgz
    echo "Extracting osmo-mgw.tgz ..."
    tar -xf osmo-mgw.tgz
    echo "Extracting osmo-msc.tgz ..."
    tar -xf osmo-msc.tgz
    echo "Extracting osmo-trx.tgz ..."
    tar -xf osmo-trx.tgz
fi
echo -n "Build packages? [y/n] : "
read a
if [ "$a" != "${a#[Yy]}" ] ;then
    cd libosmocore
    build
    cd libosmo-abis
    build
    cd libosmo-netif
    build
    cd libosmo-sccp
    build
    cd osmo-hlr
    build
    mkdir -p /var/lib/osmocom
    cd osmo-ggsn
    build
    cd osmo-sgsn
    build
    cd osmo-pcu
    build
    cd osmo-mgw
    build
    cd osmo-bsc
    build
    cd osmo-bts
    build
# not installed by 'make install' ?
    cp osmo-bts/src/osmo-bts-trx/osmo-bts-trx /usr/local/bin
    cd osmo-msc
    build
    cd osmo-trx
    ./configure --with-lms
    make -j4
    make install
    ldconfig
    cd ..
fi
echo -n "Stop Amarisoft services ? [y/n] : "
read a
if [ "$a" != "${a#[Yy]}" ] ;then
    systemctl stop lte-demo.service
    systemctl stop mme-lte.service
fi
echo -n "Disable Amarisoft services ? [y/n] : "
read a
if [ "$a" != "${a#[Yy]}" ] ;then
    systemctl disable lte-demo.service
    systemctl disable mme-lte.service
fi
echo -n "Copy configuration files ? [y/n] : "
read a
if [ "$a" != "${a#[Yy]}" ] ;then
    echo "Copying configuration files to /etc/osmoBTS ..."
    mkdir -p /etc/osmoBTS
    cp cfg/*cfg /etc/osmoBTS
    cp cfg/iptables-saved /etc
fi
echo -n "Copy system startup configuration files ? [y/n] : "
read a
if [ "$a" != "${a#[Yy]}" ] ;then
    echo "Copying startup system files to /lib/systemd/system ..."
    cp services/* /lib/systemd/system
    mkdir -p /var/lib/osmocom
fi
echo -n "Enable & start services ? [y/n] : "
read a
if [ "$a" != "${a#[Yy]}" ] ;then
    echo -n "Enabling & starting services ..."
    systemctl enable osmo-bsc.service
    systemctl enable osmo-hlr.service
    systemctl enable osmo-msc.service
    systemctl enable osmo-trx-lms.service
    systemctl enable osmo-bts-trx.service
    systemctl enable osmo-mgw.service
    systemctl enable osmo-stp.service
    systemctl enable osmo-pcu
    systemctl enable osmo-sgsn
    systemctl enable osmo-ggsn
    systemctl restart osmo-bsc.service
    systemctl restart osmo-hlr.service
    systemctl restart osmo-msc.service
    systemctl restart osmo-trx-lms.service
    systemctl restart osmo-bts-trx.service
    systemctl restart osmo-mgw.service
    systemctl restart osmo-stp.service
    systemctl restart osmo-pcu
    systemctl restart osmo-sgsn
    systemctl restart osmo-ggsn
fi
echo "Done, please reboot system !"
