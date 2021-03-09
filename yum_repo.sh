cd /etc/yum.repos.d/
DIR=/media/cdrom1
if [ ! -d "$DIR" ];then
        mkdir /media/cdrom1
fi
if [[ "`ls -A $DIR`" = "" ]]; then
        mount /dev/cdrom /media/cdrom1
fi
if ls *.repo >/dev/null 2>&1;then
    mv *.repo repo/
fi
if [ ! -f "local.repo" ];then
    echo "[BASE]" > /etc/yum.repos.d/local.repo
    echo "name=base" >> /etc/yum.repos.d/local.repo
    for i in /media/*
    do
    if [ -e "$i" ] ; then
        baseurl=${i// /\\ }
        echo "baseurl=file://$baseurl" >> /etc/yum.repos.d/local.repo
    else
        echo "Please Insert The Disk!"
    fi
    done
    echo "enabled=1" >> /etc/yum.repos.d/local.repo
    echo "gpgcheck=0" >> /etc/yum.repos.d/local.repo
fi