import os, shutil
from huggingface_hub import hf_hub_download
CO="/workspace/runpod-slim/ComfyUI"; M=CO+"/models"
# (repo_id, filename_in_repo, target_subdir, final_name)
JOBS=[
 ("Comfy-Org/Qwen-Image-Edit_ComfyUI",
  "split_files/diffusion_models/qwen_image_edit_2509_fp8_e4m3fn.safetensors",
  "diffusion_models","qwen_image_edit_2509_fp8_e4m3fn.safetensors"),
 ("Comfy-Org/Qwen-Image_ComfyUI",
  "split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors",
  "text_encoders","qwen_2.5_vl_7b_fp8_scaled.safetensors"),
 ("Comfy-Org/Qwen-Image_ComfyUI",
  "split_files/vae/qwen_image_vae.safetensors",
  "vae","qwen_image_vae.safetensors"),
 ("lightx2v/Qwen-Image-Lightning",
  "Qwen-Image-Edit-Lightning-8steps-V1.0.safetensors",
  "loras/QWEN","Qwen-Image-Edit-Lightning-8steps-V1.0.safetensors"),
]
for repo,fn,sub,final in JOBS:
    dest=os.path.join(M,sub); os.makedirs(dest,exist_ok=True)
    out=os.path.join(dest,final)
    if os.path.exists(out): print("SKIP",out,flush=True); continue
    print("DL",repo,fn,flush=True)
    p=hf_hub_download(repo_id=repo,filename=fn,local_dir=dest)
    if os.path.abspath(p)!=os.path.abspath(out): shutil.move(p,out)
    print("OK",out,os.path.getsize(out)//1048576,"MB",flush=True)
# опц. стилевая LoRA boreal-portraits — добавим когда будет источник:
# hf_hub_download(repo_id="<OWNER/REPO>", filename="<FILE>.safetensors", local_dir=os.path.join(M,"loras","QWEN"))
print("ALL_MODELS_DONE",flush=True)
