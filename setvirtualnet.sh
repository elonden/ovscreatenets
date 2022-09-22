#!/bin/sh
#### Script to create and delete a variable number of bridges and interfaces under OpenVswitch
#    Copyright (C) <2015>  <Erwin van Londen>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###
## Test if network needs to be created or deleted

if [[ `id -u` != "0" ]]; then
    echo "Needs to be run as root or use sudo"
    exit 1
fi



echo "Do you want to create or delete the network  c/d"
read crde

#set -x

case $crde in

    c)
    echo "How many networks you want to create 1-9 (3)"
    read -e -i 3  netnum
    if [[ $netnum > "9" ]]; then
        echo "No more than 9 networks...."
        exit
    fi


    echo "Number of uplink interfaces per network 1-3 (2)"
    read -e -i 2 intnum
    if [[ $intnum > "3" ]]; then
        echo "No more than 5 uplink interfaces"
        exit
    fi

    echo "Number of host interfaces per network (2 to 4) (4)"
    read -e -i 4 hostnum
    echo $hostnum
    if [[ $hostnum > "4" || $hostnum < "2" ]]; then
        echo "No more than 4 and less than 2 host interfaces per network segment"
        exit
    fi
#set +x


    ### Create the network
    # Add the bridges
    for ((x=1 ; x<=$netnum ; x++)) {
        ovs-vsctl -- --if-exists del-br br5$x""0
        ovs-vsctl add-br br5$x""0
        echo "Network segment br5"$x"0 created"
        ovs-vsctl add-br br6$x""0
        echo "Network segment br6"$x"0 created"
    # Add the uplink interfaces to each network
        for ((y=1 ; y<=$intnum ; y++))
            {
                ip tuntap add mode tap ulink5$x$y
                ovs-vsctl -- add-port br5$x""0 ulink5$x$y
                ip link set ulink5$x$y up ; sleep 2
                echo "Uplink interface ulink5"$x$y" on bridge br5"$x"0 created"
                ulinkarray+=(ulink5$x$y)
            }
    # Add the host interfaces connected to each switch
    # The first interface needs to be connected to the switch, the others to VM's
            for ((z=1 ; z<=$hostnum ; z++ )) {
                ip tuntap add mode tap hlink5$x$z
                ovs-vsctl -- add-port br6$x""0 hlink5$x$z
                ip link set hlink5$x$z up ; sleep 2
                echo "Host interface hlink5"$x$z" on bridge br6"$x"0 created"

        }
        }
    ;;

    d)
    ### Delete the network

    #network segments
    for x in `ovs-vsctl list-br | grep -E "br[5-6]"` ; do
        ovs-vsctl -- del-br $x
    done
    #interfaces
    for x in `ifconfig -a | grep -E "^ulink5|^hlink5" | awk -F: '{print $1}'` ; do
        ip link del $x
    done
    ;;

    ?)
    exit


esac



