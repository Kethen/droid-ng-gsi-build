set -xe

mkdir -p workdir

podman run \
	--rm -it \
	--security-opt label=disable \
	-v ./workdir:/workdir \
	-w /workdir \
	-v ./build.sh:/build.sh \
	--entrypoint '["/bin/bash", "/build.sh"]' \
	lineageos4microg/docker-lineage-cicd
