#!/usr/bin/env bash
# Fetch iso if it doesn't already exist
#wget iso
ISO_FILE=x

# Extract iso files
udevil mount "/opt/build/source/${ISO_FILE}"
cp -rT "/media/${ISO_FILE}/" isofiles/

# Insert install config
chmod +w -R isofiles/install.386/
gunzip isofiles/install.386/initrd.gz
echo preseed.cfg | cpio -H newc -o -A -F isofiles/install.386/initrd
gzip isofiles/install.386/initrd
chmod -w -R isofiles/install.386/

# Regenerate MD5 Checksum
cd isofiles
chmod +w md5sum.txt
find -follow -type f ! -name md5sum.txt -print0 | xargs -0 md5sum > md5sum.txt
chmod -w md5sum.txt
cd ..

# Build the new ISO
genisoimage -r -J -b isolinux/isolinux.bin -c isolinux/boot.cat
            -no-emul-boot -boot-load-size 4 -boot-info-table
            -o preseed-debian-10.2.0-i386-netinst.iso isofiles

# Test the new ISO
qemu-system-i386 -net user -cdrom test.iso

# Make the ISO bootable
isohybrid preseed-debian-10.2.0-i386-netinst.iso

# Cleanup
chmod +w -R isofiles
rm -r isofiles
udevil unmount /media/debian-10.2.0-i386-netinst.iso