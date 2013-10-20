#!/bin/bash -e
#
# Installation script for Pombo.
#

if [ $(id -ru) -ne 0 ]; then
    echo "! You need to have root rights !"
    sudo $0
    exit 0
fi

inst_dir=/usr/local/bin
[ -d ${inst_dir} ] || inst_dir=/usr/local/sbin

echo ""
echo "Installing (verbose) ..."
[ -f /etc/pombo.conf ] && mv -fv /etc/pombo.conf /etc/pombo.conf.$(date '+%s')
install -v pombo.conf /etc
echo "« chmod 600 /etc/pombo.conf »"
chmod 600 /etc/pombo.conf
install -v pombo.py ${inst_dir}/pombo
echo "« chmod +x ${inst_dir}/pombo »"
chmod +x ${inst_dir}/pombo

if test -f /etc/crontab ; then
    if [ $(grep -c "bin/pombo" /etc/crontab) == 0 ] ; then
        echo "« */15 * * * * root ${inst_dir}/pombo >>/etc/crontab »"
        echo "*/15 * * * * root ${inst_dir}/pombo" >>/etc/crontab
    fi
else
    touch /etc/crontab
    echo "« */15 * * * * root ${inst_dir}/pombo >>/etc/crontab »"
    echo "*/15 * * * * root ${inst_dir}/pombo" >>/etc/crontab
fi
[ -f /var/local/pombo ] && rm -fv /var/local/pombo
echo "Done."

echo ""
echo "Checking dependancies ..."
ok=1
for package in python gpg ifconfig iwlist traceroute imagesnap; do
    test=$(which ${package})
    [ $? != 0 ] && echo " ! ${package} needed but not installed." && ok=0
done
python check-imports.py
[ $? != 0 ] && ok=0
case ${ok} in
    1) echo "Done." ;;
    *) echo "Please install necessary tools before continuing." ;;
esac

cat <<EOM

Thank you to use Pombo!
Then you will need to:
    1 - import your GnuPG keyID
    2 - tune options into /etc/pombo.conf (you can use the GUI: pombo-config)
    3 - tune variables into pombo.php
    4 - copy pombo.php to your server(s) (both PHP versions 4 & 5 supported)
And do not forget to write somewhere in security your computer Serial Number.

EOM
exit 0
