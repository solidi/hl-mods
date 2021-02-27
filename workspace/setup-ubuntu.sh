# Ubuntu 20.04+
sudo su -
apt update
apt install build-essential
adduser your-user vboxsf
apt-get install g++-multilib

# https://askubuntu.com/questions/1235819/ubuntu-20-04-gcc-version-lower-than-gcc-7

echo "deb http://dk.archive.ubuntu.com/ubuntu/ xenial main" >> /etc/apt/sources.list
echo "deb http://dk.archive.ubuntu.com/ubuntu/ xenial universe" >> /etc/apt/sources.list
apt update
apt install g++-4.8 gcc-4.8
# https://stackoverflow.com/questions/4643197/missing-include-bits-cconfig-h-when-cross-compiling-64-bit-program-on-32-bit
apt-get install gcc-4.8-multilib g++-4.8-multilib
