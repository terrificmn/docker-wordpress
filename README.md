# raspberry pi 3 에 docker 설치하기
라즈베리파이에 docker 설치하기 및 wordpress 설치하기 입니다.   
필요하신분은 다운로드 받아서 README 내용 처럼 해주시면 됩니다.   

라즈베리파이 3 b+ 모델에서 설치
ARM 아키텍쳐 아마 32비트 라즈비안 OS 전용 방식입니다~

설치에 앞서 만약 64비트에 사용을 하고 싶다면 docker와 docker-compose는 다른 방식으로 설치되어 합니다.
[도커 엔진 다운로드-docker-install 방문하기](https://docs.docker.com/engine/install/centos/)  

[도커 허브 방문하기](https://hub.docker.com/search?offering=community&operating_system=linux&q=&type=edition)
이곳에서 원하는 운영체제 치 디스트리뷰션을 선택해서 진행하세요~
관련 document를 보면 도움이 될 겁니다.

<br>

이제 docker raspberry pi에 설치하기 시작합니다~

먼저 apt update를 해준다
```
sudo apt update
```

[도커 깃허브-docker-install 방문하기](https://github.com/docker/docker-install)

docker에서 깃허브로 한 줄의 소스 코드로 docker를 설치할 수 있게 해준다
```
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

(옵션사항) 도커 그룹에 pi 유저를 등록하려면 
```
sudo usermod -aG docker pi
```
<br>

# docker-compose 설치
다른 64 아키텍쳐랑 방식으로는 docker-compose가 설치가 안된다. 파이썬으로 설치를 할 수 있다.  
라즈베리파이에 기본으로 설치되는 파이썬 버전은 3.7을 이용  

먼저 의존성 패키지 설치
```
sudo apt update
sudo apt install -y python3-pip libffi-dev
```

docker-compose 설치
```
sudo pip3 install docker-compose
```

<br>

# 현재 깃허브에서 다운로드 받으면 설정해줄 부분
다운받은 Dockerfile이 위치한 디렉토리로 이동한다 (원하는 디렉토리명으로 바뀌어도 상관없다)
먼저 디렉토리를 2개 만들어 준다

```
cd ~/Projects/docker-wordpress
mkdir src
mkdir mysqldata
```
> src 디렉토리는 docker-compose파일에서 도커 컨테이너와 연결시켜준 부분이므로 src 디렉토리 필요함  
mysqldata는 docker-compose파일에서 mysql 데이터가 저장되는 디렉토리로 연결시켜줌

그래서 2개의 디렉토리는 만들어 주세요. (src와 mysqldata)


<br>

# yml 파일 및 .env파일의 DB 설정하기
wordpress를 사용하기 위한 데이터베이스 설정해주기

먼저 docker-compose.yml 파일을 연다 (편집기나 vi 등)
mysql 컨테이너 부분에서 찾는다
```yml
environment:
      MYSQL_ROOT_PASSWORD: secret-password  
    environment:
      MYSQL_ROOT_PASSWORD: root비번  
      MYSQL_DATABASE: wordpress
      MYSQL_USER: user아이디
      MYSQL_PASSWORD: user패스워드
```
원하는 id와 비밀번호를 입력한 후 저장 해주세요

그리고 숨김파일인 .env 파일도 열어준다
```yml
WORDPRESS_DB_HOST=mysql:3306
WORDPRESS_DB_USER=user아이디
WORDPRESS_DB_PASSWORD=user패스워드
WORDPRESS_DB_NAME=wordpress
```

docker-compose.yml 에서 설정한 것과 같은 user아이디/패스워드를 적는다. 
DB_HOST는 그대로 둡니다

저장하고 빠져나오기


<br>

# wordpress 다운 받기
src 디렉토리로 이동한다. 그리고 wget으로 다운로드를 받는다
```shell
$cd ~/Projects/docker-wordpress/src/
$wget https://wordpress.org/latest.tar.gz
```
그리고 압축을 푼다
```shell
$tar -zxvf wordpress-5.7.2.tar.gz
```
이제 wordpress라는 디렉토리가 생겼을 것이다.

만약 wget이 안된다면 직접 사이트에 들어가서 다운로드를 받으면 된다  
[wordpress.org에 접속](https://wordpress.org)  
직접 다운로드를 받는다  (zip파일과 tar파일을 제공)

압축을 푼 후에 마찬가지로 src 디렉토리 안에 wordpress가 위치하게 이동시켜주면 된다
(압축 파일명과 디렉토리명은 다를 수 있음에 주의)
이때는 
```shell
$cd ~/Downloads
$tar -zxvf wordpress-5.7.2.tar.gz
$mv wordpress ~/Projects/docker-wordpress/src/
```

마지막으로 wordpress 디렉토리 권한 바꿔주기
```shell
$ sudo chown -R www-data:www-data wordpress
```
docker의 php-apache2 컨테이너가 wordpress의 내용을 사용(수정)할 수 있게 소유 권한을 바꿔준다.
그래야 wordpress 안의 파일들이 필요할 때 원할하게 수정이 될 수 있다

<br>

# docker-compose build && up
Dockerfile이 있는 상위 경로로 이동해 줘야한다

```shell
$cd ..
```
위에서 docker를 설치 했기 때문에 도커가 실행 중이겠지만 도커 상태를 한번 확인해 본다
```shell
sudo systemctl status docker
```
문제가 없고 active (running) 로 잘 실행되고 있다면 q를 누르고 빠져나와 
도커 빌드를 한다
```shell
$docker-compose build
```
다운로드 및 빌드를 한다. 시간이 조금 소요됨

이제 docker container들이 실행이 되게 up을 시켜준다
```shell
$docker-compose up
```
이것도 다운로드 조금 받고 실행이 된다.
이때 도커 컨테이너가 실행되면서 특히 이때 mysql 도커 컨테이너에서는 데이터베이스 및 db사용할 유저등을 최초 생성해 준다

<br>

# 성공적으로 도커가 실행되었다면
웹 브라우저를 열고 주소창에 **localhost** 를 입력한다

wordpress 설치 화면이 DB 정보를 입력해준다. 유저 id/password 정보를 넣어준다
db는 다른걸로 바꾸지 않았다면 wordpress로 넣어주고  
database host는 localhost가 아닌 도커 컨테이너를 적어줘야한다 mysql 이라고 적어준다

<br>

phpmyadmin을 이용하고 싶으면 
웹브라우저에 **localhost:8080** 을 입력한다 
phpmyadmin 페이지가 뜨면 
서버는 mysql 그리고 유저id 패스워드를 넣고 입력한다 
wordpress database가 보일 것이다

<br>

# 트러블 슈팅
1. 만약 포트가 사용하고 있다고 한다면
기존에 아파치 웹 서버가 mariadb 등이 실행되고 있는지 확인한다
    ```shell
    systemctl status apache2
    systemctl stop apache2
    ```

    ```shell
    systemctl status mariadb
    systemctl stop mariadb
    ```
<br>

2. docker-compose build 시에 아래와 같은 에러 발생

    ```
    error checking context: 'can't stat '/home/pi/Workspace/docker-wordpress/mysqldata/mysql''.
    ERROR: Service 'php' failed to build : Build failed
    ```

    mysqldata 디렉토리 안에 있는 파일을 지워준다.
    ```shell
    cd mysqldata
    $sudo rm -rf ./
    ```
    그리고 다시 build를 실행한다

<br>

3. wordpress 설치 실행 후 DB설정에서 넘어가지 않을 경우
    unable to write to wp-config.php file 에러가 발생한다면

    /src/wordpress의 권한을 아파치 권한으로 바꿔줘야한다

    ```
    $ls -l ~/Projects/docker-wordpress/src/wordpress
    ```

    만약 소유권한이 pi 그룹권한도 pi로 되어 있다면 
    pi pi

    소유 권한을 바꾼다
    ```
    $cd ~/Projects/docker-wordpress/src/wordpress
    $sudo chown -R www-data:www-data wordpress
    ```

<br>

# 끝
추가로 docker-compose에 wordpress를 image를 직접 받아서   
wordpress도 도커 컨테이너로 실행 시킬 수 있는 것 같습니다. 
즉, wordpress도 도커 이미지가 있습니다 

원하시는 분을 try 해보세요~ docker-compose.yml 파일에 wordpress 컨테이너를 추가하고 
아마 .env 파일의 환경변수도 여기에 쓰면 될 듯 합니다.

감사합니다~ ^^
