#!/bin/sh

export PATH="/usr/bin:/usr/sbin:/root/my_bin:/usr/local/tools/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"

# config
FROM=tomcat_conf
TO=tomcat_conf

echo
echo "Trying to migrate your tomcat from version $FROM -> $TO, setting up authentification and the systemctl stuff"
echo

bail(){
  LN=$1
  echo "  bailing at line : $LN" && echo && exit 1
}


initialChecks(){
  [ "`whoami`" != "root" ] && echo "  -FAILED : Son or girlie - you are not root. You are useless." && bail $LINENO
  [ "$FROM" == "$TO" ] && echo "  -FAILED : FROM and TO cannot be the same path - where are we going...?" && bail $LINENO
  [ "$TO" == "tomcat_conf" ] && echo "  -FAILED : target version cannot be the 'tomcat_conf folder - this is a source for sure!" && bail $LINENO

  HERE=`pwd`
  [ "$HERE" != "/opt/tomcat" ] && echo "  -FAILED : This thing should be placed under /opt/tomcat, softlinking 'latest' to the migrating target version" && bail $LINENO
}


doConf(){
  cp ./$FROM/conf/tomcat-users.xml ./$TO/conf/ || bail $LINENO
  cp ./$FROM/conf/server.xml ./$TO/conf/server.xml || bail $LINENO
  cp ./$FROM/webapps/manager/WEB-INF/web.xml ./$TO/webapps/manager/WEB-INF/web.xml || bail $LINENO
  cp ./$FROM//webapps/manager/META-INF/context.xml ./$TO/webapps/manager/META-INF/context.xml || bail $LINENO
  cp ./$FROM//conf/context.xml ./$TO/conf/context.xml || bail $LINENO
  cp ./$FROM//webapps/examples/META-INF/context.xml ./$TO/webapps/examples/META-INF/context.xml || bail $LINENO
  cp ./$FROM//webapps/host-manager/WEB-INF/manager.xml ./$TO/webapps/host-manager/WEB-INF/manager.xml || bail $LINENO
  chown -R tomcat:tomcat ./$TO  || bail $LINENO
  echo "  -SUCCESS : http://localhost:8080/manager/html will be available for user tomcat password tomcat" 
}

doSystemCtlStuff(){
if [ ! -f /etc/systemd/system/tomcat.service.$TO ]; then
  echo "  -FAILED : There is no /etc/systemd/system/tomcat.service.$TO" && echo
  echo "It should probably look something like"
  cat ./tomcat_conf/example_service_file
  bail $LINENO
else
  rm -rf latest
  ln -s $TO ./latest
  cp /etc/systemd/system/tomcat.service.$TO /etc/systemd/system/tomcat.service
  systemctl daemon-reload && systemctl restart tomcat && systemctl status tomcat  
  echo "  -SUCCESS : Migration is done : tomcat is now $TO"
fi
}

# Main
initialChecks
doConf
doSystemCtlStuff

exit 0
