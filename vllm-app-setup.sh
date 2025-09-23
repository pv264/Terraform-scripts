#!/bin/bash
#exec > /tmp/db-setup.log 2>&1

set -e  # Exit immediately on error
set -x

DIR=~/haystack_poc
# Version check
nvidia-smi
/usr/local/cuda/bin/nvcc -V || true
nvidia-container-cli -V || true
docker -v

# AWS SSM parameter names
ACCESS_KEY_PARAM="ACCESS_KEY"
SECRET_KEY_PARAM="SECRET_KEY"
AWS_REGION="us-east-1" # or your appropriate region

# Fetch credentials from SSM
echo "Fetching AWS credentials from SSM..."
AWS_ACCESS_KEY=$(aws ssm get-parameter --name "$ACCESS_KEY_PARAM" --query "Parameter.Value" --output text)
AWS_SECRET_KEY=$(aws ssm get-parameter --name "$SECRET_KEY_PARAM" --query "Parameter.Value" --output text)

if [[ -z "$AWS_ACCESS_KEY" || -z "$AWS_SECRET_KEY" ]]; then
  echo "Failed to retrieve credentials from SSM. Exiting."
  exit 1
fi

# Configure AWS CLI
mkdir -p ~/.aws
cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id = $AWS_ACCESS_KEY
aws_secret_access_key = $AWS_SECRET_KEY
EOF

cat > ~/.aws/config <<EOF
[default]
region = $AWS_REGION
output = json
EOF

echo "AWS CLI configured."

# --- Git setup ---
ADO_PAT="ADO_PAT"
REPO_NAME="REPO_NAME"
USER="USER"

VLLM_API_KEY="VLLM_API_KEY"
VLLM_MODEL="VLLM_MODEL"
VLLM_API_BASE_URL="VLLM_API_BASE_URL"
VLLM_MAX_TOKENS="VLLM_MAX_TOKENS"
VLLM_TEMPERATURE="VLLM_TEMPERATURE"
VLLM_TIMEOUT="VLLM_TIMEOUT"
MILVUS_URI_KEY="MILVUS_URI"
VLLM_EMBEDDING_MODEL="VLLM_EMBEDDING_MODEL"
VLLM_EMBEDDING_API_BASE_URL="VLLM_EMBEDDING_API_BASE_URL"
#REDIS_URI_KEY="REDIS_URI"
# LANGFUSE_SECRET_KEY="LANGFUSE_SECRET_KEY"
# LANGFUSE_PUBLIC_KEY="LANGFUSE_PUBLIC_KEY"

# Retrieve the parameter from AWS SSM and store it in the variable
ADO_PAT_VALUE=$(aws ssm get-parameter --name "$ADO_PAT" --query "Parameter.Value" --output text)
REPO_NAME_VALUE=$(aws ssm get-parameter --name "$REPO_NAME" --query "Parameter.Value" --output text)
USER_VALUE=$(aws ssm get-parameter --name "$USER" --query "Parameter.Value" --output text)
# Check if the retrieval was successful

if [[ -z "$ADO_PAT_VALUE" || -z "$REPO_NAME_VALUE" || -z "$USER_VALUE" ]]; then
  echo "Failed to fetch Git credentials from SSM. Exiting."
  exit 1
fi

rm -rf "$DIR"
git clone https://${USER_VALUE}:${ADO_PAT_VALUE}@dev.azure.com/Applied-GenAI/GenAI_HCTRA_CSR_Training_App/_git/${REPO_NAME_VALUE} "$DIR"
cd "$DIR"
git switch task-776/detach-langfuse-jaeger-prometheus-grafana-loki

# --- IP and Endpoint Setup ---
# This instance determines its OWN URL
VLLM_API_BASE_URL="http://$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):8000/v1"

# This instance FETCHES the URLs of OTHER services from SSM
MILVUS_URI=$(aws ssm get-parameter --name "MILVUS_URI" --query "Parameter.Value" --output text)

# --- Get other parameter values ---
VLLM_API_KEY_VALUE=$(aws ssm get-parameter --name "VLLM_API_KEY" --query "Parameter.Value" --output text)
VLLM_MODEL_VALUE=$(aws ssm get-parameter --name "VLLM_MODEL" --query "Parameter.Value" --output text)
VLLM_MAX_TOKENS_VALUE=$(aws ssm get-parameter --name "VLLM_MAX_TOKENS" --query "Parameter.Value" --output text)
VLLM_TEMPERATURE_VALUE=$(aws ssm get-parameter --name "VLLM_TEMPERATURE" --query "Parameter.Value" --output text)
VLLM_TIMEOUT_VALUE=$(aws ssm get-parameter --name "VLLM_TIMEOUT" --query "Parameter.Value" --output text)
VLLM_EMBEDDING_MODEL_VALUE=$(aws ssm get-parameter --name "VLLM_EMBEDDING_MODEL" --query "Parameter.Value" --output text)
# This was the only required change
EMBEDDING_API_URL=$(aws ssm get-parameter --name "VLLM_EMBEDDING_API_BASE_URL" --query "Parameter.Value" --output text)

# --- .env creation ---
if [ ! -f "$DIR/.env" ]; then
  echo "Creating .env file..."
  cat > "$DIR/.env" <<EOF
VLLM_API_KEY=$VLLM_API_KEY_VALUE
VLLM_MODEL=$VLLM_MODEL_VALUE
VLLM_API_BASE_URL=$VLLM_API_BASE_URL
VLLM_MAX_TOKENS=$VLLM_MAX_TOKENS_VALUE
VLLM_TEMPERATURE=$VLLM_TEMPERATURE_VALUE
VLLM_TIMEOUT=$VLLM_TIMEOUT_VALUE
MILVUS_URI=$MILVUS_URI
VLLM_EMBEDDING_MODEL=$VLLM_EMBEDDING_MODEL_VALUE
VLLM_EMBEDDING_API_BASE_URL=$VLLM_EMBEDDING_API_BASE_URL
HAYSTACK_CONTENT_TRACING_ENABLED=True
WORKERS=24
EOF
else
  echo ".env already exists. Skipping."
fi

# --- Pull fine-tuned model ---
TARGET_DIR=~/finetuned_model
mkdir -p "$TARGET_DIR"

if [ -z "$(ls -A "$TARGET_DIR")" ]; then
  echo "Copying fine-tuned model from S3..."
  aws s3 cp s3://ti-hctra-fine-tuned-model/HCTRA_fine_tuned_models/Final_Model/full_model/ "$TARGET_DIR" --recursive
else
  echo "Model directory is not empty. Skipping copy."
fi

# --- Launch Docker containers ---
#line113 is for launching only vllm container
docker compose -f "$DIR/vllm/docker_vllm_compose.yml" up -d --build vllm-server

#docker compose -f "$DIR/vllm/docker_vllm_compose.yml" up -d --build


docker compose -f "$DIR/monitoring/docker_vllm_exporters_compose.yml" up -d --build


echo "Setup complete."
