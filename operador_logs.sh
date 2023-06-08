#!/bin/bash

echo "****IMPORTANTE: NO INTRODUCIR ESPACIOS EN EL NOMBRE DE LA MV y RUTA DE LOGS****"
echo ""

# Pregunta por las direcciones IP o nombres de host de las máquinas virtuales
read -p "Ingrese las direcciones IP o nombres de host de las máquinas virtuales (separadas por comas): " vm_addresses

# Convertir las direcciones IP o nombres de host en un array
IFS=',' read -ra vm_array <<< "$vm_addresses"

# Pregunta por la ruta de los logs en las máquinas virtuales (asumiendo que es la misma para todas)
read -p "Ingrese la ruta de los logs en las máquinas virtuales: " logs_path

# Pregunta por el número de ticket
read -p "Ingrese el número de ticket: " ticket_number

for index in "${!vm_array[@]}"; do
  clear
  vm_address=${vm_array[index]}
  echo "Conectando a la máquina virtual: $vm_address"
  echo ""

  # Crea la carpeta Logs-TICKET si no existe
  logs_folder="Logs-$ticket_number"

  if [ "${#vm_array[@]}" -gt 1 ]; then
    logs_folder="$logs_folder/nodo$((index+1))"
  fi

  # Conexión SSH a la máquina virtual y obtención de los logs
  ssh "$vm_address" "ls -lth \"$logs_path\"" | awk 'BEGIN{ count=1 } NR>1 { printf "%d. %s | Tamaño: %s\n", count++, $NF, $5 }' | head -n 20 > logs_list.txt

  # Función para mostrar el listado de logs
  function mostrar_listado_logs() {
    clear
    echo "Listado de logs - $vm_address (Últimos 20 logs...):"
    echo "-----------------"
    cat logs_list.txt
    echo "-----------------"
    echo "1. Descargar log(s)"
    echo "2. Siguiente máquina virtual"
    echo "3. Salir"
    echo

    read -p "Ingrese una opción: " option
    case $option in
      1)
        read -p "Ingrese el número(s) del log que desea descargar (separado por comas): " log_numbers
        IFS=',' read -ra nums <<< "$log_numbers"
        mkdir -p "$logs_folder"
        for num in "${nums[@]}"; do
          log_file=$(sed "${num}q;d" logs_list.txt | awk -F ' |: ' 'BEGIN{OFS=""} {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')

          scp -q "$vm_address:\"$logs_path/$log_file\"" "$logs_folder/"
          echo "Log \"$log_file\" descargado en la carpeta \"$PWD/$logs_folder/\"."
        done
        ;;
      2)
        rm -Rf logs_list.txt
        break
        ;;
      3)
        rm -Rf logs_list.txt
        exit
        ;;
      *)
        echo "Opción inválida. Intente nuevamente."
        ;;
    esac
  }

  # Mostrar el listado de logs
  mostrar_listado_logs

  rm -Rf logs_list.txt

  if [ "${#vm_array[@]}" -gt 1 ] && [ $((index+1)) -eq 1 ]; then
    echo ""
    read -n 1 -s -r -p "Pulse cualquier tecla para continuar con la descarga del nodo 2..."
  fi
done
