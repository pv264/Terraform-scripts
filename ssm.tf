 #Manages the parameter for the Database instance (Milvus)
resource "aws_ssm_parameter" "db_uri" {
  name        = "MILVUS_URI"
  description = "The private URI for the Milvus DB instance."
  type        = "String"
  value       = "http://${aws_instance.db.private_ip}:19530"
  overwrite   = true
}

# Manages the parameter for the Embedding instance
resource "aws_ssm_parameter" "embed_url" {
  name        = "VLLM_EMBEDDING_API_BASE_URL"
  description = "The private URL for the embedding instance."
  type        = "String"
  value       = "http://${aws_instance.embed.private_ip}:9020/v1"
  overwrite   = true
}

# Manages the parameter for the vLLM instance
resource "aws_ssm_parameter" "vllm_url" {
  name        = "VLLM_API_BASE_URL"
  description = "The private URL for the vLLM instance."
  type        = "String"
  value       = "http://${aws_instance.vllm[0].private_ip}:8000/v1"
  overwrite   = true
}

# --- NEW PARAMETERS ADDED BELOW ---

# 1. Manages the parameter for the Redis instance IP
resource "aws_ssm_parameter" "redis_ip" {
  name        = "REDIS_HOST_IP"
  description = "The private IP for the Redis instance."
  type        = "String"
  value       = aws_instance.redis.private_ip
  overwrite   = true
}

# 2. Manages the parameter for the Langfuse host
resource "aws_ssm_parameter" "langfuse_host" {
  name        = "LANGFUSE_HOST"
  description = "The private host URL for the Langfuse service."
  type        = "String"
  value       = "http://${aws_instance.monitoring.private_ip}:3000"
  overwrite   = true
}

# 3. Manages the parameter for the OTEL endpoint
resource "aws_ssm_parameter" "otel_endpoint" {
  name        = "OTEL_EXPORTER_OTLP_ENDPOINT"
  description = "The private endpoint for the OpenTelemetry collector."
  type        = "String"
  value       = "http://${aws_instance.monitoring.private_ip}:4317"
  overwrite   = true
}

