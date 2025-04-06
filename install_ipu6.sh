#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script as root (use sudo)"
   exit 1
fi

echo "Updating system and installing dependencies..."
# Install required dependencies
pacman -Syu --needed base-devel git cmake meson ninja python-pip python-setuptools python-wheel clang llvm

# Install additional dependencies for IPU6
pacman -S --needed linux-headers v4l-utils ffmpeg gstreamer gst-plugins-good gst-plugins-bad gst-plugins-ugly

# Create working directory
mkdir -p /opt/ipu6 && cd /opt/ipu6

echo "Cloning Intel IPU6 driver repositories..."
# Clone required repositories
git clone https://github.com/intel/ipu6-drivers.git
git clone https://github.com/intel/ipu6-camera-bins.git
git clone https://github.com/intel/ipu6-camera-hal.git

echo "Building and installing IPU6 kernel drivers..."
cd ipu6-drivers
make && make install
modprobe intel-ipu6

echo "Installing IPU6 camera HAL..."
cd ../ipu6-camera-hal
mkdir build && cd build
meson ..
ninja
ninja install

echo "Installing IPU6 firmware..."
cd ../../ipu6-camera-bins
cp -r firmware /lib/firmware/intel/ipu6

echo "Loading kernel modules..."
modprobe intel-ipu6
modprobe v4l2loopback

echo "Verifying installation..."
lsmod | grep ipu6
v4l2-ctl --list-devices

echo "Testing camera..."
ffmpeg -f v4l2 -i /dev/video0 -frames:v 1 test.jpg

echo "Installation complete! If your camera is not working, reboot and try again."
