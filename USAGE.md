***
Setup llama.cpp HTTP Server with ROCm (AMD 6750 XT)

Run llama.cpp as an HTTP server inside a Docker container, utilizing the AMD Radeon 6750 XT GPU via ROCm.

## Specifications

| Component | Value |
|-----------|-------|
| GPU | AMD Radeon 6750 XT (Architecture: gfx1031) |
| CPU | Intel® Core™ i7-6700K Processor |
| RAM | 32 GB RAM |
| Models | Qwen2.5-7B-Instruct-Q4_K_M.gguf (32K), Gemma-3-4B-Q4_K_M.gguf (128K), gpt-oss-20b-Q4_K_M (128K) |
| Router Mode | Enabled (via `--models-preset` and `models.ini`) |

---

## Step 1: Clone Repository

Get the latest llama.cpp source code (modified).

```bash
git clone https://github.com/endymion2k14/llama.cpp
cd llama.cpp
```

## Step 2: Build Docker Image

Build the server target (includes `llama-server` executable).

```bash
docker build -t llama.cpp-rocm-server --target server -f .devops/rocm.Dockerfile .
```

> **Note:** This compilation may take several minutes. (~45 minutes on this system)

## Step 3: Run llama.cpp HTTP Server Container

Start the server in detached mode.

```bash
docker run -d \
  --name llama-server \
  --device /dev/kfd \
  --device /dev/dri \
  --group-add video \
  --security-opt seccomp=unconfined \
  -e HSA_OVERRIDE_GFX_VERSION=10.3.0 \
  -v llama-models:/models \
  -p 8080:8080 \
  llama.cpp-rocm-server \
  --models-preset /app/models.ini \
  --models-max 1 \
  --models-autoload \
  --jinja \
  --port 8080 \
  --host 0.0.0.0
```

## Step 4: Add provider (~/.config/opencode/opencode.json)
```
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "llama.cpp (server)",
      "options": {
        "baseURL": "http://192.168.2.120:8080/v1"
      },
      "models": {
        "Qwen2.5-7B-Instruct-Q4_K_M": {
          "tools": true,
          "tool_choice": "auto"
        },
        "GPT-OSS-20B-Q4_K_M": {
          "tools": true,
          "tool_choice": "auto"
        }
      }
    }
  },
  "model": "Qwen2.5-7B-Instruct-Q4_K_M"
}
```

## Step 5: Add to Open-WebUI

Goto Admin Panel, Settings, Connections.
Enable OpenAI API.
Create a new OpenAI API to: http://192.168.2.120:8080
Disable Ollama API.

### Environment Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `HSA_OVERRIDE_GFX_VERSION` | `10.3.0` | Override GPU architecture version |

### llama-server Options

| Flag | Description |
|------|-------------|
| `--models-preset` | Path to INI file containing model presets |
| `--models-max N` | Maximum number of models loaded simultaneously (0 = unlimited) |
| `--models-autoload` | Automatically load models on demand (default: enabled) |
| `--port` | Server port |
| `--host` | Host bind address |
| `n-gpu-layers` | Number of GPU layers (per model in `models.ini`), supports `auto` for automatic detection |
| `ctx-size` | Context length (per model in `models.ini`) |
| `chat-template-file` | Custom chat template file (per model in `models.ini`) |
| `flash-attn` | Flash attention (per model in `models.ini`) |
| `jinja` | Enable Jinja template processing (per model in `models.ini`) |
| `cache-ram` | Maximum cache size in MiB (global in `models.ini`) |
| `models-max` | Maximum models loaded simultaneously (global in `models.ini`) |
