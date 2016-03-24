#!/bin/sh

apt-get install libvo-aacenc-dev libmp3lame-dev libmp3lame-ocaml-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libtheora-ocaml-dev libvorbis-dev libvorbis-ocaml-dev libvorbisidec-dev libvpx-dev

cd /usr/src
sudo git clone git://git.videolan.org/x264
cd x264
sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-opencl
sudo make
sudo make install

cd /usr/src
sudo git clone git://source.ffmpeg.org/ffmpeg.git
cd ffmpeg

sudo ./configure --enable-gpl --enable-libvo-aacenc --enable-libmp3lame --enable-libopencore-amrnb    --enable-libopencore-amrwb --enable-librtmp --enable-libtheora --enable-libvorbis    --enable-libvpx --enable-libx264 --enable-nonfree --enable-version3 --enable-libfreetype

#apt-cache search aac | grep aac | grep dev

sudo make -j8

sudo checkinstall --pkgname=ffmpeg --pkgversion="2.7.$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default
