#!/bin/bash
set -e

# Qwen2.5-7B-Instruct
MODEL_PATH_QWEN="/models/Qwen2.5-7B-Instruct-Q4_K_M.gguf"
MODEL_URL_QWEN="https://huggingface.co/bartowski/Qwen2.5-7B-Instruct-GGUF/resolve/main/Qwen2.5-7B-Instruct-Q4_K_M.gguf"

# Gemma 3 4B
MODEL_PATH_GEMMA="/models/gemma-3-4b-it-Q4_K_M.gguf"
MODEL_URL_GEMMA="https://huggingface.co/bartowski/google_gemma-3-4b-it-GGUF/resolve/main/google_gemma-3-4b-it-Q4_K_M.gguf"

# GPT-OSS-20B
MODEL_PATH_GPTOSS="/models/gpt-oss-20b-Q4_K_M.gguf"
MODEL_URL_GPTOSS="https://huggingface.co/unsloth/gpt-oss-20b-GGUF/resolve/main/gpt-oss-20b-Q4_K_M.gguf"

# Function to download model if missing
download_model() {
    local path=$1
    local url=$2
    if [ ! -f "$path" ]; then
        echo "Model not found at $path, downloading..."
        mkdir -p /models
        curl -L -o "$path" "$url"
        echo "Download complete."
    else
        echo "Model already exists at $path"
    fi
}

# Download models
download_model "$MODEL_PATH_QWEN" "$MODEL_URL_QWEN"
download_model "$MODEL_PATH_GEMMA" "$MODEL_URL_GEMMA"
download_model "$MODEL_PATH_GPTOSS" "$MODEL_URL_GPTOSS"

exec /app/llama-server "$@"
