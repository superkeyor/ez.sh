
# ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
# > docker
# ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
ez_docker_up() {
    local composefile=${1:-"/data/caddy/docker-compose.yml"}
    sudo docker compose -f $composefile up -d
}

ez_docker_down() {
    local composefile=${1:-"/data/caddy/docker-compose.yml"}
    sudo docker compose -f $composefile down
}

ez_docker_start() {
    sudo docker start $1
}

ez_docker_stop() {
    sudo docker stop $1
}

ez_docker_restart() {
    sudo docker restart $1
}

ez_docker_logs() {
    sudo docker logs -f $1
}

ez_docker_exec() {
    local shell=${1:-"bash"}
    sudo docker exec -it $1 $shell
}

ez_docker_rm() {
    sudo docker rm $1
}

ez_docker_prune() {
    sudo docker system prune -a
    sudo docker system prune --force
    sudo docker image prune --force
}

ez_docker_list() {
    sudo docker ps -a
    sudo docker images
}

# ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
# > installer
# ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
ez_install_docker() {
    # # DOCKER GROUP
    # # https://github.com/moby/moby/issues/9976
    # # not recommended??
    # # if not exist run the following two:
    # # sudo groupadd docker
    # # sudo systemctl restart docker
    # grep docker /etc/group
    # sudo usermod -aG docker $USER
    # reboot # to make effective
    # groups $USER
    # # being in the docker group essentially grants root access, without sudo
    
    # DOCKER PORTS
    # https://askubuntu.com/a/652572/586989
    # Docker makes changes directly on your iptables, which are not shown with ufw status.
    # Bind containers locally so they are not exposed outside your machine
    # docker run -p 127.0.0.1:8080:8080 ...
    # if need to be available externally, simply 8080:8080, or use caddy to reverse_proxy localhost:8080
    
    # install docker
    local version=${1:-"25.0"}
    if [[ $(command -v docker) == "" ]]; then
        sudo apt update # && sudo apt upgrade -y
        echo "Installing Docker..."
        curl -fsSL get.docker.com -o get-docker.sh 
        sudo sh get-docker.sh --version $version
        
        sudo systemctl enable docker
        sudo systemctl start docker

        sudo usermod -aG docker $USER
          
        rm get-docker.sh
        # logout required after usermod
        echo "Logout/re-login to run docker without sudo"
    else
        echo "Docker already installed."
        docker --version
    fi
}

ez_install_caddy() {
    if [[ $(command -v caddy) == "" ]]; then
        echo "Installing Caddy..."
        # https://caddyserver.com/docs/install#debian-ubuntu-raspbian
        # install caddy so that I can have the service, even though later I recompile caddy
        sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
        curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
        curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
        sudo apt update
        sudo apt install caddy -y
    else
        echo "Caddy already installed."
        caddy version
    fi
}

ez_install_anaconda() {
    local version=${1:-"2023.07"}
    local architecture=$(uname -m)  # x86_64 or aarch64
    local anacondaversion=$(echo "Anaconda3-${version}-Linux-${architecture}")
    if [[ $(command -v $HOME/anaconda3/bin/python) == "" ]]; then
        echo "Installing Anaconda..."
        curl https://repo.anaconda.com/archive/${anacondaversion}.sh --output ${anacondaversion}.sh
        bash ${anacondaversion}.sh
        # no need to initialize Anaconda3 (my .bashrc has taken care of it)
        # may need to restart bash?
        $HOME/anaconda3/bin/conda activate base
        pip install ez --upgrade --no-cache-dir
        # for email via python
    else
        echo "Anaconda already installed."
        $HOME/anaconda3/bin/python --version
    fi
}

# ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
# > git and github
# ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
ez_git_init() {
    # .gitignore
cat <<'EOF' | tee .gitignore >/dev/null
# mypy
secret.py
pysecrets.py
.mypy_cache/
.dmypy.json
dmypy.json

# macOS specific
.DS_Store
.AppleDouble
.LSOverride

# Icon must end with two \r
Icon

# Thumbnails
._*

# Files that might appear in the root of a volume
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent

# Directories potentially created on remote AFP share
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.apdisk

# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# PyInstaller
# Usually, these files are written by a python script from a template
# before PyInstaller builds the exe, so as to inject date/other infos into it.
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/
build/docs/

# PyBuilder
target/

# Jupyter Notebook
.ipynb_checkpoints

# pyenv
.python-version

# celery beat schedule file
celerybeat-schedule

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# Pyre type checker
.pyre/

# pytype static type analyzer
.pytype/

# Cython debug symbols
cython_debug/
EOF
    # license LGPL
    [ ! -f "LICENSE" ] && curl -O https://raw.githubusercontent.com/superkeyor/ez.sh/main/LICENSE
    # README.md
cat <<'EOF' | tee README.md >/dev/null
# ez.sh
frequently used shell/bash functions
EOF
    # initialize a git repository
    git init
    git add .
    git commit -m "first commit"
    echo "Initialized. Please edit README.md and .gitignore"
    echo "Create a new repository on github: go to https://github.com/new (only fill in name, rest empty)"
    echo "Then link: git remote add origin git@github.com:superkeyor/ez.sh.git"
    echo "Ready to push."
}

ez_git_commit() {
    # commit with message (default: "update")
    local message=${1:-"update"}
    git add .
    git commit -m "$message"
}

ez_git_push() {
    git branch -M main
    git push -u origin main
}

ez_git_pull() {
    # pull from github
    git pull origin main
}

# ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
# > self maintenance
# ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
ez_updateself() {
    # update this script by downloading from github and saving it to ~/.ez.sh
    curl https://raw.githubusercontent.com/superkeyor/ez.sh/main/ez.sh -o .ez.sh && mv -f .ez.sh ~/.ez.sh
}

ez_reload() {
    # reload this script
    [ ! -f ~/.ez.sh ] && ez_updateself
    source ~/.ez.sh
}

# ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
# > server management
# ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
ez_scp() {
    # ez_scp "-p 22 root@192.168.1.1" :/root/rc.local.log ./r.log
    # ssh root@192.168.1.1 "dd if='/root/rc.local.log' bs=1M" | dd of="./r.log" bs=1M status=progress
    if [[ "$1" == "--help" || "$#" -ne 3 ]]; then
        echo "Usage: ez_scp [remote_host] [source] [destination]"
        echo "Description: Securely transfers files between local and remote locations using dd over SSH."
        echo "             If source contains ':', it will download from remote to local."
        echo "             If destination contains ':', it will upload from local to remote."
        echo "Example: ez_scp "-p 22 user@hostname" /path/to/local/file :/path/to/remote/file"
        echo "         ez_scp user@hostname :/path/to/remote/file /path/to/local/file"
        return 0
    fi

    local remote_host=$1
    local source=$2
    local destination=$3

    # Handle download from remote to local
    if [[ "$source" == *:* ]]; then
        local remote_path="${source#*:}"
        echo "Starting download from: $remote_host:$remote_path to $destination"
        ssh "$remote_host" "dd if='$remote_path' bs=1M" | dd of="$destination" bs=1M status=progress
    # Handle upload from local to remote
    elif [[ "$destination" == *:* ]]; then
        local remote_path="${destination#*:}"
        echo "Starting upload from: $source to $remote_host:$remote_path"
        dd if="$source" bs=1M status=progress | ssh "$remote_host" "dd of='$remote_path' bs=1M"
    else
        echo "Error: Invalid path format. Please use format: user@hostname :/path/to/file or user@hostname /path/to/local/file :/path/to/remote/file"
        return 1
    fi
}

ez_restart() {
    # restart only if enabled
    service_name="${1}"
    if systemctl list-units --type=service --all | grep -q "$service_name"; then
        if systemctl is-enabled "$service_name" | grep -q "enabled"; then
            echo "Restarting ${service_name} ..."
            # legacy way: sudo service "$service_name" restart
            sudo systemctl restart "$service_name"
        fi
    fi
}

ez_autostart() {
    sudo systemctl enable --now $1
}

ez_start() {
    sudo systemctl start $1
}

ez_stop() {
    sudo systemctl stop $1
}

# ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
# > general
# ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
# ez_write "
# a
# b
# " .demo.txt
ez_write() {
    local content="$1"
    local filepath="${2:-/data/caddy/docker-compose.yml}"
sudo cat <<EOF | sudo tee "$filepath" >/dev/null
$content
EOF
}

ez_append() {
    local content="$1"
    local filepath="${2:-/data/caddy/docker-compose.yml}"
sudo cat <<EOF | sudo tee -a "$filepath" >/dev/null
$content
EOF
}

ez_mkdir() {
    pth="${1}"
    [ ! -d "${pth}" ] && sudo mkdir -p "${pth}"
}

pause() {
    local message="${1:-Press any key to continue...}"
    read -n1 -r -p "$message"
}

confirm() {
    local message=$1
    local quiet=$2
    if [[ "$quiet" == "-q" || "$quiet" == "--quiet" ]]; then
        echo "$message ([y]/n):"  # Optionally display the message
        return 0         # Automatically confirm
    fi
    read -p "$message ([y]/n): " response
    response=${response:-y}
    if [[ $response == [Nn]* ]]; then
        echo "User cancelled."
        return 1
    fi
    [[ $response == [Yy]* ]]
}

function findpath() {
    # returns real path to a folder or file, given a wild card
    # e.g., findpath "$HOME/Library/Application Support/Firefox/Profiles/*release"
    #       findpath "Firefox/WaveFox*.zip"
    local pattern=$1
    # Extract base directory from the pattern
    local base_dir=$(dirname "${pattern}")
    local filename=$(basename "${pattern}")

    # Use find to locate files or directories matching the pattern
    find "${base_dir}" -name "${filename}" -maxdepth 1
}

function pprint {
    # pprint "This text will be green" "green" 
    # pprint "This text will be red" "red"
    # pprint "unknown"  # "This text will be in the default color"

    local text=$1
    local color=$2
    local color_code="\033[32m"  # Default color

    case $color in
        red) color_code="\033[31m";;
        green) color_code="\033[32m";;
        yellow) color_code="\033[33m";;
        blue) color_code="\033[34m";;
        magenta) color_code="\033[35m";;
        cyan) color_code="\033[36m";;
        white) color_code="\033[37m";;
        gray) color_code="\033[90m";;
        grey) color_code="\033[90m";;
        # *) color_code="\033[0m";; # no color
        # No need for a default case as we've already set the default color
    esac

    printf "${color_code}${text}\033[0m\n"
}
