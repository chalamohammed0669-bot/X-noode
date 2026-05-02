#!/usr/bin/env bash
set -euo pipefail

# install-python.sh
# Simple helper to install Python3, pip and venv on Debian/Ubuntu systems and optionally create a virtual environment.

usage() {
  cat <<EOF
Usage: $0 [--venv <dir>] [--upgrade]

Options:
  --venv <dir>   Create a virtual environment in <dir> after installing packages (default: .venv)
  --upgrade      If --venv is used, upgrade pip, setuptools, and wheel inside the venv
  -h, --help      Show this help message

This script requires sudo privileges and is intended for Debian/Ubuntu systems with apt/apt-get.
EOF
}

# Default values
VENV_DIR=".venv"
DO_VENV=0
DO_UPGRADE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --venv)
      DO_VENV=1
      shift
      if [[ $# -gt 0 && ! "$1" =~ ^- ]]; then
        VENV_DIR="$1"
        shift
      fi
      ;;
    --upgrade)
      DO_UPGRADE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;
  esac
done

# Ensure apt exists
if ! command -v apt-get >/dev/null 2>&1 && ! command -v apt >/dev/null 2>&1; then
  echo "This script supports Debian/Ubuntu systems with apt/apt-get only. Aborting." >&2
  exit 3
fi

echo "Updating package lists..."
sudo apt update

echo "Installing python3, python3-venv and python3-pip (if not already installed)..."
sudo apt install -y python3 python3-venv python3-pip

echo "Installed versions:"
python3 --version || true
pip3 --version || true

if [[ $DO_VENV -eq 1 ]]; then
  echo "Creating virtual environment in '$VENV_DIR'..."
  python3 -m venv "$VENV_DIR"
  echo "Virtual environment created. To activate: source $VENV_DIR/bin/activate"

  if [[ $DO_UPGRADE -eq 1 ]]; then
    echo "Upgrading pip, setuptools and wheel inside the venv..."
    # shellcheck disable=SC1091
    source "$VENV_DIR/bin/activate"
    pip install --upgrade pip setuptools wheel
    deactivate
    echo "Upgraded packaging tools inside venv."
  fi
fi

echo "Done."