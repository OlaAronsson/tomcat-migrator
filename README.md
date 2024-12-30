# tomcat-migrator
Just a small tool for migrating tomcat version A -> B

* download a fresh tomcat
* place it under /opt/tomcat.

The idea here is that you toggle tomcats via a 'latest' softlink under /opt/tomcat. Then you have an associated

/etc/systemd/system/tomcat.service.[version]

config file for systemctl.

\$ git clone git@github.com:OlaAronsson/tomcat-migrator.git

\$ tar zcvf tomcat-migrator.tar.gz migrate.sh tomcat_conf

\$ su -

\$ mv tomcat-migrator.tar.gz /opt/tomcat

\$ cd /opt/tomcat

\$ tar zxvf tomcat-migrator.tar.gz

\$ chmod 700 ./migrate.sh

\$ ./migrate.sh
