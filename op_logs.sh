#!/bin/bash

# Pregunta por la dirección IP o nombre de host de la máquina virtual
read -p "Ingrese la dirección IP o el nombre de host de la máquina virtual: " vm_address

# Pregunta por la ruta de los logs en la máquina virtual
read -p "Ingrese la ruta de los logs en la máquina virtual: " logs_path

# Pregunta por el número de ticket
read -p "Ingrese el número de ticket: " ticket_number

# Crea la carpeta Logs-TICKET si no existe
logs_folder="Logs-$ticket_number"

# Conexión SSH a la máquina virtual y obtención de los logs
ssh "$vm_address" "ls -lth \"$logs_path\"" | awk 'BEGIN{ count=1 } NR>1 { print count++ ". " $0 }' | head -n 20 > logs_list.txt

# Función para mostrar el listado de logs
function mostrar_listado_logs() {
  clear
  echo "Listado de logs (Últimos 20 logs...):"
  echo "-----------------"
  cat logs_list.txt
  echo "-----------------"
  echo "1. Descargar log(s)"
  echo "2. Salir"
  echo

  read -p "Ingrese una opción: " option
  case $option in
    1)
      read -p "Ingrese el número(s) del log que desea descargar (separado por comas): " log_numbers
      IFS=',' read -ra nums <<< "$log_numbers"
      mkdir -p "$logs_folder"
      for num in "${nums[@]}"; do
        log_file=$(sed "${num}q;d" logs_list.txt | awk '{print $NF}')
        scp -q "$vm_address:\"$logs_path/$log_file\"" "$logs_folder/"
        echo "Log \"$log_file\" descargado en la carpeta \"$PWD/$logs_folder/\"."
      done
      ;;
    2)
      exit
      ;;
    *)
      echo "Opción inválida. Intente nuevamente."
      ;;
  esac
}

# Mostrar listado de logs
mostrar_listado_logs

rm -Rf logs_list.txt
