#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script as root (use sudo)"
   exit 1
fi

echo "Updating system and installing dependencies..."
# Install dependencies
pacman -Syu --needed base-devel git cmake meson ninja python-pip python-setuptools python-wheel clang llvm

# Install additional dependencies for IPU6
pacman -S --needed linux-headers v4l-utils ffmpeg gstreamer gst-plugins-good gst-plugins-bad gst-plugins-ugly

# Create working directory
mkdir -p /opt/ipu6 && cd /opt/ipu6

echo "Cloning Intel IPU6 driver repositories..."
git clone https://github.com/intel/ipu6-drivers.git
git clone https://github.com/intel/ipu6-camera-bins.git
git clone https://github.com/intel/ipu6-camera-hal.git

echo "Building and installing IPU6 kernel drivers..."
cd ipu6-drivers
make clean && make && make install
modprobe intel-ipu6

echo "Installing IPU6 camera HAL..."
cd ../ipu6-camera-hal
mkdir -p build && cd build
meson ..
ninja
ninja install

echo "Installing IPU6 firmware..."
cd ../../ipu6-camera-bins
mkdir -p /lib/firmware/intel/ipu6
cp -r firmware/* /lib/firmware/intel/ipu6

echo "Loading kernel modules..."
modprobe intel-ipu6
modprobe v4l2loopback

echo "Verifying installation..."
lsmod | grep ipu6
dmesg | grep -i ipu6

echo "Detecting camera device..."
VIDEO_DEVICE=$(v4l2-ctl --list-devices | grep -A 1 "Intel" | tail -n 1 | awk '{print $1}')
if [[ -z "$VIDEO_DEVICE" ]]; then
    echo "ERROR: No Intel IPU6 camera detected!"
    exit 1
fi
echo "Camera found at $VIDEO_DEVICE"

echo "Testing camera with GStreamer..."
gst-launch-1.0 v4l2src device=$VIDEO_DEVICE ! videoconvert ! autovideosink

echo "Installation complete! If your camera is not working, reboot and try again."
