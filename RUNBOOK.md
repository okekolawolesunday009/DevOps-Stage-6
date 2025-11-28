## DevOps-Stage-6 Runbook

Purpose: quick operational guide to deploy, verify, and troubleshoot the DevOps-Stage-6 application stack (Traefik, frontend, auth-api, todos-api, users-api, log processor, Redis).

**Quick Commands**
- **Build & start (local)**: `docker compose build --no-cache && docker compose up -d --remove-orphans`
- **Recreate Traefik & frontend**: `docker compose up -d --force-recreate traefik frontend`
- **View logs**: `docker compose logs -f traefik frontend auth-api todos-api users-api --tail 200`
- **Stop & remove**: `docker compose down --remove-orphans`

**GitHub Actions / CD**
- Workflow: `.github/workflows/deploy.yml` — runs on push to `dev` and can be triggered manually (`workflow_dispatch`).
- Prepare step: creates `deployment.tar.gz` and uploads artifact.
- Deploy step: SCP -> extract -> copy to `/opt/devops-app` on the server, installs docker/docker-compose, then `docker-compose up -d --build`.
- If the prepare step fails with `cp: cannot stat '...'`, ensure files exist or the workflow has been updated to skip missing optional files (we added guards for `traefik`, `nginx`, `docker-compose.yml`, and `.env`).

**Required GitHub Secrets** (set in repo Settings → Secrets → Actions)
- `HOST` — server IP or DNS used by the deploy action
- `USERNAME` — SSH user for the server
- `SSH_PRIVATE_KEY` — private key for SSH (PEM or OpenSSH format)
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` — for infra workflow
- `SMTP_USERNAME`, `SMTP_PASSWORD`, `NOTIFICATION_EMAIL` — for email notifications (Gmail app password recommended)

**Terraform Infra (high-level)**
- Workflow: `.github/workflows/infrastructure.yml` runs plan → manual approval → apply.
- Backend: S3 bucket `devops-stage-6-terraform-state` and DynamoDB `terraform-locks` are created by the workflow if missing. Ensure IAM keys allow S3 & DynamoDB actions.
- Common error: `file()` with `~` — fixed by `pathexpand(var.ec2_key)` in `modules/ec2/main.tf`.

**Traefik checks & troubleshooting**
- Confirm domain DNS: `dig +short www.prod.chickenkiller.com` (should resolve to server public IP).
- Check Traefik routers and services in logs: `docker compose logs traefik --tail 200` and look for lines registering routers for `www.prod.chickenkiller.com`.
- Verify ACME: check `acme.json` exists and is writable by Traefik. On server: `sudo ls -l /var/lib/docker/volumes/traefik_acme/_data` or where `traefik_acme` volume is mounted.
- Traefik dashboard: if exposed, visit `http://<server_ip>:8088` (dashboard port in `docker-compose.yaml`). If using HTTPS, ensure certificates are valid: `openssl s_client -connect www.prod.chickenkiller.com:443 -servername www.prod.chickenkiller.com`.

**Application verification (once deployed)**
- Frontend: `curl -v https://www.prod.chickenkiller.com/` or `http://localhost:8080/` for local tests.
- Login page: `https://www.prod.chickenkiller.com/dashboard/#/login?redirect=%2F` (hash router usually works without special server config).
- API health endpoints (example):
  - `curl -v https://www.prod.chickenkiller.com/api/auth/` 
  - `curl -v https://www.prod.chickenkiller.com/api/todos/`
  - `curl -v https://www.prod.chickenkiller.com/api/users/`

**Server-side cleanup (out of disk / overlayfs errors)**
- Free space quickly: `docker system prune -af --volumes` (destroys unused images, containers, networks, volumes).
- Remove dangling images only: `docker image prune -f`
- Check disk usage: `df -h` and `du -sh /var/lib/docker/*`
- If EBS root is small, prefer expanding disk and resizing filesystem; signal to ops team for permanent fix.

**Building and pushing images to Docker Hub**
- Build image locally:
  ```powershell
  docker build -t <hub-user>/frontend:latest ./frontend
  docker login
  docker push <hub-user>/frontend:latest
  ```
- Then update `docker-compose.yml` to use `image: <hub-user>/frontend:latest` or let the CD build locally (we configured builds by default).

**Rollback / Restore**
- The deployment job creates backups of `/opt/devops-app` under `/opt/backups/devops-app-<timestamp>` before replacing — to rollback, stop containers and restore the desired backup, then `docker compose up -d`.

**Troubleshooting quick list**
- `cp: cannot stat 'X'` in prepare step → file missing; confirm repository roots and that action checked out code; we added guards to skip missing optional files.
- Traefik no router for domain → check container labels in `docker-compose.yaml`, restart Traefik, and inspect logs for registration messages.
- ACME certificate errors → check `acme.json` permissions (600) and Traefik logs for ACME errors; ensure DNS A record points to server.
- Terraform `no file exists at "~/.ssh/id_ed25519.pub"` → use absolute path or let workflow user set `ec2_key` to an accessible path; `pathexpand()` now resolves `~`.
- Build failures due to native modules (node-sass) → ensure frontend Dockerfile uses Node >=16 and installs `python3`, `build-base` (we updated `frontend/Dockerfile`).

If you'd like, I can:
- Add a small `ls -la` debugging line to the deploy job (before copying) to show repo contents during CI runs.
- Create a separate `OPERATION_CHECKLIST.md` with step-by-step one-liners for on-call engineers.

Contact: repo maintainer (see README) for escalation.
