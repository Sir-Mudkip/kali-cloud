export image_name := env("IMAGE_NAME", "kali-cloud")
export default_tag := env("DEFAULT_TAG", "latest")
export chunkah_version := env("CHUNKAH_VERSION", "v0.6.0")

[private]
default:
    @just --list

# Build the image using the specified parameters
build $target_image=image_name $tag=default_tag:
    #!/usr/bin/env bash

    BUILD_ARGS=()
    if [[ -z "$(git status -s)" ]]; then
        BUILD_ARGS+=("--build-arg" "SHA_HEAD_SHORT=$(git rev-parse --short HEAD)")
    fi

    podman build \
        "${BUILD_ARGS[@]}" \
        --pull=newer \
        --tag "${target_image}:${tag}" \
        .


# Rechunk an already-built image (run `just build` first) so you can inspect the CI's rechunking step locally
chunk $target_image=image_name $tag=default_tag:
    #!/usr/bin/env bash
    set -eoux pipefail

    IMG="${target_image}:${tag}"
    CHUNKED_IMG="${target_image}:${tag}-chunked"
    OUT=$(mktemp -d)
    trap 'rm -rf "$OUT"' EXIT

    CHUNKAH_CONFIG_STR=$(podman inspect "$IMG" | jq '.[0].Config')
    export CHUNKAH_CONFIG_STR
    podman run --rm \
        --mount=type=image,src="$IMG",dst=/chunkah \
        -v "$OUT":/out:z \
        -e CHUNKAH_CONFIG_STR "quay.io/coreos/chunkah:${chunkah_version}" build \
            --compressed --output oci:/out/image

    skopeo copy "oci:$OUT/image" "containers-storage:$CHUNKED_IMG"

    echo "--- ${IMG} ---"
    podman inspect "$IMG" --format '{{{{len .RootFS.Layers}} layers'
    echo "--- ${CHUNKED_IMG} ---"
    podman inspect "$CHUNKED_IMG" --format '{{{{len .RootFS.Layers}} layers'

# Runs shell check on all Bash scripts
lint:
    #!/usr/bin/env bash
    set -eoux pipefail
    # Check if shellcheck is installed
    if ! command -v shellcheck &> /dev/null; then
        echo "shellcheck could not be found. Please install it."
        exit 1
    fi
    # Run shellcheck on all Bash scripts
    /usr/bin/find . -iname "*.sh" -type f -exec shellcheck "{}" ';'

# Runs shfmt on all Bash scripts
format:
    #!/usr/bin/env bash
    set -eoux pipefail
    # Check if shfmt is installed
    if ! command -v shfmt &> /dev/null; then
        echo "shellcheck could not be found. Please install it."
        exit 1
    fi
    # Run shfmt on all Bash scripts
    /usr/bin/find . -iname "*.sh" -type f -exec shfmt --write "{}" ';'

