#!/bin/sh

ngxver=1.9.9

echo "Installing nginx + nginx-rtmp module..."
sleep 5
echo "update packeges libruary..."
sudo yum update
echo "done"
sleep 2
echo "Installing libruary and packages..."
yum groupinstall 'Development Tools'
yum install gcc git prce-devel openssl-devel libxslt-devel libxml2-devel gcc-c++ pcre-devel zlib-devel make wget openssl-devel libxml2-devel libxslt-devel gd-devel perl-ExtUtils-Embed GeoIP-devel gperftools-devel gcc gcc-c++ kernel-devel GeoIP-devel

echo "done"
sleep 2

cd /usr/src/

echo "Get module source..."
sleep 2

sudo git clone https://github.com/arut/nginx-rtmp-module.git
echo "done"
sleep 2

echo "Get nginx source..."
sleep 2

sudo wget http://nginx.org/download/nginx-${ngxver}.tar.gz
echo "done"
sleep 2

echo "Untar nginx source..."
sleep 2

sudo tar -xzf nginx-${ngxver}.tar.gz
cd nginx-${ngxver}

echo "done"
sleep 2

echo "Compiling nginx source..."
sleep 2

sudo ./configure --with-http_xslt_module --with-http_ssl_module --with-http_mp4_module --with-http_flv_module \
--with-http_secure_link_module --with-http_spdy_module --with-http_dav_module \
--with-http_image_filter_module \
--with-mail --with-mail_ssl_module \
--with-debug --with-pcre-jit --with-ipv6 --with-http_stub_status_module --with-http_realip_module \
--with-http_addition_module --with-http_gzip_static_module --with-http_sub_module \
--add-module=/usr/src/nginx-rtmp-module /

sudo make
sudo make install
echo "done"
sleep 2

echo "Get ffmpeg and coping..."
sleep 2

cd ..
sudo wget http://ffmpeg.gusari.org/static/64bit/ffmpeg.static.64bit.latest.tar.gz
sudo tar -xzf ffmpeg.static.64bit.latest.tar.gz
sudo cp ffmpeg /usr/local/bin/ffmpeg
sudo cp ffprobe /usr/local/bin/ffprobe
echo "done"
sleep 2

echo "Get nginx config and files and coping to it place..."
sleep 2

sudo wget http://dburianov.pp.ua/wp-content/uploads/2014/04/cfg.zip
sudo unzip cfg.zip
sudo cp nginx.conf mime.types /usr/local/nginx/conf/
sudo cp stat.xsl /usr/local/nginx/html/
sudo cp nclients.xsl /usr/local/nginx/html/
echo "done"
sleep 2

echo "Edit nginx config..."
sleep 2
sudo nano /usr/local/nginx/conf/nginx.conf
echo "done"
sleep 2

echo "Start nginx ..."
sleep 2

sudo /usr/local/nginx/sbin/nginx
echo "done"
sleep 2

