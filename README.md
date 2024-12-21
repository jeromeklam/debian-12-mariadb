# debian-12-mariadb10

```
docker build -t="freeasso/debian-12-mariadb10" .
```

```
docker run -d -v ./data:/data -p 127.0.0.1:8506:3306 --name="debian-12-mariadb10" freeasso/debian-12-mariadb10
docker run -it -p 127.0.0.1:8506:3306 --name="debian-12-mariadb10" freeasso/debian-12-mariadb10 /bin/bash
```