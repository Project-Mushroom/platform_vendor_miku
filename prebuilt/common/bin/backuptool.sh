#!/sbin/sh
#
# Backup and restore addon /system files
#

export C=/tmp/backupdir
export S=/system
export V=SNOW

export ADDOND_VERSION=1

# Scripts in /system/addon.d expect to find backuptool.functions in /tmp
cp -f /tmp/install/bin/backuptool.functions /tmp

# Preserve /system/addon.d in /tmp/addon.d
preserve_addon_d() {
  if [ -d /system/addon.d/ ]; then
    mkdir -p /tmp/addon.d/
    cp -a /system/addon.d/* /tmp/addon.d/

    # Discard any scripts that aren't at least our version level
    for f in /postinstall/tmp/addon.d/*sh; do
      SCRIPT_VERSION=$(grep "^# ADDOND_VERSION=" $f | cut -d= -f2)
      if [ -z "$SCRIPT_VERSION" ]; then
        SCRIPT_VERSION=1
      fi
      if [ $SCRIPT_VERSION -lt $ADDOND_VERSION ]; then
        rm $f
      fi
    done

    chmod 755 /tmp/addon.d/*.sh
  fi
}

# Restore /system/addon.d from /tmp/addon.d
restore_addon_d() {
  if [ -d /tmp/addon.d/ ]; then
    mkdir -p /system/addon.d/
    cp -a /tmp/addon.d/* /system/addon.d/
    rm -rf /tmp/addon.d/
  fi
}

# Proceed only if /system is the expected major version
check_prereq() {
# If there is no build.prop file the partition is probably empty.
if [ ! -r /system/build.prop ]; then
    exit 127
fi
if ! grep -q "^ro.system.miku.version=$V.*" /system/build.prop; then
  echo "Not backing up files from incompatible version."
  exit 127
fi
}

# Execute /system/addon.d/*.sh scripts with $1 parameter
run_stage() {
if [ -d /tmp/addon.d/ ]; then
  for script in $(find /tmp/addon.d/ -name '*.sh' |sort -n); do
    $script $1
  done
fi
}

case "$1" in
  backup)
    mkdir -p $C
    check_prereq
    preserve_addon_d
    run_stage pre-backup
    run_stage backup
    run_stage post-backup
  ;;
  restore)
    check_prereq
    run_stage pre-restore
    run_stage restore
    run_stage post-restore
    restore_addon_d
    rm -rf $C
    sync
  ;;
  *)
    echo "Usage: $0 {backup|restore}"
    exit 
esac

exit 0
