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