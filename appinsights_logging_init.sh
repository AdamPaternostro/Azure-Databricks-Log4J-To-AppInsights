#!/bin/bash

STAGE_DIR="/dbfs/databricks/appinsights"
APPINSIGHTS_INSTRUMENTATIONKEY="FILL ME IN"
LOG_ANALYTICS_WORKSPACE_ID="FILL ME IN"
LOG_ANALYTICS_PRIMARY_KEY="FILL ME IN"

echo "BEGIN: Upload App Insights JARs"
cp -f "$STAGE_DIR/applicationinsights-core-2.3.0.jar" /mnt/driver-daemon/jars || { echo "Error copying file"; exit 1;}
cp -f "$STAGE_DIR/applicationinsights-logging-log4j1_2-2.3.0.jar" /mnt/driver-daemon/jars || { echo "Error copying file"; exit 1;}
echo "END: Upload App Insights JARs"

echo "BEGIN: Setting Environment variables"
sudo echo APPINSIGHTS_INSTRUMENTATIONKEY=$APPINSIGHTS_INSTRUMENTATIONKEY >> /etc/environment
echo "END: Setting Environment variables"

echo "BEGIN: Updating Executor log4j properties file"
sed -i 's/log4j.rootCategory=INFO, console/log4j.rootCategory=INFO, console, aiAppender/g' /home/ubuntu/databricks/spark/dbconf/log4j/executor/log4j.properties
echo "log4j.appender.aiAppender=com.microsoft.applicationinsights.log4j.v1_2.ApplicationInsightsAppender" >> /home/ubuntu/databricks/spark/dbconf/log4j/executor/log4j.properties
# echo "log4j.appender.aiAppender.DatePattern='.'yyyy-MM-dd" >> /home/ubuntu/databricks/spark/dbconf/log4j/executor/log4j.properties
echo "log4j.appender.aiAppender.layout=org.apache.log4j.PatternLayout" >> /home/ubuntu/databricks/spark/dbconf/log4j/executor/log4j.properties
echo "log4j.appender.aiAppender.layout.ConversionPattern=[%p] %d %c %M - %m%n" >> /home/ubuntu/databricks/spark/dbconf/log4j/executor/log4j.properties
echo "END: Updating Executor log4j properties file"

echo "BEGIN: Updating Driver log4j properties file"
sed -i 's/log4j.rootCategory=INFO, publicFile/log4j.rootCategory=INFO, publicFile, aiAppender/g' /home/ubuntu/databricks/spark/dbconf/log4j/driver/log4j.properties
echo "log4j.appender.aiAppender=com.microsoft.applicationinsights.log4j.v1_2.ApplicationInsightsAppender" >> /home/ubuntu/databricks/spark/dbconf/log4j/driver/log4j.properties
# echo "log4j.appender.aiAppender.DatePattern='.'yyyy-MM-dd" >> /home/ubuntu/databricks/spark/dbconf/log4j/driver/log4j.properties
echo "log4j.appender.aiAppender.layout=org.apache.log4j.PatternLayout" >> /home/ubuntu/databricks/spark/dbconf/log4j/driver/log4j.properties
echo "log4j.appender.aiAppender.layout.ConversionPattern=[%p] %d %c %M - %m%n" >> /home/ubuntu/databricks/spark/dbconf/log4j/driver/log4j.properties
echo "END: Updating Driver log4j properties file"

echo "BEGIN: Updating Azure Log Analytics properties file"
sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d
wget https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh && sh onboard_agent.sh -w $LOG_ANALYTICS_WORKSPACE_ID -s $LOG_ANALYTICS_PRIMARY_KEY
sudo su omsagent -c 'python /opt/microsoft/omsconfig/Scripts/PerformRequiredConfigurationChecks.py'
/opt/microsoft/omsagent/bin/service_control restart $LOG_ANALYTICS_WORKSPACE_ID
echo "END: Updating Azure Log Analytics properties file"