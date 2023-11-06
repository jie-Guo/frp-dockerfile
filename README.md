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
docker pull alpine:3.18

cat > Dockerfile <<'EOF'
FROM alpine:3.18

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
FRP_IMG_NAME=frp:latest
docker build . -t $FRP_IMG_NAME

# 启动
docker run -itd --restart=always --name $S_OR_C \
  --network host \
  -v ./$S_OR_C.ini:/opt/frp/$S_OR_C.ini \
  $FRP_IMG_NAME \
  /opt/frp/$S_OR_C -c /opt/frp/$S_OR_C.ini

# 进容器
docker exec -it frp sh
```


#### k8s

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: frp-config
  namespace: default
data:
  frps.ini: |   # 服务端配置文件，改成自己的
     [common]
     bind_port = 7000
  frpc.ini: |   # 客户端配置文件，改成自己的
    [common]
    server_addr = xxx.xxx.xxx.xxx
    server_port = 7000
EOF
```

```yaml
# 更新
 k set image deploy/frps frps=docker.io/dovej/frp-dockerfile

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frps
  namespace: default
  labels:
    app: frps
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frps
  strategy:
    rollingUpdate: 
      maxSurge: 1
      maxUnavailable: 1
  template:
    metadata:
      labels:
        app: frps
    spec:
      hostNetwork: True
      dnsPolicy: ClusterFirstWithHostNet
      restartPolicy: "Always"
      containers:
      - name: "frps"
        image: "dovej/frp-dockerfile:latest"
        imagePullPolicy: "Always"
        command: ["/opt/frp/frps","-c","/opt/frp/frps.ini"]
        volumeMounts:
          - name: frps
            mountPath: /opt/frp/frps.ini
            subPath: frps.ini
      volumes:
        - name: frps
          configMap:
            name: frp-config
            items:
              - key: frps.ini
                path: frps.ini
EOF
```
