FROM alpine:3.18

# 更新、下载、解压、+用户、授权 
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
    apk update && apk upgrade && \
    wget -O frp.tar.gz https://github.com/fatedier/frp/releases/download/v0.58.0/frp_0.58.0_linux_amd64.tar.gz && \
    tar zxvf frp.tar.gz -C /opt && rm -f frp.tar.gz && \
    mv /opt/frp* /opt/frp && \
    addgroup -g 101 -S frp && \
    adduser -S -D -H -u 101 -h /opt/frp -s /sbin/nologin -G frp -g frp frp && \ 
    chown -R frp.frp /opt/frp
