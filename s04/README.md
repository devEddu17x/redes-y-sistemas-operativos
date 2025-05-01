# Redes y Sistemas Operativos - Semana 4

## Ejercicio 1: Crear un sistema de archivos XFS y montarlo

1.  **Crear directorio de montaje:**
    ```bash
    sudo mkdir /mnt/disco_xfs
    ```

2.  **Crear directorio para imágenes de disco (opcional):**
    ```bash
    mkdir ~/discos
    ```

3.  **Crear archivo de imagen de disco (simulación, 300MB):**
    ```bash
    dd if=/dev/zero of=~/discos/disco_xfs.img bs=1M count=300
    ```

4.  **Instalar herramientas XFS (si es necesario):**
    ```bash
    # Para Arch Linux / Manjaro:
    # sudo pacman -S xfsprogs
    # Para Debian / Ubuntu:
    # sudo apt install xfsprogs
    ```

5.  **Formatear la imagen con XFS:**
    ```bash
    mkfs.xfs ~/discos/disco_xfs.img
    ```

6.  **Asociar la imagen a un dispositivo loop:**
    ```bash
    sudo losetup -fP ~/discos/disco_xfs.img
    ```

7.  **Verificar el dispositivo loop asignado (ej. /dev/loop0):**
    ```bash
    losetup -l
    ```

8.  **Montar el dispositivo loop:** (Reemplaza `/dev/loop0` si `losetup -l` mostró uno diferente)
    ```bash
    sudo mount /dev/loop0 /mnt/disco_xfs/
    ```

9.  **Verificar el montaje:**
    ```bash
    df -hT /mnt/disco_xfs/
    ```

## Ejercicio 2: Automatizar el montaje en /etc/fstab

1.  **Crear copia de seguridad de fstab:**
    ```bash
    sudo cp /etc/fstab /etc/fstab.bak
    ```

2.  **Editar /etc/fstab:**
    ```bash
    sudo nano /etc/fstab
    ```

3.  **Añadir la siguiente línea al final de `/etc/fstab`** (Reemplaza `[TU_USUARIO]` con tu nombre de usuario real):
    ```fstab
    # Montaje disco XFS virtual
    /home/[TU_USUARIO]/discos/disco_xfs.img       /mnt/disco_xfs      xfs     defaults,loop,nofail 0 0
    ```

4.  **Recargar la configuración de systemd:**
    ```bash
    sudo systemctl daemon-reload
    ```

5.  **Montar todos los sistemas de archivos definidos en fstab (o intentar montar el nuevo):**
    ```bash
    sudo mount -a
    ```

6.  **Verificar que el dispositivo loop esté montado:**
    ```bash
    lsblk
    df -hT /mnt/disco_xfs/
    ```

## Ejercicio 3: Establecer cuotas de usuario en XFS

1.  **Editar `/etc/fstab` para añadir la opción de cuota:**
    ```bash
    sudo nano /etc/fstab
    ```

2.  **Modificar la línea del disco XFS añadiendo `usrquota` a las opciones:** (Reemplaza `[TU_USUARIO]`)
    ```fstab
    # Montaje disco XFS virtual con cuotas
    /home/[TU_USUARIO]/discos/disco_xfs.img       /mnt/disco_xfs      xfs     defaults,loop,nofail,usrquota 0 0
    ```

3.  **Recargar la configuración de systemd:**
    ```bash
    sudo systemctl daemon-reload
    ```

4.  **Desmontar y volver a montar el sistema de archivos para aplicar las opciones:**
    ```bash
    sudo umount /mnt/disco_xfs
    sudo mount /mnt/disco_xfs # O 'sudo mount -a' si prefieres
    # Alternativamente, si ya está montado sin la opción:
    # sudo mount -o remount /mnt/disco_xfs/
    ```

5.  **Verificar que la opción de cuota esté activa:**
    ```bash
    mount | grep /mnt/disco_xfs
    # Debería mostrar 'usrquota' entre las opciones entre paréntesis
    ```
    O también:
    ```bash
    sudo xfs_quota -x -c 'state' /mnt/disco_xfs
    # Debería indicar que 'User quota state' tiene 'Accounting: ON' y 'Enforcement: ON'
    ```

6.  **Crear un usuario de prueba:**
    ```bash
    sudo useradd testquota
    sudo passwd testquota # Asignarle una contraseña
    ```

7.  **Dar permisos de escritura al punto de montaje:** (Para que `testquota` pueda escribir)
    ```bash
    sudo chmod 777 /mnt/disco_xfs/
    ```

8.  **Establecer límites de cuota para el usuario `testquota`:** (10M suave, 12M duro para bloques; 5 suave, 7 duro para inodos/archivos)
    ```bash
    sudo xfs_quota -x -c 'limit -u bsoft=10m bhard=12m isoft=5 ihard=7 testquota' /mnt/disco_xfs
    ```

9.  **Verificar los reportes de cuota:**
    ```bash
    sudo xfs_quota -x -c 'report -h' /mnt/disco_xfs
    ```

10. **Probar los límites (opcional):**
    ```bash
    # Iniciar sesión como testquota
    su - testquota
    # (Puede dar un warning si el home no existe, es normal)
    cd /mnt/disco_xfs/

    # Probar límite de espacio (debería fallar al intentar escribir 15M)
    dd if=/dev/zero of=archivo_grande bs=1M count=15
    # Debería mostrar "Disk quota exceeded" y escribir solo hasta el límite duro (12M)
    ls -lh archivo_grande
    rm archivo_grande

    # Probar límite de inodos (debería fallar al crear el 8vo archivo)
    touch f1 f2 f3 f4 f5 f6 f7
    ls # Muestra 7 archivos
    touch f8 # Debería mostrar "Disk quota exceeded"
    rm f*

    # Salir de la sesión de testquota
    exit
    ```

## Ejercicio 4: Crear un RAID 0 con tres discos virtuales

1.  **Crear directorio para imágenes de disco RAID:**
    ```bash
    mkdir ~/discos/discos_raid0
    ```

2.  **Crear 3 archivos de imagen de disco (simulación, 300MB cada uno):**
    ```bash
    dd if=/dev/zero of=~/discos/discos_raid0/disco1.img bs=1M count=300
    dd if=/dev/zero of=~/discos/discos_raid0/disco2.img bs=1M count=300
    dd if=/dev/zero of=~/discos/discos_raid0/disco3.img bs=1M count=300
    ```

3.  **Asociar cada imagen a un dispositivo loop:**
    ```bash
    sudo losetup -fP ~/discos/discos_raid0/disco1.img
    sudo losetup -fP ~/discos/discos_raid0/disco2.img
    sudo losetup -fP ~/discos/discos_raid0/disco3.img
    ```

4.  **Verificar los dispositivos loop asignados (ej. /dev/loop1, /dev/loop2, /dev/loop3):**
    ```bash
    losetup -l
    lsblk
    # Anota qué dispositivos loop fueron asignados a estas imágenes
    ```

5.  **Crear el array RAID 0 (/dev/md0) con los dispositivos loop:** (Asegúrate de usar los 3 loops correctos asignados en el paso anterior, *no* el usado para XFS si sigue activo)
    ```bash
    # Reemplaza /dev/loop1 /dev/loop2 /dev/loop3 con los correctos si son diferentes
    sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=3 /dev/loop1 /dev/loop2 /dev/loop3
    ```

6.  **Verificar el estado del RAID:**
    ```bash
    cat /proc/mdstat
    lsblk
    ```

7.  **Formatear el array RAID 0 con ext4:**
    ```bash
    sudo mkfs.ext4 /dev/md0
    ```

8.  **Crear punto de montaje para RAID 0:**
    ```bash
    sudo mkdir /mnt/raid0
    ```

9.  **Montar el array RAID 0:**
    ```bash
    sudo mount /dev/md0 /mnt/raid0
    ```
    ```bash
    df -hT /mnt/raid0 # Verificar montaje y tamaño (~900MB)
    ```

## Ejercicio 5: Simular fallo de un disco y recuperación (con RAID 1)

*Nota: RAID 0 no tiene tolerancia a fallos. Este ejercicio demuestra la tolerancia a fallos de RAID 1, por lo que primero se deshace el RAID 0 y se crea un RAID 1.*

1.  **Deshacer el RAID 0 (`/dev/md0`) creado anteriormente:**
    * Desmontar:
        ```bash
        sudo umount /mnt/raid0
        ```
    * Detener el array:
        ```bash
        sudo mdadm --stop /dev/md0
        cat /proc/mdstat # Verificar que md0 ya no aparece como activo
        ```
    * Limpiar superbloques de los discos loop (para poder reutilizarlos):
        ```bash
        sudo mdadm --zero-superblock /dev/loop1
        sudo mdadm --zero-superblock /dev/loop2
        sudo mdadm --zero-superblock /dev/loop3
        # Reemplaza loop1/2/3 si usaste otros para el RAID 0
        ```

2.  **Crear un array RAID 1 (`/dev/md1`) con dos de los dispositivos loop:** (Ej: /dev/loop1, /dev/loop2)
    ```bash
    # Reemplaza /dev/loop1 /dev/loop2 si es necesario
    sudo mdadm --create --verbose /dev/md1 --level=1 --raid-devices=2 /dev/loop1 /dev/loop2
    # Responder 'y' a las preguntas sobre bitmap y continuar si aparecen
    ```

3.  **Verificar el estado del RAID 1:**
    ```bash
    cat /proc/mdstat # Debería mostrar [UU] indicando ambos discos activos y sincronizados
    ```

4.  **Formatear el array RAID 1 con ext4:**
    ```bash
    sudo mkfs.ext4 /dev/md1
    ```

5.  **Crear punto de montaje para RAID 1:**
    ```bash
    sudo mkdir /mnt/raid1
    ```

6.  **Montar el array RAID 1:**
    ```bash
    sudo mount /dev/md1 /mnt/raid1
    ```
    ```bash
    df -hT /mnt/raid1 # Verificar montaje y tamaño (~300MB)
    ```

7.  **Preparar para la simulación (crear datos de prueba):**
    ```bash
    sudo chmod 777 /mnt/raid1 # Ajustar permisos si es necesario
    cd /mnt/raid1
    sudo mkdir directorio_prueba
    sudo echo "Datos importantes en RAID 1" > archivo_prueba.txt
    ls -l # Verificar que los archivos existen
    cd ~ # Volver al home
    ```

8.  **Simular fallo de un disco (ej. /dev/loop1):**
    ```bash
    # Reemplaza /dev/loop1 si es necesario
    sudo mdadm /dev/md1 --fail /dev/loop1
    ```

9.  **Verificar estado degradado:**
    ```bash
    cat /proc/mdstat # Debería mostrar [_U] o [U_] y '(F)' junto al disco fallido
    sudo mdadm --detail /dev/md1 # Debería mostrar 'State: clean, degraded', 'Failed Devices: 1'
    ls -lR /mnt/raid1 # ¡Los datos deberían seguir accesibles gracias a RAID 1!
    cat /mnt/raid1/archivo_prueba.txt # Verificar contenido
    ```

10. **Recuperar el RAID (simulando reemplazo del disco):**
    * Remover el disco marcado como "fallido" del array:
        ```bash
        # Reemplaza /dev/loop1 si es necesario
        sudo mdadm /dev/md1 --remove /dev/loop1
        ```
    * (Opcional: Si fuera un disco físico, aquí lo reemplazarías. Para simulación, podemos reutilizar el mismo loop. Limpiar su superbloque es buena práctica si contenía metadatos antiguos, aunque `add` suele sobreescribirlo):
        ```bash
        # sudo mdadm --zero-superblock /dev/loop1
        ```
    * Añadir el disco (o uno "nuevo") de nuevo al array:
        ```bash
        # Reemplaza /dev/loop1 si es necesario
        sudo mdadm /dev/md1 --add /dev/loop1
        ```

11. **Verificar estado de recuperación/sincronización:**
    ```bash
    cat /proc/mdstat
    # Mostrará el estado de reconstrucción (resync) con un porcentaje.
    # Espera a que termine (puede ser rápido para discos pequeños).
    # Al finalizar, debe volver a mostrar [UU].

    # Verificar detalles una vez finalizada la sincronización
    sudo mdadm --detail /dev/md1
    # Debería volver a 'State: clean', 'Active Devices: 2', 'Failed Devices: 0', 'Working Devices: 2'
    ```

## Ejercicio 6: Automatizar configuración RAID con /etc/mdadm/mdadm.conf

1.  **Asegurarse que el RAID (ej. `/dev/md1`) está activo y estable:**
    ```bash
    cat /proc/mdstat
    ```

2.  **Obtener la línea de configuración del array activo:**
    ```bash
    sudo mdadm --detail --scan
    ```
    *(Copia la línea de salida que empieza con `ARRAY /dev/md1...`, la necesitarás)*

3.  **Crear el directorio de configuración (si no existe):**
    ```bash
    sudo mkdir -p /etc/mdadm
    ```

4.  **Crear o editar el archivo `mdadm.conf`:**
    ```bash
    sudo nano /etc/mdadm/mdadm.conf
    ```

5.  **Pegar la línea `ARRAY...` obtenida en el paso 2 dentro del archivo.** Asegúrate de que no haya líneas duplicadas si el archivo ya existía. Guarda y cierra el editor.

    *Alternativa (si el archivo no existe o está vacío, o quieres añadir al final):*
    ```bash
    sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
    ```

6.  **Verificar el contenido del archivo:**
    ```bash
    cat /etc/mdadm/mdadm.conf
    ```
    Debería contener la línea `ARRAY` para `/dev/md1` (el UUID variará):
    ```
    ARRAY /dev/md1 metadata=1.2 UUID=a8db5708:77ac4ba5:9a9b3b13:8ac90f8c name=archlinux:1
    ```
    *(Nota: El `name=...` puede o no aparecer)*

7.  **Probar la configuración automática:**
    * Desmontar el RAID:
        ```bash
        sudo umount /mnt/raid1
        ```
    * Detener el array RAID:
        ```bash
        sudo mdadm --stop /dev/md1
        cat /proc/mdstat # Verificar que md1 ya no está activo
        ```
    * Pedir a `mdadm` que ensamble los arrays definidos en el archivo de configuración:
        ```bash
        sudo mdadm --assemble --scan
        ```
        Debería indicar que `/dev/md1` (o `/dev/md/1`) ha sido iniciado.
    * Verificar que el RAID está activo nuevamente:
        ```bash
        cat /proc/mdstat
        lsblk
        ```
    * (Opcional) Volver a montar si es necesario para acceder a los datos:
        ```bash
        sudo mount /dev/md1 /mnt/raid1
        ```

## Ejercicio 8: Crear reglas udev para asignar permisos a un dispositivo USB

*Nota: Este ejemplo usa un pendrive Kingston específico como referencia del PDF. **Deberás adaptar** los valores `idVendor`, `idProduct`, `serial` y posiblemente `KERNEL` y `SUBSYSTEM` a **tu propio dispositivo USB**.*

1.  **Instalar `usbutils` (si no está presente):**
    ```bash
    # Para Arch Linux / Manjaro:
    # sudo pacman -S usbutils
    # Para Debian / Ubuntu:
    # sudo apt install usbutils
    ```

2.  **Identificar tu dispositivo USB:**
    * Conecta tu dispositivo USB.
    * Lista los dispositivos USB para obtener `idVendor` e `idProduct`:
        ```bash
        lsusb
        ```
        Busca la línea correspondiente a tu dispositivo y anota los dos números hexadecimales después de `ID` (ej: `0930:6544` donde `idVendor=0930` y `idProduct=6544`).
    * Lista los dispositivos de bloque para ver cómo lo reconoce el kernel (ej: `sda`, `sdb`, y sus particiones `sda1`, `sdb1`):
        ```bash
        lsblk
        ```
        Anota el nombre de la partición que quieres afectar (ej: `sda1`).

3.  **Obtener atributos udev específicos:** (Reemplaza `/dev/sda1` con el nombre correcto de tu dispositivo/partición)
    * Obtener el número de serie:
        ```bash
        sudo udevadm info -a -n /dev/sda1 | grep 'ATTRS{serial}'
        # Anota el valor entre comillas (ej: "001D0F184A3FCCA127312438")
        ```
    * Obtener el subsistema:
        ```bash
        sudo udevadm info -a -n /dev/sda1 | grep 'SUBSYSTEM=='
        # Busca la línea que corresponde directamente al dispositivo (ej: SUBSYSTEM=="block")
        ```

4.  **Añadir tu usuario a un grupo apropiado:** (El grupo `uucp` se usa en el PDF; `plugdev` o `storage` son comunes también. Elige uno.)
    ```bash
    # Reemplaza 'uucp' si eliges otro grupo, y '[tu_usuario]' con tu nombre de usuario
    sudo usermod -aG uucp [tu_usuario]
    # Puede que necesites cerrar sesión y volver a iniciar para que el cambio de grupo tenga efecto
    ```

5.  **Crear el archivo de reglas udev:** (El nombre `99-...` asegura que se ejecute tarde)
    ```bash
    sudo nano /etc/udev/rules.d/99-usb-personalizado.rules
    ```

6.  **Añadir la regla al archivo:** ( **¡IMPORTANTE!** Reemplaza los valores de `KERNEL`, `ATTRS{idVendor}`, `ATTRS{idProduct}`, `ATTRS{serial}` y `GROUP` con los que identificaste para **TU** dispositivo y grupo)
    ```udevrules
    # Regla para dar permisos específicos a mi dispositivo USB
    SUBSYSTEM=="block", KERNEL=="sd[a-z]1", ATTRS{idVendor}=="0930", ATTRS{idProduct}=="6544", ATTRS{serial}=="001D0F184A3FCCA127312438", MODE="0660", GROUP="uucp"
    ```
    * `SUBSYSTEM=="block"`: Aplica a dispositivos de bloque.
    * `KERNEL=="sd[a-z]1"`: Aplica a la primera partición de discos detectados como `sda`, `sdb`, etc. Ajusta si tu dispositivo es diferente (ej: `nvme0n1p1`) o si quieres afectar al disco entero (`KERNEL=="sd[a-z]"`).
    * `MODE="0660"`: Permisos de Lectura/Escritura para el propietario (root) y el grupo especificado. Sin permisos para otros.
    * `GROUP="uucp"`: Asigna el nodo del dispositivo al grupo `uucp`.

7.  **Recargar las reglas udev para aplicarlas:**
    ```bash
    sudo udevadm control --reload-rules
    ```

8.  **Probar:** Desconecta y vuelve a conectar tu dispositivo USB. Verifica los permisos del nodo de dispositivo (reemplaza `/dev/sda1`):
    ```bash
    ls -l /dev/sda1
    ```
    Debería mostrar permisos `brw-rw----` (dispositivo de bloque con r/w para root y el grupo) y el grupo debería ser `uucp` (o el que elegiste). Tu usuario (perteneciente a ese grupo) ahora debería poder acceder al dispositivo según esos permisos.

## Ejercicio 9: Registrar inserción de USB en un log con udev

1.  **Crear el archivo de log y el script:** (Puedes elegir otra ubicación si prefieres, ej. `/var/log` para logs del sistema, pero requeriría permisos adecuados en el script)
    ```bash
    # Usaremos un directorio en tu home para simplicidad
    mkdir -p ~/scripts/s04_udev_logs
    touch ~/scripts/s04_udev_logs/usb_activity.log
    touch ~/scripts/s04_udev_logs/log_usb_event.sh
    ```

2.  **Obtener la ruta absoluta del archivo log y del script:**
    ```bash
    realpath ~/scripts/s04_udev_logs/usb_activity.log
    realpath ~/scripts/s04_udev_logs/log_usb_event.sh
    ```
    *(Anota estas rutas completas, las necesitarás)*

3.  **Editar el script `log_usb_event.sh`:**
    ```bash
    nano ~/scripts/s04_udev_logs/log_usb_event.sh
    ```

4.  **Pegar el siguiente contenido en el script:** ( **¡IMPORTANTE!** Reemplaza `/ruta/absoluta/al/log/usb_activity.log` con la ruta completa del archivo log obtenida en el paso 2)
    ```bash
    #! /bin/bash

    LOG_FILE=/home/eddu/upao/redes-y-sistemas-operativos/s04/usb.log
    TIME="$(date)"
    echo "$TIME: USB AÑADIDO" >> "$LOG_FILE"
    echo "  DEVNAME: $DEVNAME" >> "$LOG_FILE"
    echo "  VENDOR: $ID_VENDOR_FROM_DATABASE ($ID_VENDOR_ID)" >> "$LOG_FILE"
    echo "  MODEL: $ID_MODEL_FROM_DATABASE ($ID_MODEL_ID)" >> "$LOG_FILE"
    echo "  SERIAL: $ID_SERIAL_SHORT" >> "$LOG_FILE"
    echo "--------------------------" >> "$LOG_FILE"

    exit 0
    ```

5.  **Hacer el script ejecutable:**
    ```bash
    chmod +x ~/scripts/s04_udev_logs/log_usb_event.sh
    ```

6.  **Crear la regla udev:** (El nombre `70-...` es un ejemplo, puede ser otro)

    ```bash
    sudo nano /etc/udev/rules.d/70-usb-log-activity.rules
    ```

7.  **Añadir la siguiente regla al archivo:** ( **¡IMPORTANTE!** Reemplaza `/ruta/absoluta/al/script/log_usb_event.sh` con la ruta completa del script obtenida en el paso 2)
    ```udevrules
    # Ejecuta un script cuando se añade un dispositivo USB principal
    ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", RUN+="/ruta/absoluta/al/script/log_usb_event.sh"

    # Opcional: Para loguear también cuando se quita el dispositivo
    # ACTION=="remove", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", RUN+="/ruta/absoluta/al/script/log_usb_event.sh"
    ```
    * `ACTION=="add"`: Se dispara solo cuando se conecta el dispositivo.
    * `SUBSYSTEM=="usb"`: Filtra por eventos del subsistema USB.
    * `ENV{DEVTYPE}=="usb_device"`: Intenta filtrar por el evento principal del dispositivo USB, no sus interfaces.
    * `RUN+="..."`: Ejecuta el script especificado.

8.  **Recargar las reglas udev:**
    ```bash
    sudo udevadm control --reload-rules
    ```

9.  **Probar:** Conecta y/o desconecta un dispositivo USB. Revisa el contenido del archivo log:
    ```bash
    cat ~/scripts/s04_udev_logs/usb_activity.log
    ```
    Deberías ver nuevas entradas registrando los eventos USB cada vez que ocurran.