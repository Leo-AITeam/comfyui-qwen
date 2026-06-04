#!/bin/bash
# Provision Qwen models then hand off to the stock RunPod ComfyUI start script.
# NOTE: no `set -e` — a model-download hiccup must not block ComfyUI/SSH/Jupyter.
CO=/workspace/runpod-slim/ComfyUI
if [ ! -d "$CO" ]; then
  echo "[entrypoint] seeding /workspace from baked ComfyUI..."
  cp -r /opt/comfyui-baked "$CO"
fi
echo "[entrypoint] downloading Qwen models (before ComfyUI starts)..."
python3.12 /download_models.py || echo "[entrypoint] WARN: model download non-zero; continuing"
echo "[entrypoint] handing off to /start.sh"
exec /start.sh
