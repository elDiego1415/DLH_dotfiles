#!/bin/bash 

#desbloquea targeta Wifi 
if rfkill list wifi | grep -q "Soft blocked: yes"; then 
    echo "Wifi bloqueado " 
    read -p "Quieres desbloquear el wifi (s/n): " option

    if [[ "$option" == "s" || "$option" == "S" ]]; then 
        sudo rfkill unblock wifi 
        echo "Estado actual: "
        echo "---------------"
        rfkill list wifi 
    else 
        echo "Saliendo "
        read -p "Pulsa ENTER para salir " 
        exit 0
    fi
else 
    echo "Wifi esta desbloqueado "
    echo "-----------------------"
fi 

echo ""

#Reinicio NetworkManager
read -p "Quieres reiniciar servicios de Wifi? (s/n): " confirm
if [[ "$confirm" =~ ^[sS]$ ]]; then 
    echo "Reiniciando NetworkManager "
    echo "---------------------------"
    sudo systemctl restart NetworkManager 
    
    sleep 2 
    echo ""
else
    echo "No reiniciar servicios de Wifi"
fi 

#Comprovar pings
if ping -c 2 -W 2 google.com > /dev/null 2>&1; then 
    echo "Pings realizados correctamente "
else 
    echo "Pings fallidos  "
fi 
