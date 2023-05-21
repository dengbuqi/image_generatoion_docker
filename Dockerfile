FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04
#copy run.sh /usr/local/
ARG DEBIAN_FRONTEND=noninteractive
ARG COMMANDLINE_ARGS=--skip-torch-cuda-test
ENV TZ=Asia/Beijing
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update -y && apt -y upgrade
RUN apt -y install sudo git apt-utils dialog git-lfs wget python3 python3-pip python3-venv python3-tk ffmpeg libsm6 libxext6 tzdata
RUN apt -y install --no-install-recommends google-perftools
RUN apt clean
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN useradd --create-home --no-log-init --shell /bin/bash myuser \
    && adduser myuser sudo \
    && echo "myuser:myuser" | chpasswd
RUN echo 'myuser ALL=(ALL) NOPASSWD:ALL' >>  /etc/sudoers
WORKDIR "/home/myuser/"
USER myuser

CMD git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui
CMD git clone https://github.com/bmaltais/kohya_ss
CMD sudo ./kohya_ss/setup.sh -d ./kohya_ss -u -v
CMD cp ./stable-diffusion-webui/launch.py ./stable-diffusion-webui/launch_bak.py
CMD sed -i '$d' ./stable-diffusion-webui/launch.py
ARG TORCH_COMMAND="pip install torch==2.0.0 torchvision torchaudio xformers"
CMD ./stable-diffusion-webui/webui.sh -port 80 -listen -enable-insecure-extension-access
CMD cp ./stable-diffusion-webui/launch_bak.py ./stable-diffusion-webui/launch.py
CMD rm ./stable-diffusion-webui/launch_bak.py
# RUN source ./stable-diffusion-webui/venv/bin/activate
# RUN python3 -m pip uninstall torch torchvision torchaudio xformers -y
# RUN python3 -m pip --no-cache-dir install torch==2.0.0 xformers torchvision torchaudio
# RUN deactivate
CMD wget -q https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors -O /home/myuser/stable-diffusion-webui/models/Stable-diffusion/v1-5-pruned-emaonly.safetensors 
# CMD ["/bin/bash", "-c", "./stable-diffusion-webui/webui.sh", "--port", "80", "--listen", "--enable-insecure-extension-access", "&" "/bin/bash", "-c", "./kohya_ss/gui.sh", "--listen", "0.0.0.0", "--server_port", "8080"]
CMD ./stable-diffusion-webui/webui.sh --port  80  --listen --enable-insecure-extension-access & ./kohya_ss/gui.sh --listen 0.0.0.0 --server_port 8080
 