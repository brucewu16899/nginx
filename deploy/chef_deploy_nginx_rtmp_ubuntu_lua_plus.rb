#"Installing nginx + nginx-rtmp module..."

nginxver = "1.7.9"

# install system

%w{libxml2-dev libbz2-dev libcurl4-openssl-dev libmcrypt-dev libmhash2 libmhash-dev libpcre3 libpcre3-dev make build-essential libxslt1-dev git unzip libgd2-xpm-dev libgeoip-dev libpam-dev libgoogle-perftools-dev lua5.1 liblua5.1-0 liblua5.1-0-dev checkinstall}.each do |packages|
    package packages do
    action :install
    end
end

# "Get lua source..."

git '/usr/src/luajit-2.0' do
  repository 'http://luajit.org/git/luajit-2.0.git'
  revision "master"
  action :sync
end

git '/usr/src/ngx_devel_kit' do
  repository 'https://github.com/simpl/ngx_devel_kit.git'
  revision "master"
  action :sync
end

git '/usr/src/lua-nginx-module' do
  repository 'https://github.com/openresty/lua-nginx-module.git'
  revision "master"
  action :sync
end

# "Compiling and install lua ..."
bash "Compiling_luajit" do
  cwd "/usr/src/luajit-2.0"
  code <<-EOH
    make
    make install
  EOH
end

# "Get module source..."
git '/usr/src/nginx-rtmp-module' do
  repository 'https://github.com/arut/nginx-rtmp-module.git'
  revision "master"
  action :sync
end

# "Get nginx source and compile and install"
bash "get_nginx" do
  cwd "/usr/src"
  code <<-EOH
    wget http://nginx.org/download/nginx-#{nginxver}.tar.gz
    tar -xzf nginx-#{nginxver}.tar.gz
  EOH
end

bash "install_nginx" do
  cwd "/usr/src/nginx-#{nginxver}"
  code <<-EOH
    export LUAJIT_LIB=/usr/local/lib
    export LUAJIT_INC=/usr/local/include/luajit-2.0
    ./configure --with-http_xslt_module --with-http_ssl_module --with-http_mp4_module --with-http_flv_module \
        --with-http_secure_link_module --with-http_spdy_module --with-http_dav_module --with-http_geoip_module \
        --with-http_image_filter_module --with-mail --with-mail_ssl_module --with-google_perftools_module --with-debug \
        --with-pcre-jit --with-ipv6 --with-http_stub_status_module --with-http_realip_module --with-http_addition_module \
        --with-http_gzip_static_module --with-http_sub_module --add-module=/usr/src/nginx-rtmp-module \
        --add-module=/usr/src/ngx_devel_kit --add-module=/usr/src/lua-nginx-module

    make -j2
    make install
	ldconfig
    unset LUAJIT_LIB
    unset LUAJIT_INC
  EOH
end

# "Get ffmpeg and coping..."

bash "get_ffmpeg_config" do
  cwd "/usr/src"
  code <<-EOH
	wget http://ffmpeg.gusari.org/static/64bit/ffmpeg.static.64bit.latest.tar.gz
	tar -xzf ffmpeg.static.64bit.latest.tar.gz
	cp ffmpeg /usr/local/bin/ffmpeg
	cp ffprobe /usr/local/bin/ffprobe
	wget http://dburianov.pp.ua/wp-content/uploads/2014/04/cfg.zip
	unzip cfg.zip
	cp nginx.conf mime.types /usr/local/nginx/conf/
	cp stat.xsl /usr/local/nginx/html/
	cp nclients.xsl /usr/local/nginx/html/

  EOH
end

# "Start nginx ..."
#  	export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
bash "start_nginx" do
  cwd "/usr/src"
  code <<-EOH

	/usr/local/nginx/sbin/nginx
  EOH
end

