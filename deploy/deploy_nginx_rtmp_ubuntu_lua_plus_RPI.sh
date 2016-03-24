#!/bin/sh

ngxver=1.9.9

echo "Installing nginx + nginx-rtmp module..."
sleep 5
echo "update packeges libruary..."
sudo apt-get update
echo "done"
sleep 2
echo "Installing libruary and packages..."
sudo apt-get install -y libxml2-dev libbz2-dev libcurl4-openssl-dev libmcrypt-dev libmhash2 libmhash-dev libpcre3 libpcre3-dev make build-essential libxslt1-dev git unzip libgd2-xpm-dev libgeoip-dev libpam0g-dev  lua5.1 liblua5.1-0 liblua5.1-0-dev
echo "done"
sleep 2

cd /usr/src/
echo "Get google-perftools..."
sudo wget http://http.us.debian.org/debian/pool/main/g/google-perftools/libgoogle-perftools4_2.2.1-0.2_armhf.deb
sudo wget http://http.us.debian.org/debian/pool/main/g/google-perftools/libgoogle-perftools-dev_2.2.1-0.2_armhf.deb
sudo wget http://http.us.debian.org/debian/pool/main/g/google-perftools/libtcmalloc-minimal4_2.2.1-0.2_armhf.deb
#sudo wget 
sudo dpkg -i *.deb
echo "done"
sleep 2

echo "Get lua source..."
sleep 2

sudo git clone http://luajit.org/git/luajit-2.0.git
sudo git clone https://github.com/simpl/ngx_devel_kit.git
sudo git clone https://github.com/openresty/lua-nginx-module.git
echo "done"
sleep 2
#exit 0
echo "Compiling and install lua ..."
sleep 2

cd luajit-2.0
sudo make && sudo make install && cd ..
export LUAJIT_LIB=/usr/local/lib
export LUAJIT_INC=/usr/local/include/luajit-2.0
echo "done"
sleep 2

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
--with-http_secure_link_module --with-http_dav_module \
--with-http_geoip_module --with-http_image_filter_module \
--with-mail --with-mail_ssl_module --with-google_perftools_module \
--with-debug --with-pcre-jit --with-ipv6 --with-http_stub_status_module --with-http_realip_module \
--with-http_addition_module --with-http_gzip_static_module --with-http_sub_module \
--add-module=/usr/src/nginx-rtmp-module \
--add-module=/usr/src/ngx_devel_kit \
--add-module=/usr/src/lua-nginx-module

sudo make -j2
sudo make install

unset LUAJIT_LIB
unset LUAJIT_INC

echo "done"
sleep 2

echo "Get ffmpeg and coping..."
sleep 2

cd ..
#sudo wget http://ffmpeg.gusari.org/static/64bit/ffmpeg.static.64bit.latest.tar.gz
#sudo tar -xzf ffmpeg.static.64bit.latest.tar.gz
#cp ffmpeg /usr/local/bin/ffmpeg
#cp ffprobe /usr/local/bin/ffprobe
echo "done"
sleep 2

echo "Get nginx config and files and coping to it place..."
sleep 2

#sudo wget http://dburianov.pp.ua/wp-content/uploads/2014/04/cfg.zip
#sudo unzip cfg.zip
#sudo cp nginx.conf mime.types /usr/local/nginx/conf/
#sudo cp stat.xsl /usr/local/nginx/html/
#sudo cp nclients.xsl /usr/local/nginx/html/
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
