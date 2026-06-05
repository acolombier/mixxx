#!/bin/bash
set -exo pipefail

modprobe libcomposite
modprobe dummy_hcd
modprobe usb_f_hid

# Using ConfigFS:
mount -t configfs none /sys/kernel/config

cd /sys/kernel/config/usb_gadget
mkdir myhid
cd myhid

echo 0xDEAD > idVendor
echo 0xBEAF > idProduct

mkdir strings/0x409
echo "0123456789" > strings/0x409/serialnumber
echo "TestVendor" > strings/0x409/manufacturer
echo "UHID Device" > strings/0x409/product

# Create configuration:

mkdir configs/c.1
mkdir configs/c.1/strings/0x409
echo "Config 1" > configs/c.1/strings/0x409/configuration

#Create HID function:

mkdir functions/hid.usb0

echo 1 > functions/hid.usb0/protocol
echo 0 > functions/hid.usb0/subclass
echo 32 > functions/hid.usb0/report_length

cat /sys/class/hidraw/hidraw9/device/report_descriptor  > functions/hid.usb0/report_desc


# Link it:

ln -s functions/hid.usb0 configs/c.1/

# Enable gadget:

ls /sys/class/udc

# Choose the dummy controller:

echo dummy_udc.0 > UDC
# 3. Find the resulting USB device

# The gadget should now appear on the host as a USB device.
lsusb
# sudo chown antoine:antoine /dev/bus/usb/005/003


socat -u FILE:/dev/hidraw9,raw,readbytes=32 FILE:/dev/hidg0,raw



## CLEANUP

# echo "" > /sys/kernel/config/usb_gadget/myhid/UDC 2>/dev/null

# rm -f /sys/kernel/config/usb_gadget/myhid/configs/c.1/hid.usb0

# rmdir /sys/kernel/config/usb_gadget/myhid/functions/hid.usb0 2>/dev/null
# rmdir /sys/kernel/config/usb_gadget/myhid/configs/c.1/strings/0x409 2>/dev/null
# rmdir /sys/kernel/config/usb_gadget/myhid/configs/c.1 2>/dev/null
# rmdir /sys/kernel/config/usb_gadget/myhid/strings/0x409 2>/dev/null
# rmdir /sys/kernel/config/usb_gadget/myhid 2>/dev/null
