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

# --- ReActor face-swap models (Stage-2) ---
IF=os.path.join(M,"insightface"); os.makedirs(IF,exist_ok=True)
insw=os.path.join(IF,"inswapper_128.onnx")
if not os.path.exists(insw):
    try:
        print("DL inswapper_128",flush=True)
        p=hf_hub_download(repo_id="Gourieff/ReActor",filename="models/inswapper_128.onnx",repo_type="dataset",local_dir=IF)
        if os.path.abspath(p)!=os.path.abspath(insw): shutil.move(p,insw)
        print("OK inswapper",os.path.getsize(insw)//1048576,"MB",flush=True)
    except Exception as e: print("WARN inswapper",e,flush=True)
else: print("SKIP inswapper",flush=True)
bl=os.path.join(IF,"models","buffalo_l")
if not os.path.exists(os.path.join(bl,"det_10g.onnx")):
    try:
        import urllib.request, zipfile
        os.makedirs(bl,exist_ok=True); z="/tmp/buffalo_l.zip"
        print("DL buffalo_l",flush=True)
        urllib.request.urlretrieve("https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l.zip",z)
        zipfile.ZipFile(z).extractall(bl); os.remove(z)
        print("OK buffalo_l",flush=True)
    except Exception as e: print("WARN buffalo_l",e,flush=True)
else: print("SKIP buffalo_l",flush=True)
print("ALL_MODELS_DONE",flush=True)
