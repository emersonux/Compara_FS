#!/bin/bash
#
# Script para validação de file systems montados e FSTAB.
#
# Programador: Emerson Souza dos Santos
#
# Versão 1

# Função para comparar file systems montados via df e fstab
function  compara_df () {

        #As strings são armazenadas em variaveis evitando escrita em arquivos. Depois são comparadas com o comando diff
	FSTAB=$(egrep -v '^#|^$|swap|devpts|tmpfs|/proc|/sys' /etc/fstab | awk '{print $2}' | sort)
	DF=$(df -hP | egrep -v 'udev|tmpfs|cgmfs|Sist.|Filesystem' | awk '{print $6}' | sort)

	echo "Fstab                            VS                            Mounted FS's" \ ;
	sdiff  <(echo $FSTAB | tr ' ' '\n') <(echo $DF | tr ' ' '\n')
}

# Função para comparar os devices. Focado em devices LVM. Não recomendado para file system montado direto no disco/partição.
function compara_device () {

        # As strings são armazenadas em variaveis evitando escrita em arquivos. Depois são comparadas com o comando diff
        FSTAB=$(egrep -v '^#|^$|swap|devpts|tmpfs|/proc|/boot|sysfs' /etc/fstab | awk '{print $1}' | sort)
        DF=$(df -hP | egrep -v 'udev|tmpfs|cgmfs|Sist.|Filesystem|/boot' | awk '{print $1}' | sort)
        BOOTDEVICE=$(grep /boot /etc/fstab | grep -v ^# | cut -d = -f 2 | awk '{print $1}')
        BLKID=$(blkid | grep $BOOTDEVICE | awk '{print $1}' | cut -d : -f 1 | tail -1)

        echo -e "Device de Boot: $BLKID    UUID: $BOOTDEVICE \n"
        echo "Fstab devices                   VS                            Mounted FS' devices" \ ;
        sdiff  <(echo $FSTAB | tr ' ' '\n') <(echo $DF | tr ' ' '\n')

}

function versao () {
        echo -n $(basename "$0")
        # Grep da versão direto da linha do cabeçalho
        grep '^# Versão ' "$0" | tail -1 | tr -d \#
}


# Variavel da mensagem de help
MENSAGEM_HELP="
Uso: $(basename "$0") [OPÇÕES]\n\n

OPÇÕES\n
 -d     \"devices\" Compara os devices do fstab com os montados. Recomendado apenas para devices LVM\n
 -h     \"help\"    Abre esta mensagem.\n
 -V     \"version\" Versão do script.\n

"


# Opções para chamada de script. 
if [ -z "$1" ] ; then
        compara_df #Se executado sem opções a chamada padrão é a comparação de pontos de Montagem.

else

        while getopts ":dhV" opcao
                do
                        case $opcao in
                        d) compara_device ;;
                        h) echo -e $MENSAGEM_HELP ;;    
                        V) versao ;;
                        \?) echo  "Opção inválida" && exit 1 ;;
                        esac
                done

fi
