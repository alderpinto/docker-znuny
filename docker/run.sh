#!/bin/bash

function prepare_otrs () {
    echo "Preparing otrs..."
    cp -rfp /app-files/otrs/* ${OTRS_ROOT}
    su -c "${OTRS_ROOT}bin/otrs.Console.pl Maint::Config::Rebuild" -s /bin/bash otrs
    su -c "${OTRS_ROOT}bin/otrs.Console.pl Maint::Cache::Delete" -s /bin/bash otrs
    ${OTRS_ROOT}bin/otrs.SetPermissions.pl --otrs-user=otrs --web-group=nginx ${OTRS_ROOT}
    rm -fr /app-files/otrs   
}

VOLUME_DIR=${OTRS_ROOT:-/opt/otrs/}

# Verificar se o diretório do volume existe
if [ -d "$VOLUME_DIR" ]; then
    # Verificar se existem arquivos ou diretórios dentro do diretório do volume
    if [ "$(ls -A $VOLUME_DIR)" ]; then
        echo "O ambiente já foi configurado anteriormente."
    else
        echo "O ambiente ainda não foi configurado."
        # Coloque aqui o código para executar a configuração inicial do ambiente
        prepare_otrs     
    fi
else
    echo "O volume ainda não foi criado."
    # Coloque aqui o código para criar o volume e executar a configuração inicial do ambiente
    mkdir -p ${OTRS_ROOT}
    prepare_otrs  
fi

/usr/bin/supervisord -c /etc/supervisord.conf&

trap 'kill ${!}; term_handler' SIGTERM

# wait forever
while true
do
 tail -f /dev/null & wait ${!}
done