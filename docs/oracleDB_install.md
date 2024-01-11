# Install Oracle Database 19c

# Điều kiện tiên quyết 

Cần tạo một tài khoản Oracle 

Máy chủ cần có ít nhất 2 GB RAM và 30 GB dung lượng đĩa trống

# Cài đặt

**Bước 1: Update Package và cài đặt các gói cần thiết**

Để bắt đầu, ta cần update các gói hiện tại trên CentOS 7 lên phiên bản mới nhất

```sh
yum update -y
```

**Bước 2: Tải xuống gói RPM cho Oracle Database 19c từ trang chủ sau đó upload nó lên máy chủ**

>> https://www.oracle.com/database/technologies/oracle-database-software-downloads.html

Nếu chưa có tài khoản, hãy đăng nhập sau đó tải xuống Oracle Database 19c cho Linux

**Bước 3: Cài đặt gói RPM `preinstall` trước tiên** (Gói này chưa các dependencies cần thiết để cài Oracle Database)

```sh
curl http://public-yum.oracle.com/public-yum-ol7.repo -o /etc/yum.repos.d/public-yum-ol7.repo
```

```sh
[root@oracledb yum.repos.d]# sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/public-yum-ol7.repo
[root@oracledb yum.repos.d]# rpm --import http://yum.oracle.com/RPM-GPG-KEY-oracle-ol7
[root@oracledb tubt]# yum --enablerepo=ol7_latest -y install oracle-database-preinstall-19c
```

**Bước 4: Cài đặt Oracle Database 19c**

```sh
[root@oracledb tubt]# rpm -Uvh oracle-database-ee-19c-1.0-1.x86_64.rpm 
Preparing...                          ################################# [100%]
Updating / installing...
   1:oracle-database-ee-19c-1.0-1     ################################# [100%]
[INFO] Executing post installation scripts...
[INFO] Oracle home installed successfully and ready to be configured.
To configure a sample Oracle Database you can execute the following service configuration script as root: /etc/init.d/oracledb_ORCLCDB-19c configure




[root@oracledb tubt]# /etc/init.d/oracledb_ORCLCDB-19c configure
Configuring Oracle Database ORCLCDB.
Prepare for db operation
8% complete
Copying database files
31% complete
Creating and starting Oracle instance
32% complete
36% complete
40% complete
43% complete
46% complete
Completing Database Creation
51% complete
54% complete
Creating Pluggable Databases
58% complete
77% complete
Executing Post Configuration Actions
100% complete
Database creation complete. For details check the logfiles at:
 /opt/oracle/cfgtoollogs/dbca/ORCLCDB.
Database Information:
Global Database Name:ORCLCDB
System Identifier(SID):ORCLCDB
Look at the log file "/opt/oracle/cfgtoollogs/dbca/ORCLCDB/ORCLCDB.log" for further details.

Database configuration completed successfully. The passwords were auto generated, you must change them by connecting to the database using 'sqlplus / as sysdba' as the oracle user.
```

**Bước 5: Set biến môi trường cho user `oracle`**

```sh
[root@oracledb tubt]# vi ~/.bash_profile

# add to the end
umask 022
export ORACLE_SID=ORCLCDB
export ORACLE_BASE=/opt/oracle/oradata
export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
export PATH=$PATH:$ORACLE_HOME/bin
```

```sh
[root@oracledb tubt]# source ~/.bash_profile
```

**Bước 6: Kiểm tra bằng cách connect đến database thông qua `sqlplus` command**

```sh
[root@oracledb tubt]# su oracle
[oracle@oracledb tubt]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Wed Nov 8 03:24:41 2023
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> exit
Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0
```

**Bước 7: Tạo systemd file**

Sửa dòng cuối trong file `/etc/oratab`

```sh
vi /etc/oratab

ORCLCDB:/opt/oracle/product/19c/dbhome_1:Y
```

Define biến môi trường

```sh
vi /etc/sysconfig/ORCLCDB.oracledb

ORACLE_BASE=/opt/oracle/oradata
ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
ORACLE_SID=ORCLCDB
```

Config listener service

```sh
[root@oracledb tubt]# vi /usr/lib/systemd/system/ORCLCDB@lsnrctl.service

[Unit]
Description=Oracle Net Listener
After=network.target

[Service]
Type=forking
EnvironmentFile=/etc/sysconfig/ORCLCDB.oracledb
ExecStart=/opt/oracle/product/19c/dbhome_1/bin/lsnrctl start
ExecStop=/opt/oracle/product/19c/dbhome_1/bin/lsnrctl stop
User=oracle

[Install]
WantedBy=multi-user.target
```

Config database service

```sh
[root@oracledb tubt]# vi /usr/lib/systemd/system/ORCLCDB@oracledb.service

[Unit]
Description=Oracle Database service
After=network.target lsnrctl.service

[Service]
Type=forking
EnvironmentFile=/etc/sysconfig/ORCLCDB.oracledb
ExecStart=/opt/oracle/product/19c/dbhome_1/bin/dbstart $ORACLE_HOME
ExecStop=/opt/oracle/product/19c/dbhome_1/bin/dbshut $ORACLE_HOME
User=oracle

[Install]
WantedBy=multi-user.target
```

Reload config systemd and enable service

```sh
[root@oracledb tubt]# systemctl daemon-reload
[root@oracledb tubt]# systemctl enable ORCLCDB@lsnrctl ORCLCDB@oracledb
Created symlink from /etc/systemd/system/multi-user.target.wants/ORCLCDB@lsnrctl.service to /usr/lib/systemd/system/ORCLCDB@lsnrctl.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/ORCLCDB@oracledb.service to /usr/lib/systemd/system/ORCLCDB@oracledb.service.
```