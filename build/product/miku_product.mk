#
# Copyright (C) 2018 The Android Open Source Project
# Copyright (C) 2021-2022 Miku UI
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This makefile is the basis of a generic system image for a handheld device.
$(call inherit-product, $(SRC_TARGET_DIR)/product/handheld_system.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/telephony_system.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_default.mk)

# Inherit from our versioning
$(call inherit-product, vendor/miku/config/versioning.mk)

# Inherit from our overlay
$(call inherit-product, vendor/miku/config/overlay.mk)

# Applications
PRODUCT_PACKAGES += \
    Gboard \
    Jelly \
    LiveWallpapersPicker \
    messaging \
    PartnerBookmarksProvider \
    QuickAccessWallet \
    Stk \
    Tag \
    TimeZoneUpdater \
    ThemePicker 

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/miku/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/miku/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/miku/prebuilt/common/bin/50-miku.sh:system/addon.d/50-miku.sh

# Blur
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.launcher.blur.appLaunch=false

# Bootanimation
PRODUCT_PACKAGES += \
    bootanimation.zip

# OTA support
PRODUCT_PACKAGES += \
    recovery-refresh \
    update_engine \
    update_verifier

# Ringtone
PRODUCT_COPY_FILES += \
    vendor/miku/ringtone/miku_secret.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/miku_secret.ogg \
    vendor/miku/ringtone/miku_noti_msg.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/miku_noti_msg.ogg

PRODUCT_PRODUCT_PROPERTIES += \
    ro.config.ringtone=miku_secret.ogg \
    ro.config.notification_sound=miku_noti_msg.ogg

# World APN list
PRODUCT_PACKAGES += \
    apns-conf.xml

# Wrapped net utils for /vendor access.
PRODUCT_PACKAGES += netutils-wrapper-1.0

# Charger images
PRODUCT_PACKAGES += charger_res_images

# system_other support
PRODUCT_PACKAGES += \
    cppreopts.sh \
    otapreopt_script

# Bluetooth libraries
PRODUCT_PACKAGES += \
    audio.a2dp.default \
    audio.hearing_aid.default

# For ringtones that rely on forward lock encryption
PRODUCT_PACKAGES += libfwdlockengine

# ThemeOverlays
include packages/overlays/Themes/themes.mk

# System libraries commonly depended on by things on the system_ext or product partitions.
# These lists will be pruned periodically.
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint@2.1 \
    android.hardware.radio@1.0 \
    android.hardware.radio@1.1 \
    android.hardware.radio@1.2 \
    android.hardware.radio@1.3 \
    android.hardware.radio@1.4 \
    android.hardware.radio.config@1.0 \
    android.hardware.radio.deprecated@1.0 \
    android.hardware.secure_element@1.0 \
    android.hardware.wifi@1.0 \
    libaudio-resampler \
    libaudiohal \
    libdrm \
    liblogwrap \
    liblz4 \
    libminui \
    libnl \
    libprotobuf-cpp-full

# These libraries are empty and have been combined into libhidlbase, but are still depended
# on by things off /system.
# TODO(b/135686713): remove these
PRODUCT_PACKAGES += \
    libhidltransport \
    libhwbinder

# Enable configurable audio policy
PRODUCT_PACKAGES += \
    libaudiopolicyengineconfigurable \
    libpolicy-subsystem

# Enable support of one-handed mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode=true

# Include all zygote init scripts. "ro.zygote" will select one of them.
PRODUCT_COPY_FILES += \
    system/core/rootdir/init.zygote32.rc:system/etc/init/hw/init.zygote32.rc \
    system/core/rootdir/init.zygote64.rc:system/etc/init/hw/init.zygote64.rc \
    system/core/rootdir/init.zygote64_32.rc:system/etc/init/hw/init.zygote64_32.rc

# Put en_US first in the list, so make it default.
PRODUCT_LOCALES := zh_CN

# Disable extra StrictMode features on all non-engineering builds
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.strictmode.disable=true

# Flatten APEXs for performance
OVERRIDE_TARGET_FLATTEN_APEX := true
# This needs to be specified explicitly to override ro.apex.updatable=true from
# prebuilt vendors, as init reads /product/build.prop after /vendor/build.prop
PRODUCT_PRODUCT_PROPERTIES += ro.apex.updatable=false
