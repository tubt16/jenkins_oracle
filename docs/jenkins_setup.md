# Cài đặt jenkins server

Bước 1: Cài đặt `wget`

```sh
yum install wget -y
```

Bước 2: Tải xuống Jenkins repo

```sh
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
```

Bước 3: Import key

```sh
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
```

Bước 3: Cài đặt Java (Java 11)

```sh
sudo yum install fontconfig java-11-openjdk
```

Bước 4: Cài đặt Jenkins

```sh
sudo yum install jenkins
```

Bước 5: Enable Service

```sh
sudo systemctl daemon-reload

sudo systemctl enable jenkins
sudo systemctl start jenkins
```

# Cài đặt Jenkins Agent

Thực hiện add node Oracle vào Jenkins

Tại Dashboard Jenkins chọn `Manage Jenkins` sau đó chọn `Nodes` -> `New Node` để add Jenkins Agent

![](/images/jenkinsagent.png)

Add node với các thông tin như sau

![](/images/jenkinsagent1.png)

![](/images/jenkinsagent2.png)

Đứng tại server muốn cài agent chạy các câu lệnh sau

```sh
curl -sO http://34.168.148.119:8080/jnlpJars/agent.jar
nohup java -jar agent.jar -jnlpUrl http://34.168.148.119:8080/computer/ora/jenkins-agent.jnlp -secret 24d8accd5fed6aeb9f07130500ff87aaa6224ee2ecacc63bd8c70a74d501e710 -workDir "/var/lib/jenkins"
```

Lệnh trên được lấy từ mục `status` trong Node trên Jenkins

![](/images/agent.png)

