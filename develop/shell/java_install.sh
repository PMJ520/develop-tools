#!/bin/bash

# https://github.com/PMJ520/develop_tools/blob/master/develop/shell/java_install.sh
# 


# 询问配置参数并安装
function installQuestions () {
	echo "Welcome to the MySQL installer!"
	echo ""

	echo "I need to ask you a few questions before starting the setup."
	echo "You can leave the default options and just press enter if you are ok with them."
	echo ""
	result_logs=""
# 询问MySQL的安装情况
	echo "Choice of MySQL to install:"
	echo "   1) install (recommended)"
	echo "   2) not install"
	until [[ "$IF_install_MySQL" =~ ^[1-2]$ ]]; do
		read -rp "Cipher [1-2]: " -e -i 1 IF_install_MySQL
	done
	if [[ "$IF_install_MySQL" = "1" ]]; then
		
		installMySQLBefor
		if [[ "$IF_install_MySQL" = "0" ]]; then
			result_logs=$result_logs"\033[31m MySQL:Old MySQL not uninstalled, skip installing this MySQL…… \033[0m"

		fi;

	else 
		result_logs=$result_logs"\033[33m MySQL:Users cancel the installation of the MySQL…… \033[0m"
	fi

# 询问tomcat的安装情况
	echo "Choice of Tomcat to install:"
	echo "   1) install (recommended)"
	echo "   2) not install"
	until [[ "$IF_install_Tomcat" =~ ^[1-2]$ ]]; do
		read -rp "Cipher [1-2]: " -e -i 1 IF_install_Tomcat
	done
	if [[ "$IF_install_Tomcat" == "1" ]]; then
		installJDKBeforfun
		IF_install_Tomcat=$?
		if [[ $IF_install_Tomcat == "0" ]]; then 
			result_logs=$result_logs"\033[31m Tomcat:Old Tomcat not uninstalled, skip installing this Tomcat…… \033[0m"
		fi
		
	else 
		result_logs=$result_logs"\033[33m Tomcat:Users cancel the installation of the Tomcat…… \033[0m"
	fi
	
	
	echo -e "\033[32m Press any key to continue... \033[0m"
	read -n1 -r -p ""
		if [[ "$IF_install_MySQL" == "1" ]]; then
			installMySQL
			#return "\033[37m install MySQL Successful \033[0m \033[32m password=$DB_Root_Password ; port=$mysql_port \033[0m"
			MySQL_install_result=`netstat  -anp  |grep  $mysql_port`;
			if [[ $MySQL_install_result =~ "$mysql_port" ]];then
				result_logs=$result_logs"\033[32m MySQL: MySQL install Successful……\nMySQL directory: $MYSQL_directory\nMySQL version: 5.7.25\n $MYSQL_directory\nMySQL rootPassword: $DB_Root_Password  \033[0m"
			else
				result_logs=$result_logs"\033[33m MySQL: MySQL install faild;Please try 'service mysql start' startup……\nMySQL directory: $MYSQL_directory\nMySQL version: 5.7.25\nMySQL rootPassword: $DB_Root_Password \033[0m"
			fi
			#echo -e "$?";
		fi;
	if [[ "$IF_install_Tomcat" == "1" ]]; then 
		installTomcatFun
		tomcat_install_result=`netstat  -anp  |grep  8080`;
		if [[ $tomcat_install_result =~ "8080" ]];then
			result_logs=$result_logs"\n\033[32m Tomcat: Tomcat install Successful……\ntomcat directory: $TOMCAT_directory\ntomcat version:$TOMCAT_VERSION \njava version: $JAVA_VERSION  \033[0m"
		else
			result_logs=$result_logs"\n\033[33m Tomcat: Tomcat install faild;Please try 'service tomcat start' startup……\ntomcat directory: $TOMCAT_directory\ntomcat version:$TOMCAT_VERSION \njava version: $JAVA_VERSION \033[0m"
		fi
	fi
	echo -e "$result_logs";
	

}

####### Tomcat START  #######################################################################################3


#判断是否有安装Tomcat;1:已安装
function tomcatIfInstalledFun(){
	server_result_tomcat=`chkconfig | grep tomcat`;
	if [[ $server_result_tomcat =~ "tomcat" ]];then
		return 1;
	else
		if [ -f "/etc/init.d/tomcat" ];then 
			return 1;
		else 
			return 0;
		fi
	fi
}
#卸载旧的Tomcat
function deleteTomcat(){
	service tomcat stop;
	sleep 2;
	rm -rf /etc/init.d/tomcat*;
	chkconfig --del tomcat;
	echo 1; 
}
#安装Tomcat
function installJDKBeforfun(){
	read -rp "Please enter the install directory(default:/usr/local/tomcat): " -e -i "/usr/local/tomcat" TOMCAT_directory 
	while [[ $TOMCAT_directory != /* || -f $TOMCAT_directory ]]; do 
		echo -e "\033[31m directory error! \033[0m";
		read -rp "Please enter the install directory(default:/usr/local/tomcat): " -e -i "/usr/local/tomcat" TOMCAT_directory 
	done;
	tomcatIfInstalledFun
	hav_tomcat=$?
	if [[ "$hav_tomcat" = "1" ]]; then
		echo -e "\033[33m It seems that the Tomcat has been installed.  \033[0m"
		read -rp "Do you need to delete it?(y/n): " -e -i "y" if_del_old_tomcat 
		if [[ $if_del_old_tomcat == y* ]];then
			deleteTomcat
			return "1"
		else
			return "0"
		fi;
	else 
		return "1";
	fi
}
#安装jdk
function installJDKfun(){
	JAVA_VERSION=`java -version 2>&1 |awk 'NR==1{ gsub(/"/,""); print $3 }'`
	if [[ $JAVA_VERSION =~ "." ]];then
		JAVA_VERSION=$JAVA_VERSION;
	else
		TOMCAT_directory_end=`echo $TOMCAT_directory|awk -F '/' '{print $NF}'`
		JAVA_directory=${TOMCAT_directory/"$TOMCAT_directory_end"/"java"}
		if [ -z "$JAVA_directory" ];then
			JAVA_directory="/usr/local/java"
		fi;
		if [[ -d "$JAVA_directory" || -f "$JAVA_directory" ]];then
			rm -rf $JAVA_directory
		fi;
		mkdir -p $JAVA_directory
		echo "TOMCAT_directory="$TOMCAT_directory"TOMCAT_directory_end="$TOMCAT_directory_end"JAVA_directory="$JAVA_directory
		#sleep 10;
		rm -rf /tmp/jdk1.7.0_17* /tmp/jdk-7u17-linux-x64.tar.gz*
		cd /tmp && wget https://tools-1256410212.cos.ap-guangzhou.myqcloud.com/linux/java/jdk-7u17-linux-x64.tar.gz && tar zxvf jdk-7u17-linux-x64.tar.gz && cp -r jdk1.7.0_17/* $JAVA_directory/;
		
		PATH_line=`grep -rn "export PATH "  /etc/profile | awk -F ':' '{print $1}'`;
		sed -i "$PATH_line i export PATH=\$PATH:\$JAVA_HOME/bin:\$JRE_HOME/bin " /etc/profile
		sed -i "$PATH_line i export CLASS_PATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JRE_HOME/lib " /etc/profile
		sed -i "$PATH_line i export JRE_HOME=\$JAVA_HOME/jre " /etc/profile
		sed -i "$PATH_line i export JAVA_HOME=$JAVA_directory " /etc/profile
		sleep 1
		source /etc/profile
		JAVA_VERSION="1.7.0_17"
	fi
}


function installTomcatFun(){
	installJDKfun
	if [[ ! $JAVA_VERSION =~ "." ]];then
		installJDKfun
	fi
	if [[ $JAVA_VERSION =~ "." ]];then 
		if [[ -d $TOMCAT_directory || -f $TOMCAT_directory ]];then
			rm -rf $TOMCAT_directory
		fi;
		mkdir -p $TOMCAT_directory
		rm -rf /tmp/apache-tomcat-8.0.52*
		cd /tmp && wget https://tools-1256410212.cos.ap-guangzhou.myqcloud.com/linux/java/apache-tomcat-8.0.52.tar.gz && tar zxvf apache-tomcat-8.0.52.tar.gz && cp -r apache-tomcat-8.0.52/* $TOMCAT_directory/;
		TOMCAT_directory_end=`echo $TOMCAT_directory|awk -F '/' '{print $NF}'`
		JAVA_directory=${TOMCAT_directory/"$TOMCAT_directory_end"/"java"}
		if [ -z "$JAVA_directory" ];then
			JAVA_directory="/usr/local/java"
		fi;
		cat > /etc/init.d/tomcat<<EOF
#!/bin/bash
### BEGIN INIT INFO
# Provides:          tomcat
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: tomcat-server daemon
# Description:       tomcat-server daemon
### END INIT INFO
#
# chkconfig: - 95 15
# description: Tomcat start/stop/status script

#Location of JAVA_HOME (bin files)
export JAVA_HOME=$JAVA_directory/jre

#Add Java binary files to PATH
export PATH=\$JAVA_HOME/bin:\$PATH

#CATALINA_HOME is the location of the configuration files of this instance of To                                                                                              mcat
CATALINA_HOME=$TOMCAT_directory

#TOMCAT_USER is the default user of tomcat
TOMCAT_USER=root

#TOMCAT_USAGE is the message if this script is called without any options
TOMCAT_USAGE="Usage: \$0 {\e[00;32mstart\e[00m|\e[00;31mstop\e[00m|\e[00;32mstatu                                                                                              s\e[00m|\e[00;31mrestart\e[00m}"

#SHUTDOWN_WAIT is wait time in seconds for java proccess to stop
SHUTDOWN_WAIT=20

tomcat_pid() {
  echo \`ps -ef | grep java | grep \$CATALINA_HOME/ | grep -v grep | tr -s " "|cut                                                                                               -d" " -f2\`
}

start() {
  pid=\$(tomcat_pid)
  if [ -n "\$pid" ]; then
    echo -e "\e[00;31mTomcat is already running (pid: \$pid)\e[00m"
  else
    echo -e "\e[00;32mStarting tomcat\e[00m"
    if [ \`user_exists \$TOMCAT_USER\` = "1" ]; then
      su \$TOMCAT_USER -c \$CATALINA_HOME/bin/startup.sh
    else
      \$CATALINA_HOME/bin/startup.sh
    fi
    status
  fi
  return 0
}

status() {
  pid=\$(tomcat_pid)
  if [ -n "\$pid" ]; then
    echo -e "\e[00;32mTomcat is running with pid: \$pid\e[00m"
  else
    echo -e "\e[00;31mTomcat is not running\e[00m"
  fi
}

stop() {
  pid=\$(tomcat_pid)
  if [ -n "\$pid" ]; then
    echo -e "\e[00;31mStoping Tomcat\e[00m"
    \$CATALINA_HOME/bin/shutdown.sh

    let kwait=\$SHUTDOWN_WAIT
    count=0;
    until [ \`ps -p \$pid | grep -c \$pid\` = '0' ] || [ \$count -gt \$kwait ]
    do
      echo -n -e "\e[00;31mwaiting for processes to exit\e[00m\n";
      sleep 1
      let count=\$count+1;
    done

    if [ \$count -gt \$kwait ]; then
      echo -n -e "\n\e[00;31mkilling processes which didn't stop after \$SHUTDOWN                                                                                              _WAIT seconds\e[00m"
      kill -9 \$pid
    fi
  else
    echo -e "\e[00;31mTomcat is not running\e[00m"
  fi

  return 0
}

user_exists() {
  if id -u \$1 >/dev/null 2>&1; then
    echo "1"
  else
    echo "0"
  fi
}

case \$1 in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  status)
    status
    ;;
  *)
    echo -e \$TOMCAT_USAGE
    ;;
esac
exit 0

EOF
	chmod a+x /etc/init.d/tomcat && chkconfig --add tomcat && chkconfig tomcat on && chkconfig start
	TOMCAT_VERSION="8.0.52"
	else
		return "jdk install faild……";
	fi
}


####### Tomcat END  #######################################################################################3



####### MySQL START  #######################################################################################3

#判断是否有安装mysql;1:已安装
function mysqlIfInstalledFun(){

	server_result_mysql=`chkconfig | grep mysql`;
	if [[ $server_result_mysql =~ "mysql" ]];then
		return 1;
	else
		if [ -f "/etc/init.d/mysql" ];then 
			return 1;
		else 
			return 0;
		fi
	fi
}
#卸载旧的mysql
function deleteMySQL(){
	service mysql stop;
	sleep 2;
	rm -rf /etc/init.d/mysql*;
	chkconfig --del mysql;
	return 1; 
}
function installMySQLBefor(){
	IF_install_MySQL="1";
	read -rp "Please enter the install directory(default:/usr/local/mysql): " -e -i "/usr/local/mysql" MYSQL_directory 
		while [[ $MYSQL_directory != /* || -f $MYSQL_directory ]]; do 
			echo -e "\033[31m directory error! \033[0m";
			read -rp "Please enter the install directory(default:/usr/local/mysql): " -e -i "/usr/local/mysql" MYSQL_directory 
		done;
		mysqlIfInstalledFun
		mysqlIfInstalled=$?;
		echo $mysqlIfInstalled
		if [[ $mysqlIfInstalled == "1" ]];then 
			echo -e "\033[31m MySQL already been installed,Is delete... \033[0m";
			until [[ $IFdeleteMYSQL =~ (y|n) ]]; do
				read -rp "Is delete MySQL? [y/n]: " -e -i n IFdeleteMYSQL;
			done
			if [[ $IFdeleteMYSQL == "y" ]];then
				deleteMySQL;
				IF_install_MySQL="1";
			else 
				IF_install_MySQL="0";
				echo "skip install mysql!!!";
			fi;
		fi;
	if [[ "$IF_install_MySQL" = "1" ]]; then
		read -rp "Please enter the root password (default:1234567890): " -e -i "1234567890" DB_Root_Password
	fi;
	
	return $IF_install_MySQL
}
# install mysql
function installMySQL(){
	if [ -f "/tmp/mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz" ];then 
		rm -rf /tmp/mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz;
	fi;
	if [ -d "/tmp/mysql-5.7.25-linux-glibc2.12-x86_64" ];then 
		rm -rf /tmp/mysql-5.7.25-linux-glibc2.12-x86_64;
	fi;
	if [ -d $MYSQL_directory ];then 
		rm -rf $MYSQL_directory;
	fi;
	# mysql安装目录不存在时创建目录
	if [ -d $MYSQL_directory || -f $MYSQL_directory ];then 
		rm -rf $MYSQL_directory;
	fi;
	mkdir -p $MYSQL_directory/data;
	mkdir -p $MYSQL_directory/logs;
	# 创建mysql用户并将安装目录归属为mysql用户
	user_if_exist=sudo cat /etc/passwd|grep mysql | awk -F ":" '{print $1,$6}';
	if [ -z $user_if_exist ];then
		groupadd mysql && useradd -r -g mysql mysql && chown -R mysql:mysql $MYSQL_directory;
	else
		the_groups=$user_if_exist | awk -F "/" '{print $NF}'
		if [ -z $the_groups ];then
			groupadd mysql && usermod -a -G mysql mysql && chown -R mysql:mysql $MYSQL_directory;
		else 
			#usermod -a -G $user_if_exist mysql;
			chown -R $the_groups:mysql $MYSQL_directory;
		fi;
	fi


	cd /tmp && wget https://tools-1256410212.cos.ap-guangzhou.myqcloud.com/privateToMe/tools/mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz && tar zxvf mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz && cp -r mysql-5.7.25-linux-glibc2.12-x86_64/* $MYSQL_directory/;
#	cd /tmp && wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz && tar zxvf mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz && cp -r mysql-5.7.25-linux-glibc2.12-x86_64 $MYSQL_directory;
	if [ -f "/etc/my.cnf" ];then
		if [ -f "/etc/my.cnf.pmj" ];then 
			rm -rf /etc/my.cnf.pmj;
		fi;
		cp /etc/my.cnf /etc/my.cnf.pmj
		rm -rf /etc/my.cnf;
	fi;
	yum install -y numactl libaio && $MYSQL_directory/bin/mysqld --initialize --explicit_defaults_for_timestamp --user=mysql --basedir=$MYSQL_directory --datadir=$MYSQL_directory/data ;

	mysql_port=3306
	while [ 1 -eq 1 ] 
	do
		server_result=`netstat  -anp  |grep   $mysql_port`;
		if [[ $server_result =~ $mysql_port ]];then
			mysqlIfInstalled=1;
			mysql_port=$[mysql_port+1];
		else
			break
		fi
	done
	
	cat > /etc/my.cnf<<EOF
[mysqld]
character-set-server = utf8
basedir = $MYSQL_directory
datadir = $MYSQL_directory/data
port = $mysql_port
user = mysql
socket = $MYSQL_directory/data/mysql.sock
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

[client]
default-character-set=utf8
socket = $MYSQL_directory/data/mysql.sock

[mysql]
default-character-set=utf8
socket = $MYSQL_directory/data/mysql.sock
EOF
	
	
	
	
	
	cp $MYSQL_directory/support-files/mysql.server /etc/init.d/mysql && chmod a+x /etc/init.d/mysql;
	MySQL_UPDATE_PASSWORD

	chkconfig --add mysql && chkconfig mysql on && service mysql start ;
	return "\033[37m install MySQL Successful \033[0m \033[32m password=$DB_Root_Password ; port=$mysql_port \033[0m"
#	echo -e "\033[37m install MySQL Successful \033[0m \033[32m password=$def_password ; port=$mysql_port \033[0m"
}




MySQL_UPDATE_PASSWORD()
{
	/etc/init.d/mysql start
	sleep 2
    ln -sf $MYSQL_directory/data/mysql.sock /tmp/mysql.sock
    /etc/init.d/mysql stop
	sleep 2
	rm -rf /etc/my.cnf.pmj.def
	mv /etc/my.cnf /etc/my.cnf.pmj.def
	cat > /etc/my.cnf<<EOF
[mysqld]
character-set-server = utf8
basedir = $MYSQL_directory
datadir = $MYSQL_directory/data
port = 3306
user = mysql
socket = $MYSQL_directory/data/mysql.sock
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
skip-grant-tables
[client]
default-character-set=utf8
socket = $MYSQL_directory/data/mysql.sock

[mysql]
default-character-set=utf8
socket = $MYSQL_directory/data/mysql.sock
EOF

	/etc/init.d/mysql start

	$MYSQL_directory/bin/mysql -uroot -p'\x00' <<EOF
FLUSH PRIVILEGES;
alter user 'root'@'localhost' identified by '${DB_Root_Password}';
FLUSH PRIVILEGES;
\q;
EOF
	/etc/init.d/mysql stop

	rm -rf /etc/my.cnf
	mv /etc/my.cnf.pmj.def /etc/my.cnf



}


####### MySQL END  #######################################################################################3



installQuestions
