# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Inception-of-Things (IoT) — a Kubernetes administration project in three progressive parts. Documentation is in French.

- **p1/**: K3s + Vagrant — 2 VMs (chillionS server + chillionSW agent) on 192.168.56.110-111
- **p2/**: K3s + 3 web apps — 1 VM with Traefik ingress routing (app1.com, app2.com, default→app3)
- **p3/**: K3d + Argo CD — Docker-based GitOps pipeline, no VMs, port 8888

## Common Commands

All orchestration goes through the root Makefile:

```bash
# Part 1: K3s cluster with Vagrant
make p1              # Create and start both VMs
make p1-verify       # Run cluster verification script
make p1-ssh          # SSH into server VM
make p1-down         # Halt VMs (preserves state)
make p1-clean        # Destroy VMs

# Part 2: Web apps
make p2              # Create VM and deploy 3 apps
make p2-test         # curl-based routing test (app1.com, app2.com, default)
make p2-ssh          # SSH into VM
make p2-clean        # Destroy VM

# Part 3: K3d + Argo CD (runs on host, needs Docker)
make p3              # Full pipeline: install → setup → deploy
make p3-install      # Install Docker, K3d, kubectl, Argo CD CLI
make p3-setup        # Create K3d cluster + install Argo CD
make p3-deploy       # Deploy app to dev namespace
make p3-test         # Verify deployment and GitOps sync

# Global
make clean           # Destroy all VMs + K3d clusters + temp files
make fclean          # Force cleanup including docker system prune
make check           # Run compliance verification (Tools/check_requirements.sh)
make check-versions  # Show installed tool versions
make status          # Status of all parts
```

## Architecture

### Per-part structure

Each part (`p1/`, `p2/`, `p3/`) follows the same layout:

- `scripts/` — Bash provisioning and test scripts
- `confs/` — Kubernetes YAML manifests (p2, p3 only)
- `Vagrantfile` — VM definition (p1, p2 only)
- `README.md` — Part-specific documentation

### Key networking

- p1/p2 VMs use VirtualBox private network 192.168.56.0/24
- p2 Traefik ingress routes by Host header: `app1.com`, `app2.com`, unmatched→app3
- p3 K3d cluster maps host ports: 8080→80, 8443→443, 8888→8888
- p3 uses namespaces `argocd` and `dev`

### GitOps flow (Part 3)

Argo CD watches `https://github.com/BekxFR/trobert-iot-argocd-app.git` and auto-syncs changes to the `dev` namespace. The app image is `wil42/playground` (v1/v2).

## Requirements

- **p1/p2**: Vagrant + VirtualBox
- **p3**: Docker (must be accessible without sudo — use `newgrp docker` if needed)
- `Docs/CONSIGNES_POINTS_CLES.md` contains the full evaluation checklist

## Key constraints

- p1 VMs must be named `<login>S` (server) and `<login>SW` (worker) with specific IPs
- p2 app2 must have exactly 3 replicas
- p3 app must be in `dev` namespace, Argo CD in `argocd` namespace
- All K3s scripts configure the `--flannel-iface` to use `enp0s8` (VirtualBox host-only adapter)
