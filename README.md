# Reticulum GHCR image

This repository builds and publishes a Docker image containing the Reticulum `rns` package.

What it does

- Uses the Reticulum source at a given git ref (release tag) and installs the `rns` package.
- A GitHub Actions workflow (on schedule or manual dispatch) fetches the latest release from `markqvist/Reticulum`, builds the image and pushes it to GitHub Container Registry (GHCR) as `ghcr.io/<owner>/reticulum:<tag>` and `:latest`.

Files of interest

- Dockerfile — builds the image and installs `rns` from a git ref.
- .github/workflows/build-on-upstream-release.yml — workflow that polls the upstream repo and builds the image.

Usage

1. Ensure Actions can publish packages for your repository (in repo settings allow GitHub Actions to create and write packages).
2. The workflow uses the built-in `GITHUB_TOKEN` — no additional secrets required for GHCR if running in the same repository owner account.
3. To trigger a build immediately: from the Actions tab run the workflow manually (workflow_dispatch).

Notes and next steps

- The workflow currently runs daily and on manual dispatch. If you want immediate builds on upstream releases, you can replace the polling with a webhook or an upstream workflow that sends a `repository_dispatch` to this repo.
- The Dockerfile installs system build deps and the `rns` package from the Reticulum repo. The image entrypoint is `rnsd` (default CMD `--help`). Override at container runtime as needed.
