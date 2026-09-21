#!/bin/bash
set -x

# Variables (Terraform injected)
CRIBL_DIR="${CRIBL_DIR}"
CRIBL_LEADER_IP="${CRIBL_LEADER_IP}"
CRIBL_WORKER_PORT="${CRIBL_WORKER_PORT}"
CRIBL_LOG_FILE="${CRIBL_LOG_FILE}"
CRIBL_DIST_TOKEN="${CRIBL_DIST_TOKEN}"


# Logging setup
sudo mkdir -p "$(dirname $${CRIBL_LOG_FILE})"
sudo touch "$${CRIBL_LOG_FILE}"
sudo chmod 644 "$${CRIBL_LOG_FILE}"
exec > >(sudo tee -a $${CRIBL_LOG_FILE} | logger -t cribl-worker-userdata -s 2>/dev/console) 2>&1

echo "Installing Cribl Worker..."
sudo apt update -y
# sudo apt install -y curl tar gzip jq

# Create cribl user if not exists
id -u cribl &>/dev/null || sudo useradd -r -s /bin/bash cribl

if [ ! -d "$${CRIBL_DIR}/bin" ]; then
    cd /opt
    sudo curl -fsSL "$(curl -fsSL https://cdn.cribl.io/dl/latest-x64)" | sudo tar xzv
    sudo chown -R cribl:cribl "$${CRIBL_DIR}"
fi

# Start Cribl Worker
echo "[INFO] Starting Cribl Worker service..."
sudo -u cribl ${CRIBL_DIR}/bin/cribl mode-worker -H ${CRIBL_LEADER_IP} -p ${CRIBL_WORKER_PORT} -u $CRIBL_DIST_TOKEN
sudo -u cribl ${CRIBL_DIR}/bin/cribl start


# Verify Worker Service
if sudo -u cribl "${CRIBL_DIR}/bin/cribl" status | grep 'Up'; then
  echo "Cribl Worker process started successfully."
else
  echo "Cribl Worker failed to start."
  sudo -u cribl "${CRIBL_DIR}/bin/cribl" status || true
  exit 1
fi

# Auto-Verify Worker Registration
echo "[INFO] Verifying registration with Cribl Leader..."

MAX_RETRIES=20
SLEEP_INTERVAL=15
SUCCESS=false

for i in $(seq 1 $${MAX_RETRIES}); do
  echo "[INFO] Checking Leader API (attempt $${i}/$${MAX_RETRIES})..."
  
  RESPONSE=$(curl -s --max-time 10 "http://${CRIBL_LEADER_IP}:9000/api/v1/workers" | jq -r '.[]?.name' || true)
  
  if echo "$${RESPONSE}" | grep -iq "$(hostname)"; then
    echo "[Worker '$(hostname)' successfully registered with Leader."
    SUCCESS=true
    break
  else
    echo "Worker not yet registered. Retrying in $${SLEEP_INTERVAL}s..."
    sleep $${SLEEP_INTERVAL}
  fi
done

if [ "$${SUCCESS}" = false ]; then
  echo "Worker registration with Leader failed after $${MAX_RETRIES} attempts."
  exit 1
fi

echo "Cribl Worker setup and registration complete at $(date)"