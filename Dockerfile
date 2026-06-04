# ===========================================================================
# comfyui-qwen — self-contained, region-flexible Qwen-Image-Edit engine
# Base: official RunPod ComfyUI (Py3.12 + CUDA 12.8 + torch, ComfyUI baked at
# /opt/comfyui-baked, stock entrypoint /start.sh). Qwen-Edit Plus is NATIVE in
# ComfyUI core, so only Comfyroll + rgthree are added. Models pulled at start.
# No network volume; launches in ANY region.
# ===========================================================================
FROM runpod/comfyui:cuda12.8

# --- 1. Custom nodes (baked; /start.sh copies them to /workspace on launch) ---
RUN cd /opt/comfyui-baked/custom_nodes && \
    git clone --depth 1 https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes && \
    git clone --depth 1 https://github.com/rgthree/rgthree-comfy

# --- 2. Python deps into SYSTEM site-packages ---
RUN python3.12 -m pip install --no-cache-dir huggingface_hub && \
    for d in ComfyUI_Comfyroll_CustomNodes rgthree-comfy; do \
      if [ -f /opt/comfyui-baked/custom_nodes/$d/requirements.txt ]; then \
        python3.12 -m pip install --no-cache-dir -r /opt/comfyui-baked/custom_nodes/$d/requirements.txt; \
      fi; done

# --- 3. Baked API prompt template (ComfyUI userdata) ---
RUN mkdir -p /opt/comfyui-baked/user/default
COPY qwen_prompt_api.json /opt/comfyui-baked/user/default/qwen_prompt_api.json

# --- 3b. Placeholder input face (Qwen-Edit needs an input image for portrait gen) ---
RUN mkdir -p /opt/comfyui-baked/input
COPY placeholder.png /opt/comfyui-baked/input/placeholder.png

# --- 4. Model downloader + entrypoint ---
COPY download_models.py /download_models.py
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
