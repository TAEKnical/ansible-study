# node1 node2 아파치 설치
ansible node1 -m yum -a "name=httpd state=latest" -b
ansible node1 -m firewalld -a "immediate=true permanent=true service=http state=enabled" -b
ansible node2 -m yum -a "name=httpd state=latest" -b
ansible node2 -m firewalld -a "immediate=true permanent=true service=http state=enabled" -b

# node1 node2 /var/www/html nfs 연결
ansible node1 -m yum -a "name=nfs-utils state=latest" -b
ansible node1 -m firewalld -a "immediate=true permanent=true service=nfs state=enabled" -b
ansible node1 -m service -a "name=nfs-server state=started enabled=true" -b
ansible node1 -m replace -a "dest=/etc/exports regexp='' replace=/var/www/html"
ansible node1 -m replace -a "dest=/var/www/html/wordpress/wp-config.php regexp=localhost replace=192.168.122.52" -b
# node1 node2 워드프레스 구축
# node3 nfs
# node3 DB 구축
ansible node3 -m yum_repository -a "name=MariaDB description=MariaDB baseurl=http://yum.mariadb.org/10.5.4/centos7-amd64/ gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB gpgcheck=1" -b
ansible node3 -m yum -a "name=MariaDB-server" -b
ansible node3 -m service -a "name=mariadb state=started enabled=true" -b
ansible node3 -m firewalld -a "immediate=true permanent=true service=mysql state=enabled" -b
ansible node3 -m yum -a "name=MySQL-python state=latest" -b
ansible node3 -m mysql_user -a "name=root login_password='' login_host=localhost login_user=root password=toor" -b
ansible node3 -m mysql_db -a "name=wordpress login_user=root login_password=toor login_host=localhost" -b
ansible node3 -m mysql_user -a "name=wpadmin password=wpadmin login_user=root login_password=toor login_host=localhost priv=wordpress.*:ALL,GRANT host=% state=present" -b



