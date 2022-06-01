# Installing TensorFlow 2.0

Installing TensorFlow with optional GPU support.

<!--BEGIN TOC-->
## Table of Contents
1. [CPU install](#cpu-install)
2. [GPU installation](#gpu-installation)
    1. [Docker](#docker)
3. [Validation](#validation)

<!--END TOC-->

## CPU install
CPU installation is a very simple
```bash
pip install tensorflow
```

## GPU installation
For GPU, you'll require at the very least CUDA. To see which TensorFlow your OS is compatible with, be sure to [check this list](https://www.tensorflow.org/install/source#tested_build_configurations).

For a native installation you will also require cuDNN, which I've written notes for [Debian here](https://github.com/fjebaker/notes/blob/master/hardware/debian-gpu.md).

If everything is correctly set up, you can just use
```bash
pip install tensorflow-gpu
```
to install GPU supported Tensorflow.

### Docker
As is recommended in the [installation guide](https://www.tensorflow.org/install/docker#gpu_support), you can also use a Docker image with cuDNN and TensorFlow GPU preinstalled. There are many images available in the [docker hub](https://hub.docker.com/r/tensorflow/tensorflow), and personally I use
```bash
docker pull tensorflow/tensorflow:latest-gpu-jupyter
```
Which I start with 
```bash
docker run -it \
    --rm \
    --gpus all \
    -v /path/to/notebooks:/tf/notebooks \
    -v /path/to/.jupyter:/root/.jupyter/ \
    -p 8888:8888 \
    tensorflow/tensorflow:latest-gpu-jupyter
```
**NB:** You will more than likely need the GPU [container runtime and runtime hook](https://collabnix.com/introducing-new-docker-cli-api-support-for-nvidia-gpus-under-docker-engine-19-03-0-beta-release/): the long-and-short of it is, once the drivers have been installed, create a script `nvidia-container-runtime-script.sh` with contents
```bash
curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | \
  sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
sudo apt-get update
```
Execute with 
```bash
sh nvidia-container-runtime-script.sh
```

You can check GPU Docker and nVidia driver installation validity with
```bash
docker pull nvidia/cuda:[version]
```
You may need to fetch your specific CUDA version image tag, which you can see with
```bash
nvcc --version
```
Run the container
```bash
docker run --gpus all --rm nvidia/cuda:[version]
```

My version combination is `nvidia/cuda:10.1-cudnn7-devel-ubuntu16.04`.

See here for troubleshooting some [nVidia](https://github.com/NVIDIA/nvidia-docker/issues/1034) docker images.

## Validation
We can [verify](https://www.codingforentrepreneurs.com/blog/install-tensorflow-gpu-windows-cuda-cudnn/) that TensorFlow has correctly identified the GPU with two Python lines
```py
from tensorflow.python.client import device_lib
print(device_lib.list_local_devices())
```
which should print the name of your GPU, and the PCI slot it is mounted in.
