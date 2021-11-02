#!/bin/bash
build ()	{
    echo -n "Running configure ... "
    ./configure -silent
    echo -n "Done.\nRunning make ..."
    make -j4
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
    apt install build-essential libtool libortp-dev dahdi-source libsctp-dev shtool autoconf automake git-core pkg-config make gcc cmake libusb-1.0-0-dev libpcsclite-dev libtalloc-dev libortp-dev libsctp-dev libmnl-dev libdbi-dev libdbd-sqlite3 libsqlite3-dev sqlite3 libc-ares-dev libgnutls-dev libfftw3-dev 
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
    cd osmo-bsc
    build
    cd libosmo-netif
    build
    cd libosmo-sccp
    build
    cd osmo-bts
    build
# not installed by 'make install' ?
    cp osmo-bts/src/osmo-bts-trx/osmo-bts-trx /usr/local/bin
    cd osmo-hlr
    build
    mkdir -p /var/lib/osmocom
    cd osmo-mgw
    build
    cd osmo-msc
    build
    cd osmo-trx
    ./configure --with-lms
    make -j4
    make install
    ldconfig
    cd ..
fi
echo -n "Copy configuration files ? [y/n] : "
read a
if [ "$a" != "${a#[Yy]}" ] ;then
    echo "Copying configuration files to /etc/osmoBTS ..."
    mkdir -p /etc/osmoBTS
    cp cfg/* /etc/osmoBTS
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
    systemctl restart osmo-bsc.service
    systemctl restart osmo-hlr.service
    systemctl restart osmo-msc.service
    systemctl restart osmo-trx-lms.service
    systemctl restart osmo-bts-trx.service
    systemctl restart osmo-mgw.service
    systemctl restart osmo-stp.service
fi
echo "Done, please reboot system !"
