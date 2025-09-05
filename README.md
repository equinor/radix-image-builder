[![Build Status](https://github.com/equinor/radix-image-builder/workflows/radix-image-builder-build/badge.svg)](https://github.com/equinor/radix-image-builder/actions?query=workflow%3Aradix-image-builder-build)
# radix-image-builder

The radix-image-builder gives radix-pipeline access to build the images using ACR build functionality.

## Development Process

The `radix-image-builder` project follows a **trunk-based development** approach.

### 🔁 Workflow

- **External contributors** should:
  - Fork the repository
  - Create a feature branch in their fork

- **Maintainers** may create feature branches directly in the main repository.

### ✅ Merging Changes

All changes must be merged into the `master` branch using **pull requests** with **squash commits**.

The squash commit message must follow the [Conventional Commits](https://www.conventionalcommits.org/en/about/) specification.

### Running locally

The following env vars are needed. Useful default values in brackets.

```shell
LOG_PRETTY=True ISSUER=https://issuer-url/ AUDIENCE=some-audience SUBJECTS=default,kubernetes,somename go run .
```

### Validate code

- run `make lint`

## Release Process

Merging a pull request into `mamastern` triggers the **Prepare release pull request** workflow.  
This workflow analyzes the commit messages to determine whether the version number should be bumped — and if so, whether it's a major, minor, or patch change.  

It then creates two pull requests:

- one for the new stable version (e.g. `1.2.3`), and  
- one for a pre-release version where `-rc.[number]` is appended (e.g. `1.2.3-rc.1`).

---

Merging either of these pull requests triggers the **Create releases and tags** workflow.  
This workflow reads the version stored in `version.txt`, creates a GitHub release, and tags it accordingly.

The new tag triggers the **Build and deploy Docker** workflow, which builds and pushes a new container image to `ghcr.io`.

## Contribution

Want to contribute? Read our [contributing guidelines](./CONTRIBUTING.md)

## Security

This is how we handle [security issues](./SECURITY.md)
