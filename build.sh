set -xe

git config --global user.email "you@example.com"
git config --global user.name "Your Name"

if ! [ -d src ]
then
	mkdir src
	(
		cd src
		repo init -u https://github.com/droidng/android.git -b ng-v3
		git clone https://github.com/AndyCGYan/lineage_build_unified lineage_build_unified -b lineage-19.1
		git clone https://github.com/AndyCGYan/lineage_patches_unified lineage_patches_unified -b lineage-19.1
		# duplicated gitlab remote
		sed -i 's#<remote name="gitlab" fetch="https://gitlab.com/" />##g' lineage_build_unified/local_manifests_treble/manifest.xml
		# droid-ng has their own gapps repo
		sed -i 's#<project name="davi.sh/gms-android-12" path="vendor/partner_gms" remote="gitlab" revision="master" />##g' lineage_build_unified/local_manifests_treble/manifest.xml
		# un-clonable without access
		sed -i 's#<project name="droid-ng/android_vendor_priv" path="vendor/priv" remote="private" revision="master" groups="notdefault,ng_priv" />##g' .repo/manifests/snippets/ng.xml
		# don't do repopick for droid-ng
		sed -i '/repopick/d' lineage_build_unified/buildbot_unified.sh
		# these patch are already in droid-ng
		rm lineage_patches_unified/patches_treble_phh/platform_frameworks_base/0004-Show-APN-Settings-for-CDMA-carriers.patch
		rm lineage_patches_unified/patches_treble_phh/platform_frameworks_base/0009-HOME-deserves-to-wake-up-devices-just-as-well-as-bac.patch
		rm lineage_patches_unified/patches_treble_phh/platform_frameworks_base/0010-Some-devices-have-proximity-sensor-reporting-NaN-as-.patch
		rm lineage_patches_unified/patches_treble_phh/platform_frameworks_base/0018-Fix-Wakelock-issue.patch
		rm lineage_patches_unified/patches_treble_phh/platform_frameworks_base/0022-Add-support-for-app-signature-spoofing.patch
		rm lineage_patches_unified/patches_treble_phh/platform_system_netd/0001-Support-no-bpf-usecase.patch
		rm lineage_patches_unified/patches_treble_phh/platform_system_bpf/0001-Support-no-bpf-usecase.patch
		rm lineage_patches_unified/patches_treble/system_core/0002-Panic-into-recovery-rather-than-bootloader.patch

		# keep that droid-ng style
		rm -r lineage_patches_unified/patches_platform/*

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
	bash lineage_build_unified/buildbot_unified.sh treble nosync 64VN
fi


#bash -l
#exit 0

