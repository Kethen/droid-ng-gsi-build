set -xe

export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y zstd

git config --global user.email "you@example.com"
git config --global user.name "Your Name"

if ! [ -d src ]
then
	mkdir src
	(
		cd src
		( yes||: ) | repo init -u https://github.com/droid-ng/android -b ng-v4 --git-lfs
		git clone https://github.com/Kethen/lineage_build_unified lineage_build_unified -b ng-v4
		git clone https://github.com/Kethen/lineage_patches_unified lineage_patches_unified -b ng-v4
	)
fi

# provide phh superuser
(
	cd src
	if ! [ -d vendor/foss ]
	then
		mkdir -p vendor
		git clone https://github.com/phhusson/vendor_foss.git vendor/foss
		cd vendor/foss
		apt install -y wget xmlstarlet unzip aapt
		bash update.sh
	fi
)

mkdir -p ccache
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_DIR=$(realpath ccache)
ccache -M 50G
ccache -o compression=true

cd src

TARGETS="64VN 64VS A64VN A64VS"

if [ "$NOSYNC" == "true" ]
then
	echo skipping sync
	bash lineage_build_unified/buildbot_unified.sh treble nosync $TARGETS
else
	bash lineage_build_unified/buildbot_unified.sh treble $TARGETS
fi

#bash -l
#exit 0

