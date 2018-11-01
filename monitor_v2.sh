#!/bin/bash
#create by maoxf
#set -v
##############################
#                            #
#        configure           #
#                            #
##############################
#通知邮件 多个邮件用','分开
Mail=maoxf@sogood360.com


#log dir file 
log_dir=/data/logs/montior

#CPU %user  warning
cpu_user=80
#mem %user  warning
mem_user=80
#disk %user  warning
disk_user=70

#port monitor  warning
port_monitor="8080" 
port_service='Node服务'

#file dir monitor  warning 
monitor_dir=/opt
#tmp mail file
tmp_mail=/tmp/mail
#tmp md5 dir
tmp_md5=/tmp
#localhost IP 
L_IP='172.16.16.10'

######################################################################
#                             变量判断
test -d $log_dir || mkdir -p $log_dir

if [ ! -d $monitor_dir ]
     then 
     echo "指定的文件变动监控目录不存在";exit 1	 
fi

######################################################################
#                             初始化 日志文件生成MD5检查变更
echo "start script `date `">>$log_dir/monitor.log
find $monitor_dir -type f|xargs md5sum>/tmp/ROOT1.md5
in=0


######################################################################
#                             函数

#登陆
function Logged_monitor()
{ 
     logged=`last |grep "still logged in"|awk '{print $7" "$1"用户从"$3"登陆到"'$L_IP'}'|uniq -c`
     if [ -n "$logged" ]
         then
         echo $logged >>$tmp_mail
	 fi
}

 #日志文件发生变动 
function File_monitor()
{
   	
     find $monitor_dir -type f | xargs  md5sum >/tmp/ROOT2.md5
     File_name=`diff /tmp/ROOT1.md5 /tmp/ROOT2.md5|grep $monitor_dir|awk '{print $3}'|sort -u`
     if [ -n $File_name ]
         then 
         echo "$L_IP 日志文件变动 $File_name">>$tmp_mail
         echo "$L_IP 日志文件变动 $File_name"
	 fi   
}

#cup %user
function Cpu_monitor()
#使用top需要等待3次取最后一次刷新
{    CPU_USER=`top -n 3|grep Cpu|awk 'END {print 100-$8}'`
	#判断值为1则不报警
     if [ `expr $cpu_user \> $CPU_USER` -eq 0 ]
         then
         echo "CPU使用率达到 $CPU_USER % 超过警戒值 $cpu_user %">>$tmp_mail
         echo "2-CPU使用率达到 $CPU_USER % 超过警戒值 $cpu_user %"
     fi 
} 
	 
#mem %user
function Mem_monitor()
{     
     MEM_USER=`free |grep Mem |awk '{printf "%.2f",$3/$4*100}'`
	#超过警戒值则判断结果为0，报警
	 if [ `expr $mem_user \> $MEM_USER` -eq 0  ]
    	 then
		 echo "内存使用率达到 $MEM_USER % 超过警戒值$mem_user %">>$tmp_mail
		 echo "1-内存使用率达到 $MEM_USER % 超过警戒值$mem_user %"
	 fi
 }
 
 #DISK %USER
 function Disk_monitor()
 {
	 DISK_USER=`df |sed -n 2p|awk '{print $5}'|sed 's/%//'`
	 if [ `expr $DISK_USER \< $disk_user` -eq 0 ]
	     then 
		 echo "硬盘使用率达到 $DISK_USER % 超过警戒值$disk_user %">>$tmp_mail
		 echo "3-硬盘使用率达到 $DISK_USER % 超过警戒值$disk_user %"
	 fi
}
#port_monitor 单个端口监听
function Port_monitor()
{
	PORT_LISTEN=`netstat -ntlp| grep $port_monitor|wc -l`
	if [[ $PORT_LISTEN -eq 0 ]]
            then
		echo "监听端口$port_monitor $port_service 存在异常，请检查!">>$tmp_mail 
	fi
}

#mail
function Mail_send() 
{
     lin=`cat /tmp/mail|wc -l`
     if [ -n $lin ]
         then
         if [ $in == 1 ]
            then
            in=0
            continue   
         fi        
         in=`expr $in + 1`
         cat $tmp_mail |mail -s '来自腾讯云机器134.175.46.219的报警' $Mail
         sleep 5m
         cat $tmp_mail >>$log_dir/monitor.log
     fi
}

######################################################################
#                          
while true
do 
     echo ''>$tmp_mail 
     Mem_monitor
     Cpu_monitor
     Disk_monitor
     sleep 10s
     Port_monitor
     #File_monitor
     #Logged_monitor
     Mail_send
done
