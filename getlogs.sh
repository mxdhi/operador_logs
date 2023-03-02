#!/bin/sh

# Solicitar número de ticket
echo "Introduce el número de ticket:"
read ticket

APLI="XXXXXXXXXXX"

# Crear carpeta con el número de ticket y nodos


ruta_log="/opt/$APLI/logs/"
dir_ticket="$ruta_log/$ticket/"
dir_nodo1="$ruta_log/$ticket/nodo1"
dir_nodo2="$ruta_log/$ticket/nodo2"

mkdir -p "$dir_nodo1"
mkdir -p "$dir_nodo2"

# Solicitar fecha
echo "Introduce la fecha (formato YYYY-MM-DD):"
read fecha

# Obtener la fecha de hoy
if [ "$fecha" = "$(date +%Y-%m-%d)" ]; then
  # Si la fecha es la de hoy, copiar archivos sin modificar el nombre
  echo "Extrayendo logs de hoy..."
  scp root@*SERVIDOR*:$ruta_log/ARCHIVO.log $dir_nodo1/
  scp root@*SERVIDOR*:$ruta_log/ARCHIVO.log $dir_nodo2/
else
# Si la fecha es anterior:
  echo "Extrayendo logs de la fecha $fecha..."
  scp root@*SERVIDOR*:$ruta_log/ARCHIVO_"$fecha"*.log $dir_nodo1/
  scp root@*SERVIDOR*:$ruta_log/ARCHIVO_"$fecha"*.log $dir_nodo2/

fi

# Mensaje de finalización
echo "Logs extraídos y guardados en la carpeta del ticket $dir_ticket"
