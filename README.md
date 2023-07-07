# frp-dockerfile


```dockerfile
docker pull alpine:3.18.2

cat > Dockerfile <<'EOF'
FROM alpine:3.18.2
# frp文件
ADD frp.tar.gz /opt/

# 时区 + 更新
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk update && apk upgrade && \
    mv /opt/frp* /opt/frp && \
    addgroup -g 101 -S frp && \
    adduser -S -D -H -u 101 -h /opt/frp -s /sbin/nologin -G frp -g frp frp && \ 
    chown -R frp.frp /opt/frp
    

# 时区、字符集---环境变量
ENV LANG=en_US.UTF-8
ENV TZ=Asia/Shanghai
EOF
```

```sh
mv frp*.tar.gz frp.tar.gz
S_OR_C=frps

docker build . -t frp:latest

docker run -itd --restart=always --name frp \
  --network host \
  -v ./$S_OR_C.ini:/opt/frp/$S_OR_C.ini \
  frp \
  /opt/frp/$S_OR_C -c /opt/frp/$S_OR_C.ini


docker exec -it frp sh
```
