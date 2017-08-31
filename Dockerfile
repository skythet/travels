FROM debian:8

RUN apt-get update && apt-get -y install apt-transport-https curl luarocks luajit git build-essential libssl-dev
RUN curl http://download.tarantool.org/tarantool/1.7/gpgkey | apt-key add -
RUN echo "deb http://download.tarantool.org/tarantool/1.7/debian/ jessie main" >> /etc/apt/sources.list
RUN apt-get update && apt-get -y install tarantool
RUN luarocks install turbo

RUN cd /tmp && \
    git clone https://github.com/mpx/lua-cjson.git && \
    cd lua-cjson && \
    luarocks make && \
    rm -r /tmp/*

RUN mkdir -p /opt/tarantool/data
ADD . /opt/tarantool
WORKDIR /opt/tarantool

EXPOSE 80 3301

CMD ["/opt/tarantool/init.sh"]
