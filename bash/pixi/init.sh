#!/usr/bin/env bash

set -o errexit -o xtrace

# Use sitecustomize.py so that specific Python packages can see python_libs packages
tee ${HOME}/.local/lib/python3.12/site-packages/sitecustomize.py << EOF
import sys
sys.path[0:0] = [
    "/opt/.pixi/envs/python/lib/python3.12/site-packages"
]
EOF

# Use Rprofile.site so that only pixi-installed R can see r_libs packages
echo ".libPaths('/opt/.pixi/envs/r-base/lib/R/library')" >> ${HOME}/.Rprofile

# Create config files for rstudio
mkdir -p ${HOME}/.config/rstudio
tee ${HOME}/.config/rstudio/database.conf << EOF
directory=${HOME}/.local/var/lib/rstudio-server
EOF

tee ${HOME}/.config/rstudio/rserver.conf << EOF
auth-none=1
database-config-file=${HOME}/.config/rstudio/database.conf
server-daemonize=0
server-data-dir=${HOME}/.local/var/run/rstudio-server
server-user=${USER}
EOF

# Register Juypter kernels
find ${HOME}/.pixi/envs/python/share/jupyter/kernels/ -maxdepth 1 -mindepth 1 -type d | \
    xargs -I % jupyter-kernelspec install --log-level=50 --user %
find ${HOME}/.pixi/envs/r-base/share/jupyter/kernels/ -maxdepth 1 -mindepth 1 -type d | \
    xargs -I % jupyter-kernelspec install --log-level=50 --user %
ark --install

# Jupyter configurations
mkdir -p $HOME/.jupyter && \
curl -s -o $HOME/.jupyter/jupyter_lab_config.py https://raw.githubusercontent.com/gaow/misc/master/bash/pixi/configs/jupyter/jupyter_lab_config.py && \
curl -s -o $HOME/.jupyter/jupyter_server_config.py https://raw.githubusercontent.com/gaow/misc/master/bash/pixi/configs/jupyter/jupyter_server_config.py

# VSCode configurations
mkdir -p ${HOME}/.config/code-server
curl -s -o $HOME/.config/code-server/config.yaml https://raw.githubusercontent.com/gaow/misc/master/bash/pixi/configs/vscode/config.yaml
mkdir -p ${HOME}/.local/share/code-server/User
curl -s -o $HOME/.local/share/code-server/User/settings.json https://raw.githubusercontent.com/gaow/misc/master/bash/pixi/configs/vscode/settings.json

code-server --install-extension ms-python.python
code-server --install-extension ms-toolsai.jupyter
code-server --install-extension reditorsupport.r
code-server --install-extension rdebugger.r-debugger
code-server --install-extension ionutvmi.path-autocomplete
code-server --install-extension usernamehw.errorlens
