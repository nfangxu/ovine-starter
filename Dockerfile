FROM centos:7

RUN rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm \
    && yum update -y \
    && yum install yum-utils  epel-release install nginx wget -y \
    && rm -f /usr/share/nginx/html/index.html \
    && yum clean all

RUN wget https://nodejs.org/dist/v14.17.6/node-v14.17.6-linux-x64.tar.xz \
    && tar -xf node-v14.17.6-linux-x64.tar.xz \
    && rm -rf node-v14.17.6-linux-x64.tar.xz \
    && mv node-v14.17.6-linux-x64 node \
    && ln -s /node/bin/node   /usr/local/bin/ \
    && ln -s /node/bin/npm    /usr/local/bin/ \
    && ln -s /node/bin/node   /usr/bin/

RUN npm install -g yarn \
    && ln -s /node/bin/yarn /usr/bin/  \
    && yarn config set registry https://registry.npm.taobao.org/ -g

COPY nginx.conf /etc/nginx/conf.d/default.conf

WORKDIR /tmp/html/

COPY . .

ARG BUILD_ENV=dev

RUN yarn install \
    && yarn ovine build --env=${BUILD_ENV} \
    && cp -a /tmp/html/dist/* /usr/share/nginx/html/ \
    && yarn cache clean \
    && rm -rf /tmp/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
