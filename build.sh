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
		repo init -u https://github.com/droidng/android.git -b ng-v3
		git clone https://github.com/Kethen/lineage_build_unified lineage_build_unified -b ng-v3
		git clone https://github.com/Kethen/lineage_patches_unified lineage_patches_unified -b ng-v3
		# un-clonable without access
		sed -i 's#<project name="droid-ng/android_vendor_priv" path="vendor/priv" remote="private" revision="master" groups="notdefault,ng_priv" />##g' .repo/manifests/snippets/ng.xml
	)
fi

mkdir -p ccache
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_DIR=$(realpath ccache)
ccache -M 50G
ccache -o compression=true

cd src

#if ! [ -e synchronized ]
if true
then
	bash lineage_build_unified/buildbot_unified.sh treble 64VN
	touch synchronized
else
	bash lineage_build_unified/buildbot_unified.sh treble nosync A64VN A64VS 64VN 64VS
fi

#bash -l
#exit 0

