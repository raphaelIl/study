## 요구사항

1. 위에서 작성한 아키텍쳐를 Docker 기반으로 운영하려고 한다.
2. 홈페이지의 소스는 php로 작성되어 있으며 php5 ~ php7 까지 호환성 문제는 없다.
3. 홈페이지 소스가 위치해야 하는 경로는 /var/www/html 이다.
4. 홈페이지는 http(80), https(443) 으로 운영되어야 하며 고객들이 접속할 때는 공식인증서로 접속이 가능해야 한다.
5. 도커 재시작시 관리자 페이지의 변경 사항들은 유실되면 안된다. /var/www/html/admin/conf
   > php 관리자 페이지의 상태를 의미하는건가?  
   > 관리자 페이지가 먼저 있어야겠지
6. Web Server 는 nginx 를 사용한다.

```sh
# Build images
docker build -f Dockerfile-nginx -t raphael9292/nginx-fpm ./

# Run
docker-compose up -d

# Clean up
docker-compose down (--remove-orphans)
```

### 실패작

1. php-fpm이 안됨
2. /admin 으로 location 지정시 이런 에러 발생

```sh
2021/07/07 23:41:09 [error] 24#24: *9 connect() failed (111: Connection refused) while connecting to upstream, client: 192.168.16.1, server: _, request: "GET /admin HTTP/1.1", upstream: "http://192.168.16.3:3000/admin", host: "192.168.45.10"
```
