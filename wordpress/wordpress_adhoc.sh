#아파치 설치,재시작,방화벽
ansible node1 -m yum -a "name=httpd state=latest" -b
ansible node1 -m firewalld -a "immediate=true permanent=true service=http state=enabled" -b

#repository 추가
ansible all -m yum -a "name=https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm" -b
ansible all -m yum -a "name=https://rpms.remirepo.net/enterprise/remi-release-7.rpm" -b
ansible node1 -a "yum-config-manager --enable remi-php74" -b

#php74 설치
ansible node1 -m yum -a "name=php" -b
ansible node1 -m yum -a "name=php-mysql" -b

#아파치 재시작
ansible node1 -m service -a "name=httpd state=restarted enabled=true" -b

#wordpress 다운/설치
ansible node1 -m get_url -a "dest=/tmp/latest.tar.gz url=https://wordpress.org/latest.tar.gz" -b
ansible node1 -m unarchive -a "remote_src=yes src=/tmp/latest.tar.gz dest=/tmp/" -b
ansible node1 -m copy -a "remote_src=yes src=/tmp/wordpress/ dest=/var/www/html/wordpress/" -b

#wp-config
ansible node1 -m copy -a "src=/var/www/html/wordpress/wp-config-sample.php dest=/var/www/html/wordpress/wp-config.php remote_src=yes" -b 
ansible node1 -m replace -a "path=/var/www/html/wordpress/wp-config.php regexp=database_name_here replace=wordpress" -b
ansible node1 -m replace -a "dest=/var/www/html/wordpress/wp-config.php regexp=username_here replace=wpadmin" -b
ansible node1 -m replace -a "dest=/var/www/html/wordpress/wp-config.php regexp=password_here replace=wpadmin" -b
ansible node1 -m replace -a "dest=/var/www/html/wordpress/wp-config.php regexp=localhost replace=192.168.122.52" -b

#mariadb 설치,세팅
ansible node2 -m yum_repository -a "name=MariaDB description=MariaDB baseurl=http://yum.mariadb.org/10.5.4/centos7-amd64/ gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB gpgcheck=1" -b
ansible node2 -m yum -a "name=MariaDB-server" -b
ansible node2 -m service -a "name=mariadb state=started enabled=true" -b
ansible node2 -m firewalld -a "immediate=true permanent=true service=mysql state=enabled" -b
ansible node2 -m yum -a "name=MySQL-python state=latest" -b
ansible node2 -m mysql_user -a "name=root login_password='' login_host=localhost login_user=root password=toor" -b
ansible node2 -m mysql_db -a "name=wordpress login_user=root login_password=toor login_host=localhost" -b
ansible node2 -m mysql_user -a "name=wpadmin password=wpadmin login_user=root login_password=toor login_host=localhost priv=wordpress.*:ALL,GRANT host=% state=present" -b




# VM이면 지우면 되는데, 이 시스템이 베어메탈이라면?
# #서비스 중지 : mariadb
# ansible node2 -m service -a "name=mariadb state=stopped" -b

# #DB 파일 제거 : /var/lib/mysql
# ansible node2 -m file -a "path=/var/lib/mysql state=absent" -b

# #selinux bollean 정책 : allow_user_mysql_connect
# ansible node2 -m seboolean -a "name=allow_user_mysql_connect state=no persistent=no"

# #패키지 제거 : epel-release, MySQL-python, libsemanage-python, MariaDB-server
# ansible node2 -m yum -a "name=epel-release,MySQL-python,MariaDB-server,libsemanage-python state=absent" -b

# #방화벽 : mysql
# ansible node2 -m firewalld -a "service=mysql state=disabled immediate=true" -b

# #레포제거: MariaDB
# ansible node2 -m yum_repository -a "name=MariaDB state=absent" -b


# #서비스 중지
# ansible node1 -m service -a 'name=httpd state=stopped' -b

# #파일 삭제
# ansible node1 -m file -a 'path=/var/www/html/wordpress state=absent' -b

# #seboolean -a 'name=httpd_can_network_connect_db state=no persistent=no'

# ansible node1 -m yum -a "name=epel-release,libsemanage-python,httpd,php,php-mysql,remi-release state=absent"
# #방화벽: 
# ansible node1 -m firewalld -a "service=http state=disabled immediate=yes permanent=yes"


