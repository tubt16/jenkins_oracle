# Setup Jenkins upcode Oracle DB

Mô hình 

|Name|IP|OS|Installed|
|---|---|---|---|
|Jenkins1|34.168.148.119|CentOS 7|Jenkins-server|
|OracleDB|34.83.246.12|CentOS 7|Oracle ee 19c, Jenkins agent, git|

## Một số Plugin trên Jenkins cần cài đặt:

- Git plugin

- GitLab Plugin

- SQLPlus Script Runner

## Set global ORACLE_HOME trên Jenkins

Trên jenkins tại Dashboard chọn `Manage Jenkins` -> `System` đi tới phần `SQLPlus Script Runner` và thêm đoạn sau để khai báo `ORACLE_HOME`

```sh
/opt/oracle/product/19c/dbhome_1
```

![](/images/sqlplus_setup.png)

## Setup trên Server Oracle

Trên Oracle ta cần tạo một user phục vụ cho mục đích upcode. Ta tạo user và gán quyền như sau

Login OracleDB với quyền `sysdba` sử dụng sqlplus

```sh
[root@oracle mnt]# su oracle

[oracle@oracle mnt]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Tue Nov 14 07:28:24 2023
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> alter session set "_ORACLE_SCRIPT"=true;

Session altered.

SQL> create user tubt16 identified by tubt160999;

User created.

SQL> grant dba to tubt16;

Grant succeeded.
```

Sau khi tạo user xong chúng ta cần add `Credentials` trên Jenkins, để Jenkins sử dụng User này upcode

![](/images/credentials.png)

Thực hiện tạo `Credentials` như ảnh trên

## Một số file `.sql` cơ bản được sử dụng để test upcode

Thực hiện viết một số file `.sql` và commit lên gitlab

1. Create Table

`createTableInfomation.sql`

```sh
create table infomation (
    name varchar(10),
    age int,
    locate varchar(10),
    gender varchar(10),
    color varchar(10)
);
```

2. Insert Table

`insertTable.sql`

```sh
insert into infomation (name, age, locate, gender, color) values ('tubt', 24, 'Dong Anh', 'male', 'red');
insert into infomation (name, age, locate, gender, color) values ('tu1', 23, 'Ha Noi', 'male', 'blue');
insert into infomation (name, age, locate, gender, color) values ('tu2', 25, 'HN', 'male', 'green');
```

3. Select Table

`selectTable.sql`

```sh
select * from infomation;
```

4. Modify password 

`modifyPassword.sql`

```sh
alter user tubt16 identified by tubt1609@6;
```

5. Update Table

`updateTable.sql`

```sh
UPDATE infomation SET locate = 'DA', color = 'pink' WHERE name = 'tu2';
```

6. Delete Row

`deleteRow.sql`

```sh
DELETE from infomation WHERE name = 'tu2';
```

7. Drop Column

`dropColumn.sql`

```sh
ALTER table infomation DROP column color;
```

# Pipeline

1. Pipeline `jenkins_oracle_build`

```sh
pipeline {
    agent { label 'oracledb' }
    stages {
        
        stage ('Fetch code') {
            steps {
                git branch: 'main', url: 'http://gitlab.monest.sbs/tubt/jenkins_oracle.git'
            }
        }
        
        stage ('create table infomation') {
            steps {
                withCredentials([usernamePassword(credentialsId: '8f2225c9-5f54-441c-9928-8e37d0f45257', passwordVariable: 'DB_password', usernameVariable: 'DB_username')]) {
                    sh 'echo "`cat /var/lib/jenkins/workspace/Tu/jenkins_oracle_build/scripts/createTableInfomation.sql`" | sqlplus ${DB_username}/${DB_password}'
                }
            }
        }
        
        stage ('insert table infomation') {
            steps {
                withCredentials([usernamePassword(credentialsId: '8f2225c9-5f54-441c-9928-8e37d0f45257', passwordVariable: 'DB_password', usernameVariable: 'DB_username')]) {
                    sh 'echo "`cat /var/lib/jenkins/workspace/Tu/jenkins_oracle_build/scripts/insertTable.sql`" | sqlplus ${DB_username}/${DB_password}'
                }
            }
        }
        
        stage ('select table infomation') {
            steps {
                withCredentials([usernamePassword(credentialsId: '8f2225c9-5f54-441c-9928-8e37d0f45257', passwordVariable: 'DB_password', usernameVariable: 'DB_username')]) {
                    sh 'echo "`cat /var/lib/jenkins/workspace/Tu/jenkins_oracle_build/scripts/selectTable.sql`" | sqlplus ${DB_username}/${DB_password}'
                }
            }
        }
        
    }
}
```

Kết quả

![](/images/output.png)
![](/images/output1.png)
![](/images/output2.png)
![](/images/output3.png)

2. Pipeline `update_table`

```sh
pipeline {
    agent { label 'oracledb' }
    stages {
        
        stage ('Fetch code') {
            steps {
                git branch: 'main', url: 'http://gitlab.monest.sbs/tubt/jenkins_oracle.git'
            }
        }
        
        stage ('update table infomation') {
            steps {
                withCredentials([usernamePassword(credentialsId: '8f2225c9-5f54-441c-9928-8e37d0f45257', passwordVariable: 'DB_password', usernameVariable: 'DB_username')]) {
                    sh 'echo "`cat /var/lib/jenkins/workspace/Tu/update_table/scripts/updateTable.sql`" | sqlplus ${DB_username}/${DB_password}'
                }
            }
        }
        
        stage ('select table infomation') {
            steps {
                withCredentials([usernamePassword(credentialsId: '8f2225c9-5f54-441c-9928-8e37d0f45257', passwordVariable: 'DB_password', usernameVariable: 'DB_username')]) {
                    sh 'echo "`cat /var/lib/jenkins/workspace/Tu/update_table/scripts/selectTable.sql`" | sqlplus ${DB_username}/${DB_password}'
                }
            }
        }
        
    }
}
```

Kết quả

![](/images/updatetable1.png)
![](/images/updatetable2.png)

3. Pipeline `delete_row`

```sh
pipeline {
    agent { label 'oracledb' }
    stages {
        
        stage ('Fetch code') {
            steps {
                git branch: 'main', url: 'http://gitlab.monest.sbs/tubt/jenkins_oracle.git'
            }
        }
        
        stage ('delete row table infomation') {
            steps {
                withCredentials([usernamePassword(credentialsId: '8f2225c9-5f54-441c-9928-8e37d0f45257', passwordVariable: 'DB_password', usernameVariable: 'DB_username')]) {
                    sh 'echo "`cat /var/lib/jenkins/workspace/Tu/delete_row/scripts/deleteRow.sql`" | sqlplus ${DB_username}/${DB_password}'
                }
            }
        }
        
        stage ('select table infomation') {
            steps {
                withCredentials([usernamePassword(credentialsId: '8f2225c9-5f54-441c-9928-8e37d0f45257', passwordVariable: 'DB_password', usernameVariable: 'DB_username')]) {
                    sh 'echo "`cat /var/lib/jenkins/workspace/Tu/delete_row/scripts/selectTable.sql`" | sqlplus ${DB_username}/${DB_password}'
                }
            }
        }
        
    }
}
```

Kết quả

![](/images/deleterow1.png)
![](/images/deleterow2.png)

4. Pipeline `drop_column`

```sh
pipeline {
    agent { label 'oracledb' }
    stages {
        
        stage ('Fetch code') {
            steps {
                git branch: 'main', url: 'http://gitlab.monest.sbs/tubt/jenkins_oracle.git'
            }
        }
        
        stage ('drop column table infomation') {
            steps {
                withCredentials([usernamePassword(credentialsId: '8f2225c9-5f54-441c-9928-8e37d0f45257', passwordVariable: 'DB_password', usernameVariable: 'DB_username')]) {
                    sh 'echo "`cat /var/lib/jenkins/workspace/Tu/drop_column/scripts/dropColumn.sql`" | sqlplus ${DB_username}/${DB_password}'
                }
            }
        }
        
        stage ('select table infomation') {
            steps {
                withCredentials([usernamePassword(credentialsId: '8f2225c9-5f54-441c-9928-8e37d0f45257', passwordVariable: 'DB_password', usernameVariable: 'DB_username')]) {
                    sh 'echo "`cat /var/lib/jenkins/workspace/Tu/drop_column/scripts/selectTable.sql`" | sqlplus ${DB_username}/${DB_password}'
                }
            }
        }
        
    }
}
```

Kết quả

![](/images/dropcolumn1.png)
![](/images/dropcolumn2.png)
