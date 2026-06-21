# dockerfiles

Dockerfiles and build scripts for the `dzangolab` Docker Hub organization.

Each subdirectory is a separate image, with its own `Dockerfile` and `README.md`. The `README.md` doubles as the image's Docker Hub description.

## Contributing

### Building and pushing an image

```bash
./build.sh <image> <tag>
```

where `<image>` must the name of the image's folder.

This builds a multi-arch (`linux/amd64,linux/arm64`) image and pushes it to `dzangolab/<image>:<tag>`. For images that build the two architectures from separate Dockerfiles and join them with a manifest, use:

```bash
./build-manifest.sh <image> <tag>
```

Both scripts automatically sync the image's Docker Hub description (see below) from `<image>/README.md` after pushing.

### Updating the Docker Hub description without rebuilding

If you only changed an image's `README.md` and want to refresh its Docker Hub description without doing a full build/push, run:

```bash
./update-dockerhub-description.sh <image>
```

This pushes `<image>/README.md` as the `full_description` for `dzangolab/<image>` on Docker Hub.

### Credentials

The script needs `DOCKERHUB_USERNAME` (your personal Docker Hub username — not your email, and not the `dzangolab` org name) and `DOCKERHUB_TOKEN` (a Docker Hub access token, not your password) set in the environment. These are stored in `.env` at the repo root and loaded automatically via `direnv` — run `direnv allow` once after cloning.

## CI

Each image has its own independent versioning, so a build is never triggered by a plain commit to `main` — only by pushing a tag.

### Tagging convention

Tags are namespaced per image: `<image>/<semver>`, e.g. `mysql-backup-s3/1.2.0`. The image name is the name of the directory at the repo root; the version is that image's own version, independent of every other image's.

```bash
git tag mysql-backup-s3/1.2.0
git push origin mysql-backup-s3/1.2.0
```

Pushing this tag triggers [.github/workflows/build.yml](.github/workflows/build.yml), which parses the tag, builds only that image (via `build-manifest.sh` if `<image>/Dockerfile.amd64` exists, otherwise `build.sh`), and pushes `dzangolab/<image>:1.2.0` plus its Docker Hub description.

The workflow needs `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` configured as repository secrets (Settings → Secrets and variables → Actions).
