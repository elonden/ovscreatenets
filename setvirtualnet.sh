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
## Test is network needs to be created or deleted

echo "Do you want to create or delete the network  c/d"
read crde

case $crde in

    c)
    echo "How many networks you want to create 1/9"
    read netnum
    if [[ $netnum > 9 ]]; then {
        echo "No more than 9 networks...."
        exit
    }
    fi

    echo "Number of interfaces per network 1-50"
    read intnum
    if [[ $intnum > 50 ]]; then {
        echo "No more than 50 interfaces"
    }
    fi

    ### Create the network
    # Add the bridges
    for ((x=1 ; x<=$netnum ; x++)) {
        ovs-vsctl -- --if-exists del-br br5$x""0
        ovs-vsctl add-br br5$x""0
        echo "Network segment br"$x" created"
    # Add the interfaces to each network
        for ((y=1 ; y<=$intnum ; y++))
            {
                ip tuntap add mode tap vnet5$x$y
                ovs-vsctl -- add-port br5$x""0 vnet5$x$y
                ip link set vnet5$x$y up
                echo "Interface vnet5"$x$y" on bridge "$x" created"
            }
        }
    ;;

    d)
    ### Delete the network

    #network segments
    for x in `ovs-vsctl list-br | grep br5` ; do
        ovs-vsctl -- del-br $x
    done
    #interfaces
    for x in `ifconfig | grep -E "^vnet5" | awk -F: '{print $1}'` ; do
        ip link del $x
    done
    ;;

    ?)
    exit


esac



