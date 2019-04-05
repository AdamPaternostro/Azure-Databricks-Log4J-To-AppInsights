#!/bin/bash

echo "BEGIN: Upload App Insights JARs"
STAGE_DIR=/dbfs/databricks/appinsights
cp -f "$STAGE_DIR/applicationinsights-core-2.3.0.jar" /mnt/driver-daemon/jars || { echo "Error copying file"; exit 1;}
cp -f "$STAGE_DIR/applicationinsights-logging-log4j1_2-2.3.0.jar" /mnt/driver-daemon/jars || { echo "Error copying file"; exit 1;}
echo "END: Upload App Insights JARs"

echo "BEGIN: Setting Environment variables"
sudo echo APPINSIGHTS_INSTRUMENTATIONKEY=00000000-0000-0000-0000-000000000000 >> /etc/environment
echo "BEGIN: Setting Environment variables"

echo "BEGIN: Updating Executor log4j properties file"
sed -i 's/log4j.rootCategory=INFO, console/log4j.rootCategory=INFO, console, aiAppender/g' /home/ubuntu/databricks/spark/dbconf/log4j/executor/log4j.properties
echo "log4j.appender.aiAppender=com.microsoft.applicationinsights.log4j.v1_2.ApplicationInsightsAppender" >> /home/ubuntu/databricks/spark/dbconf/log4j/executor/log4j.properties
echo "log4j.appender.aiAppender.DatePattern='.'yyyy-MM-dd" >> /home/ubuntu/databricks/spark/dbconf/log4j/executor/log4j.properties
echo "log4j.appender.aiAppender.layout=org.apache.log4j.PatternLayout" >> /home/ubuntu/databricks/spark/dbconf/log4j/executor/log4j.properties
echo "log4j.appender.aiAppender.layout.ConversionPattern=[%p] %d %c %M - %m%n" >> /home/ubuntu/databricks/spark/dbconf/log4j/executor/log4j.properties
echo "BEGIN: Updating Executor log4j properties file"

echo "BEGIN: Updating Driver log4j properties file"
sed -i 's/log4j.rootCategory=INFO, publicFile/log4j.rootCategory=INFO, publicFile, aiAppender/g' /home/ubuntu/databricks/spark/dbconf/log4j/driver/log4j.properties
echo "log4j.appender.aiAppender=com.microsoft.applicationinsights.log4j.v1_2.ApplicationInsightsAppender" >> /home/ubuntu/databricks/spark/dbconf/log4j/driver/log4j.properties
echo "log4j.appender.aiAppender.DatePattern='.'yyyy-MM-dd" >> /home/ubuntu/databricks/spark/dbconf/log4j/driver/log4j.properties
echo "log4j.appender.aiAppender.layout=org.apache.log4j.PatternLayout" >> /home/ubuntu/databricks/spark/dbconf/log4j/driver/log4j.properties
echo "log4j.appender.aiAppender.layout.ConversionPattern=[%p] %d %c %M - %m%n" >> /home/ubuntu/databricks/spark/dbconf/log4j/driver/log4j.properties
echo "BEGIN: Updating Driver log4j properties file"