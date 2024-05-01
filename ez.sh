
# ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
# > self maintenance
# ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
ez_updateself() {
    # update this script by downloading from github and saving it to ~/.ez.sh
    curl -O https://raw.githubusercontent.com/superkeyor/ez.sh/main/ez.sh && mv ez.sh ~/.ez.sh
}

ez_reload() {
    # reload this script
    [ ! -f ~/.ez.sh ] && ez_updateself
    source ~/.ez.sh
}

# ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
# > git and github
# ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
ez_gitinit() {
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

ez_gitcommit() {
    # commit with message (default: "update")
    local message=${1:-"update"}
    git add .
    git commit -m "$message"
}

ez_gitpush() {
    git branch -M main
    git push -u origin main
}

ez_gitpull() {
    # pull from github
    git pull origin main
}



