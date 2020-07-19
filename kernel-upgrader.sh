#!/bin/bash
#Author: Ercan Ermis - (twitter: @flightlesstux)
       
clear
echo '
 #####                      #######  #####  #######    #    #                                       #     #                                                  
#     # ###### #    # ##### #     # #     # #    #     #   #  ###### #####  #    # ###### #         #     # #####   ####  #####    ##   #####  ###### #####  
#       #      ##   #   #   #     # #           #      #  #   #      #    # ##   # #      #         #     # #    # #    # #    #  #  #  #    # #      #    # 
#       #####  # #  #   #   #     #  #####     #       ###    #####  #    # # #  # #####  #         #     # #    # #      #    # #    # #    # #####  #    # 
#       #      #  # #   #   #     #       #   #        #  #   #      #####  #  # # #      #         #     # #####  #  ### #####  ###### #    # #      #####  
#     # #      #   ##   #   #     # #     #   #        #   #  #      #   #  #   ## #      #         #     # #      #    # #   #  #    # #    # #      #   #  
 #####  ###### #    #   #   #######  #####    #        #    # ###### #    # #    # ###### ######     #####  #       ####  #    # #    # #####  ###### #    #
'

OSCHECK=$(cat /etc/*release)
ELREPO=$(rpm -qa)
KERNELCHECK=$(uname -r | cut -d '.' -f 1-3)

check_elrepo() {
echo "elrepo-release checking..."
if echo $ELREPO | grep -q "elrepo-release" ; then
echo "$(rpm -qa | grep elrepo-release | cut -d '.' -f 1-3) already installed."
else
echo "elrepo-release not found and installation started."
sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
sudo rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm 2>&1 >> /dev/null
sudo yum -y clean all 2>&1 >> /dev/null
sudo yum -y update 2>&1 >> /dev/null
echo "$(rpm -qa | grep elrepo-release | cut -d '.' -f 1-3) is installed."
fi
}

apply(){
read -p '
New kernel installed. Press ENTER for reboot.'
sudo reboot
}

if echo $OSCHECK | grep -q "CentOS Linux 7" ; then

echo 'Which kernel version do you want to install? 

1) kernel 4.4.x (longterm support)
2) kernel 5.7.x (mainline stable)
0) Cancel
'

echo "Please select an option and press ENTER: "
read -e OPTION
echo ""

case $OPTION in

        "1")
        check_elrepo
        if echo $KERNELCHECK | grep -q "4.4" ; then
        echo "Your kernel version is $KERNELCHECK. You don't need to take an action." 
        else
        echo "kernel 4.4.x (longterm support) installation started. Please be patient..."
        sudo yum -y --enablerepo=elrepo-kernel install kernel-lt >> /dev/null
        sudo sed -i 's/saved/0/g' /etc/default/grub 2>&1 >> /dev/null
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg
        apply
        fi
        ;;

        "2")
        check_elrepo
        if echo $KERNELCHECK | grep -q "5.7" ; then
        echo "Your kernel version is $KERNELCHECK. You don't need to take an action." 
        else
        echo "kernel 5.7.x (mainline stable) installation started. Please be patient..."
        sudo yum -y --enablerepo=elrepo-kernel install kernel-ml >> /dev/null
        sudo sed -i 's/saved/0/g' /etc/default/grub 2>&1 >> /dev/null
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg 
        apply
        fi
        ;;

        "0")
        echo "Installation cancelled..."
        exit 1
esac


elif echo $OSCHECK | grep -q "CentOS Linux 8" ; then
        echo -e "You are using CentOS 8 and CentOS8 is not supported."
else
                echo -e "\nUnable to detect your OS...\n"
                exit 1
fi
