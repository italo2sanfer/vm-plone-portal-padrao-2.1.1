#!/bin/sh

PIP=9.0.3
ZC_BUILDOUT=2.13.1
SETUPTOOLS=40.8.0
WHEEL=0.33.1
PLONE_MAJOR=4.3
PLONE_VERSION=4.3.19
PLONE_MD5=04ed5beac7fb8504f06a36d44e407b06

passo(){
    local passo="$1"
    local vai=$2
    local descricao="$3"
    echo "\n\n##### $descricao"
    if [ $vai -eq 0 ]; then    
        if [ $passo = 'a' ]; then	
            echo "A versao do plone será $PLONE_VERSION"
        elif [ $passo = 'b' ]; then
            echo "" >> /etc/apt/sources.list
            echo "# Debian 9 para Python 2.7" >> /etc/apt/sources.list
            echo "deb http://archive.debian.org/debian/ stretch contrib main contrib non-free"  >> /etc/apt/sources.list
            apt update
        elif [ $passo = 'c' ]; then
            buildDeps="dpkg-dev gcc libbz2-dev libc6-dev libjpeg62-turbo-dev libopenjp2-7-dev libpcre3-dev libssl-dev libtiff5-dev libxml2-dev libxslt1-dev wget zlib1g-dev vim openssh-server python-pip python2.7-dev"
            apt update && apt install -y --no-install-recommends $buildDeps
        elif [ $passo = 'd' ]; then
            /sbin/useradd --system -m -d /plone -U -u 500 plone
            mkdir -p /plone/instance/ /data/filestorage /data/blobstorage
            cp buildout.cfg /plone/instance
        elif [ $passo = 'e' ]; then
            echo "Feito no passo d."
        elif [ $passo = 'f' ]; then
            echo "Feito nos passos referentes às instalações."
        elif [ $passo = 'g' ]; then
            echo "Instala junto com a primeira parte das dependências."
        elif [ $passo = 'h' ]; then
            wget -O Plone.tgz https://launchpad.net/plone/$PLONE_MAJOR/$PLONE_VERSION/+download/Plone-$PLONE_VERSION-UnifiedInstaller.tgz
            echo "$PLONE_MD5 Plone.tgz" | md5sum -c -
            tar -xzf Plone.tgz
            cp -rv ./Plone-$PLONE_VERSION-UnifiedInstaller/base_skeleton/* /plone/instance/
            cp -v ./Plone-$PLONE_VERSION-UnifiedInstaller/buildout_templates/buildout.cfg /plone/instance/buildout-base.cfg
        elif [ $passo = 'i' ]; then
            pip install pip==$PIP setuptools==$SETUPTOOLS zc.buildout==$ZC_BUILDOUT wheel==$WHEEL
        elif [ $passo = 'j' ]; then
            cd /plone/instance
            buildout
            rm -rf bin/buildout
        elif [ $passo = 'k' ]; then
            ln -s /data/filestorage/ /plone/instance/var/filestorage
            ln -s /data/blobstorage /plone/instance/var/blobstorage
            find /data  -not -user plone -exec chown plone:plone {} +
            find /plone -not -user plone -exec chown plone:plone {} +
        else
            echo "??? Erro no parametro"
        fi
    else
        echo '## Feito'
    fi
}

limpar()
{
    rm -rf /Plone*
    apt-get purge -y --auto-remove $buildDeps	    
    runDeps="git gosu libjpeg62 libopenjp2-7 libtiff5 libxml2 libxslt1.1 lynx netcat poppler-utils rsync wv"
    apt-get install -y --no-install-recommends $runDeps
    rm -rf /var/lib/apt/lists/*
    rm -rf /plone/buildout-cache/downloads/*
}

passo "a" 1 "Exportando variaveis"
passo "b" 1 "Repositorio para python 2.7"
passo "c" 0 "Instalando pacotes iniciais"
passo "d" 0 "Adicionando usuario plone" 
passo "e" 0 "Arquivo buildout.cfg"
passo "f" 0 "Setando variaveis de pacote"
passo "g" 0 "Instalando dependencias 1"
passo "h" 1 "Instalando Plone"
passo "i" 1 "Pinando versoes"
passo "j" 1 "Rodando o buildout"
passo "k" 1 "Pastas 'data' e 'plone'"
