#!/bin/bash


while true 
do 
        clear 

        disk_info=$(df -h / | awk 'NR==2 {print "Disco /: " $4 " libres de " $2 " (" $5 " usado)"}')
        #Menu
        echo "+-------------------------+"
        echo "| 1:Snapshot + Actualizar |"
        echo "| 2:Rollback              |"
        echo "| 3:Salir                 |"
        echo "+-------------------------+"

        echo "$disk_info"
        read -p "Opcion: " opcion 
	
        case "$opcion" in 
                        
                1 )
                        #Comando para egecutar las snapshots
                        echo "Realizando snapshot"
                        sudo timeshift --create --comments 'Snapshot antes de update' --tags D

                        if [ $? -ne 0 ]; then
                                echo "Error al crear la snapshot"
                                exit 1
                        fi

                        #Actualizar el sistema
                        echo "Actualizando sistema"
			yay -Syu 
                        read -p "Pulsa ENTER para salir "
                        ;;
                2 )
                        #Funcion de rollback 
                        echo "Snapshots disponibles "
                        sudo timeshift --list
                        
                        read -p "Estas seguro de que quieres restaurar el sistema?(s/n) " confirm
                        if [[ "$confirm" = "s" || "$confirm" = "S" ]]; then 
                                sudo timeshift --restore 
                        else 
                                echo "Cancelado"
                                read -p "Pulsa cualquier tecla para salir " 
                                exit 1 
                        
                        fi
                        
                        

                        ;;
                3)      
                        echo "Saliendo"
                        break
                        ;;
                *)      
                        echo "Opción no valida"
                        ;;
        esac 
done 
