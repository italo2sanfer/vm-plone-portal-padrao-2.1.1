#!/bin/sh

PIP=9.0.3
ZC_BUILDOUT=2.13.1
SETUPTOOLS=38.7.0
WHEEL=0.33.1
PLONE_MAJOR=4.3
PLONE_VERSION=4.3.19
PLONE_MD5=04ed5beac7fb8504f06a36d44e407b06
PORTAL_PADRAO=2.1.1
buildDeps="dpkg-dev gcc libbz2-dev libc6-dev libjpeg62-turbo-dev libopenjp2-7-dev libpcre3-dev libssl-dev libtiff5-dev libxml2-dev libxslt1-dev wget zlib1g-dev python-pip python2.7-dev python-pathlib"

step(){
    local step="$1"
    local go=$2
    local description="$3"
    echo "\n\n##### $description"
    if [ $go -eq 0 ]; then    
        if [ $step = 'a' ]; then
            echo "" >> /etc/apt/sources.list
            echo "# Debian 9 for Python 2.7" >> /etc/apt/sources.list
            echo "deb http://archive.debian.org/debian/ stretch contrib main contrib non-free"  >> /etc/apt/sources.list
            apt update
            apt update && apt install -y --no-install-recommends $buildDeps
        elif [ $step = 'b' ]; then
            /sbin/useradd --system -m -d /plone -U -u 500 plone
            mkdir -p /plone/instance/ /data/filestorage /data/blobstorage
            wget -O /plone/instance/buildout.cfg https://raw.githubusercontent.com/plonegovbr/portalpadrao.docker/refs/tags/v2.1.1/buildout.cfg
            wget -O /plone/instance/portal-padrao-versions.cfg https://raw.githubusercontent.com/plonegovbr/portalpadrao.release/master/$PORTAL_PADRAO/versions.cfg
            echo "#@italo2sanfer" >> /plone/instance/portal-padrao-versions.cfg
            echo "cssselect = 0.7" >> /plone/instance/portal-padrao-versions.cfg
            echo "ijson = 2.3" >> /plone/instance/portal-padrao-versions.cfg
            echo "inflection = 0.3.1" >> /plone/instance/portal-padrao-versions.cfg
            echo "backports.functools-lru-cache = 1.6.4" >> /plone/instance/portal-padrao-versions.cfg
        elif [ $step = 'c' ]; then
            wget -O Plone.tgz https://launchpad.net/plone/$PLONE_MAJOR/$PLONE_VERSION/+download/Plone-$PLONE_VERSION-UnifiedInstaller.tgz
            echo "$PLONE_MD5 Plone.tgz" | md5sum -c -
            tar -xzf Plone.tgz
            cp -rv ./Plone-$PLONE_VERSION-UnifiedInstaller/base_skeleton/* /plone/instance/
            cp -v ./Plone-$PLONE_VERSION-UnifiedInstaller/buildout_templates/buildout.cfg /plone/instance/buildout-base.cfg
        elif [ $step = 'd' ]; then
            pip install pip==$PIP setuptools==$SETUPTOOLS zc.buildout==$ZC_BUILDOUT wheel==$WHEEL
            pip install psutil==6.1.* argcomplete
        elif [ $step = 'e' ]; then
            cd /plone/instance
            buildout
            rm -rf bin/buildout
        elif [ $step = 'f' ]; then
            ln -s /data/filestorage/ /plone/instance/var/filestorage
            ln -s /data/blobstorage /plone/instance/var/blobstorage
            find /data  -not -user plone -exec chown plone:plone {} +
            find /plone -not -user plone -exec chown plone:plone {} +
        else
            echo "??? Error"
        fi
    else
        echo '## Done'
    fi
}

clean(){
    rm -rf /plone/buildout-cache/downloads/*
}

# The first parameter is the step.
# The second parameter is about the execution.
# ... If it is zero (0), it will be executed; otherwise, it will not be executed.
step "a" 0 "Python 2.7 Repository; Installation"
step "b" 0 "Plone; cfg files"
step "c" 0 "Install Plone"
step "d" 0 "Pin versions"
step "e" 0 "Run buildout"
step "f" 0 "'data' and 'plone' folders"