#!/bin/bash
VOLUME_DIR=${ZNUNY_ROOT:-/opt/otrs}

function prepare_znuny () {
    echo "Preparing znuny..."
    cp -rfp /app-files/otrs/* ${ZNUNY_ROOT}/
    su -c "${ZNUNY_ROOT}/bin/otrs.Console.pl Maint::Config::Rebuild" -s /bin/bash otrs
    su -c "${ZNUNY_ROOT}/bin/otrs.Console.pl Maint::Cache::Delete" -s /bin/bash otrs
    ${ZNUNY_ROOT}/bin/otrs.SetPermissions.pl --otrs-user=otrs --web-group=nginx ${ZNUNY_ROOT}/
    rm -fr /app-files/otrs   
}

# Verificar se o diretório do volume existe
if [ -d "$VOLUME_DIR" ]; then
    # Verificar se existem arquivos ou diretórios dentro do diretório do volume
    if [ "$(ls -A $VOLUME_DIR)" ]; then
        echo "O ambiente já foi configurado anteriormente."
    else
        echo "O ambiente ainda não foi configurado."
        # Coloque aqui o código para executar a configuração inicial do ambiente
        prepare_znuny     
    fi
else
    echo "O volume ainda não foi criado."
    # Coloque aqui o código para criar o volume e executar a configuração inicial do ambiente
    mkdir -p ${ZNUNY_ROOT}/
    prepare_znuny  
fi

/usr/bin/supervisord -c /etc/supervisord.conf&

trap 'kill ${!}; term_handler' SIGTERM

# wait forever
while true
do
 tail -f /dev/null & wait ${!}
done