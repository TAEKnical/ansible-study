#!/bin/bash
ansible node2 -m service -a "name=mariadb state=stopped" -b

#DB 파일 제거 : /var/lib/mysql
ansible node2 -m file -a "path=/var/lib/mysql state=absent" -b

#selinux bollean 정책 : allow_user_mysql_connect
ansible node2 -m seboolean -a "name=allow_user_mysql_connect state=no persistent=no"

#패키지 제거 : epel-release, MySQL-python, libsemanage-python, MariaDB-server
ansible node2 -m yum -a "name=epel-release,MySQL-python,MariaDB-server,libsemanage-python state=absent" -b

#방화벽 : mysql
ansible node2 -m firewalld -a "service=mysql state=disabled immediate=true" -b

#레포제거: MariaDB
ansible node2 -m yum_repository -a "name=MariaDB state=absent" -b


#서비스 중지
ansible node1 -m service -a 'name=httpd state=stopped' -b

#파일 삭제
ansible node1 -m file -a 'path=/var/www/html/wordpress state=absent' -b

#seboolean -a 'name=httpd_can_network_connect_db state=no persistent=no'

ansible node1 -m yum -a "name=epel-release,libsemanage-python,httpd,php,php-mysql,remi-release state=absent"
#방화벽: 
ansible node1 -m firewalld -a "service=http state=disabled immediate=yes permanent=yes"

