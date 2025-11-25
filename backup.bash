#!/bin/bash
#Script para executar um backup, sincronizando arquivos, verificando e validando a origem
#e o destino

origens=()

#Função que valida o diretório digitado
valD(){
if [ ! -d "$1" ]; then
	echo "Diretório $1 não encontrado."
	return 1
else
	return 0
fi
}

#O usuário decide quais pastas deseja salvar
Origem(){
while true; do
	echo "Para terminar, digite 'fim'."
	echo -n "Digite o caminho do diretório que deseja salvar: "
	read origem

	if [ "$origem" == "fim" ]; then
		break
	fi

	valD "$origem"
	if [ $? -eq 0 ]; then
		origens+=("$origem")
	fi
done

if [ ${#origens[@]} -eq 0 ]; then
	echo "Nenhum diretório válido informado."
	echo
	Origem
else
	echo
	Destino
fi
}

#O usário seleciona o local onde irá salvar o backup
Destino(){
echo -n "Digite o caminho do local de destino: "
read destino

valD "$destino"

if [ $? -eq 0 ]; then
	Backup
else
	echo "Destino inválido."
	echo
	Destino
fi
}

#Executa o backup utilizando o rsync
Backup(){
data=$(date "+%d-%m-%Y_%H%M%S")
logfile="$destino/backup_$data.log"
echo "Log registrado em $logfile"
echo
echo "Iniciando o backup..."

for origem in ${origens[@]}; do
	nome=$(basename "$origem")
	subpasta="$destino/$nome"
	echo "Carregando de $origem para $destino..."
	rsync -auv --progress --delete --exclude='.DS_Store' --delete-excluded --log-file="$logfile" "$origem/" "$subpasta/"
done

echo
echo "Backup finalizado."
}

#Inicia o programa
Origem
