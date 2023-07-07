# frp-dockerfile


### frp

```sh
# github下载
https://github.com/fatedier/frp/releases

# 官方文档
https://gofrp.org/docs/setup/
```

#### **docker**

```dockerfile
docker pull alpine:3.18.2

cat > Dockerfile <<'EOF'
FROM alpine:3.18.2

# 重命名命令在下面有
ADD frp.tar.gz /opt/

# 更新包、+用户
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
    apk update && apk upgrade && \
    mv /opt/frp* /opt/frp && \
    addgroup -g 101 -S frp && \
    adduser -S -D -H -u 101 -h /opt/frp -s /sbin/nologin -G frp -g frp frp && \ 
    chown -R frp.frp /opt/frp
EOF
```

```sh
# 重命名下载好的frp安装包
mv frp*.tar.gz frp.tar.gz

# 环境变量，frps或者frpc
S_OR_C=frps

# 构建镜像
docker build . -t frp:latest

# 启动
docker run -itd --restart=always --name frp \
  --network host \
  -v ./$S_OR_C.ini:/opt/frp/$S_OR_C.ini \
  frp \
  /opt/frp/$S_OR_C -c /opt/frp/$S_OR_C.ini

# 进容器
docker exec -it frp sh
```

#### k8s

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frp
  namespace: default
  labels:
    app: frp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frp
  strategy:
    rollingUpdate: 
      maxSurge: 1
      maxUnavailable: 1
  template:
    metadata:
      labels:
        app: frp
    spec:
      hostNetwork: True
      dnsPolicy: ClusterFirstWithHostNet
      restartPolicy: "Always"
      containers:
      - name: "frp"
        image: "frp:latest"
        imagePullPolicy: "Never"
        command: ["/opt/frp/frps","-c","/opt/frp/frps.ini"]
EOF
```
