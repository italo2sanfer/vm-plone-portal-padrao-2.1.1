#!/bin/sh

PORTAL_PADRAO=2.1.1
PIP=9.0.3
ZC_BUILDOUT=2.13.1
SETUPTOOLS=38.7.0 
WHEEL=0.33.1

passo(){
    local passo="$1"
    local vai=$2
    local descricao="$3"
    echo "\n\n##### $descricao"
    if [ $vai -eq 0 ]; then    
        if [ $passo = 'a' ]; then	
            echo "A versao do portal_padrao será $PORTAL_PADRAO"
        elif [ $passo = 'b' ]; then
            cp portal-padrao-versions.cfg /plone/instance/
            cp buildout.cfg /plone/instance/
        elif [ $passo = 'c' ]; then
            pip install pip==$PIP setuptools==$SETUPTOOLS zc.buildout==$ZC_BUILDOUT wheel==$WHEEL
            pip install ijson psutil==6.1.* argcomplete
            cd /plone/instance
            buildout
            rm -rf bin/buildout
        elif [ $passo = 'd' ]; then
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

passo "a" 1 "Exportando variavel(is)"
passo "b" 0 "Arquivo buildout.cfg"
passo "c" 1 "Rodando o buildout"
passo "d" 1 "Pastas 'data' e 'plone'"
