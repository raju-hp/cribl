#!/bin/bash
set -x

# Variables (Terraform injected)
CRIBL_DIR="${CRIBL_DIR}"
CRIBL_WORKER_PORT="${CRIBL_WORKER_PORT}"
CRIBL_LOG_FILE="${CRIBL_LOG_FILE}"
CRIBL_DIST_TOKEN="${CRIBL_DIST_TOKEN}"

# Logging setup
sudo mkdir -p "$(dirname $${CRIBL_LOG_FILE})"
sudo touch "$${CRIBL_LOG_FILE}"
sudo chmod 644 "$${CRIBL_LOG_FILE}"
exec > >(sudo tee -a $${CRIBL_LOG_FILE} | logger -t cribl-leader-userdata -s 2>/dev/console) 2>&1

echo "Installing Cribl Stream..."

sudo apt update -y
# sudo apt install -y curl tar gzip jq

# Create cribl user if not exists
id -u cribl &>/dev/null || sudo useradd -r -s /bin/bash cribl

if [ ! -d "$${CRIBL_DIR}/bin" ]; then
    cd /opt
    sudo curl -fsSL "$(curl -fsSL https://cdn.cribl.io/dl/latest-x64)" | sudo tar xzv
    sudo chown -R cribl:cribl "$${CRIBL_DIR}"
    sleep 30
fi

# Start Cribl in leader mode
echo "[INFO] Starting Cribl Leader..."
# sudo -u cribl $CRIBL_DIR/bin/cribl mode-master
# sudo -u cribl $CRIBL_DIR/bin/cribl start
sudo -u cribl bash -c "export CRIBL_DIST_MODE=leader CRIBL_DIST_LEADER_URL=tcp://$${IBL_DIST_TOKEN:-$${CRIBL_DIST_TOKEN}}@0.0.0.0:4200 && ${CRIBL_DIR}/bin/cribl start"

# Verify Leader Service
if sudo -u cribl "${CRIBL_DIR}/bin/cribl" status | grep 'Up'; then
  echo "Cribl Leader process started successfully."
else
  echo "Cribl Leader failed to start."
  sudo -u cribl "${CRIBL_DIR}/bin/cribl" status || true
  exit 1
fi