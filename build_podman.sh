set -xe

mkdir -p workdir homedir

podman run \
	--rm -it \
	--security-opt label=disable \
	-v ./workdir:/workdir \
	-w /workdir \
	-v ./homedir:/homedir \
	-e HOME=/homedir \
	-v ./build.sh:/build.sh \
	-e NOSYNC="$NOSYNC" \
	--entrypoint '["/bin/bash", "/build.sh"]' \
	lineageos4microg/docker-lineage-cicd
