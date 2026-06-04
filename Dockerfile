# ===========================================================================
# comfyui-qwen — Qwen-Image-Edit engine + ReActor face-swap (Stage-2 identity)
# Base: official RunPod ComfyUI (Py3.12 + CUDA 12.8). Models pulled at start.
# ===========================================================================
FROM runpod/comfyui:cuda12.8

# --- 1. Custom nodes (baked; copied to /workspace on launch) ---
RUN cd /opt/comfyui-baked/custom_nodes && \
    git clone --depth 1 https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes && \
    git clone --depth 1 https://github.com/rgthree/rgthree-comfy

# --- 2. Python deps into SYSTEM site-packages ---
RUN python3.12 -m pip install --no-cache-dir huggingface_hub && \
    for d in ComfyUI_Comfyroll_CustomNodes rgthree-comfy; do \
      if [ -f /opt/comfyui-baked/custom_nodes/$d/requirements.txt ]; then \
        python3.12 -m pip install --no-cache-dir -r /opt/comfyui-baked/custom_nodes/$d/requirements.txt; \
      fi; done

# --- 2b. ReActor face-swap node + deps (Stage-2 identity swap) ---
RUN apt-get update && apt-get install -y --no-install-recommends build-essential cmake ffmpeg libgl1 libglib2.0-0 && rm -rf /var/lib/apt/lists/* || true
RUN cd /opt/comfyui-baked/custom_nodes && \
    git clone --depth 1 https://github.com/Gourieff/ComfyUI-ReActor && \
    python3.12 -m pip install --no-cache-dir "numpy<2" Cython && \
    python3.12 -m pip install --no-cache-dir onnx onnxruntime-gpu insightface==0.7.3 && \
    ( [ -f ComfyUI-ReActor/requirements.txt ] && python3.12 -m pip install --no-cache-dir -r ComfyUI-ReActor/requirements.txt || true ) && \
    python3.12 -m pip install --no-cache-dir "numpy<2"

# --- 3. Baked API prompt template (ComfyUI userdata) ---
RUN mkdir -p /opt/comfyui-baked/user/default
COPY qwen_prompt_api.json /opt/comfyui-baked/user/default/qwen_prompt_api.json

# --- 3b. Placeholder input face ---
RUN mkdir -p /opt/comfyui-baked/input
COPY placeholder.png /opt/comfyui-baked/input/placeholder.png

# --- 4. Model downloader + entrypoint ---
COPY download_models.py /download_models.py
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# rebuild: add ReActor face-swap (Stage-2) for B pipeline
