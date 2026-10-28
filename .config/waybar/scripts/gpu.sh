#!/bin/sh
# One nvidia-smi process, one JSON line per second for waybar
nvidia-smi -l 1 --format=csv,noheader,nounits \
  --query-gpu=utilization.gpu,memory.used,memory.total,utilization.memory,utilization.encoder,utilization.decoder,temperature.gpu,power.draw,fan.speed,pstate |
awk -F', ' '{
  printf "{\"text\":\"%s%%\",\"tooltip\":\"GPU: %s%%\\nVRAM: %s/%s MiB (%d%%)\\nMEM R/W: %s%%\\nENC: %s%%  DEC: %s%%\\nTEMP: %s°C\\nPOWER: %.1fW\\nFAN: %s%%\\nPSTATE: %s\"}\n",
    $1, $1, $2, $3, $2*100/$3, $4, $5, $6, $7, $8, $9, $10
  fflush()
}'
