# Azure-Databricks-Log4J-To-AppInsights
Connect your Spark Databricks clusters Log4J output to the Application Insights Appender.  This will help you get your logs to a centralized location such as App Insights.  Many of my customers have been asking for this along with getting the Spark job data from the cluster (that will be a future project).

## Issues
- This is currently being tested.
- The sed command in the appinsights_logging_init.sh could be smarter.  I just needs to append versus a full replace.

## Configuration Steps
1. Create Databricks workspace in Azure
2. Create Application Insights in Azure (get your instrumentation key)
3. Install Databricks CLI
4. Open your Azure Databricks workspace, click on the user icon and create a token
5. Run "databricks configure --token" to configure the Databricks CLI
6. Replace APPINSIGHTS_INSTRUMENTATIONKEY (00000000-0000-0000-0000-000000000000) in the appinsights_logging_init.sh script
7. Run Upload-Items-To-Databricks.sh (change the .bat for Windows).  Linux you need to do a chmod +x on this file to run.
8. Create a cluster in Databricks (any size and shape is fine)
    - Make sure you click Advanced Options and "Init Scripts"
    - Add a script for "dbfs:/databricks/appinsights/appinsights_logging_init.sh"
    ![alt tag](https://raw.githubusercontent.com/AdamPaternostro/Azure-Databricks-Log4J-To-AppInsights/master/images/databrickscluster.png)
9. Start the cluster    

## Verification Steps
1. Import the notebook AppInsightsTest
2. Run the notebook
    1. Cell 1 displays your application insights key
    2. Cell 2 displays your jars (application insights jars should be in here)
    3. Cell 3 displays your log4j.properities file on the "driver" (which has the aiAppender)
    4. Cell 4 displays your log4j.properities file on the "executor" (which has the aiAppender)
    5. Cell 5 writes to Log4J so the message will appear in App Insights
    6. Cell 6 writes to App Insights via the App Insights API.  This will show as a "Custom Event" (customEvents table).
3. Open your App Insights account in the Azure Portal
4. Click on Search (top bar or left menu)
5. Click Refresh (over and over until you see data)
    - For a new App Insights account this can take 10 to 15 minutes to really initialize
    - For an account that is initialized expect a 1 to 3 minute delay for telemetry

## Now that you have data
1. The data will come into App Insights as a Trace
![alt tag](https://raw.githubusercontent.com/AdamPaternostro/Azure-Databricks-Log4J-To-AppInsights/master/images/dimensiondata.png)

2. This means the data will be in the customDimensions field as a property bad
3. Open the Analytic query for App Insights
4. Run ``` traces | order by timestamp desc ```
   - You will notice how customDimensions contains the fields 
5. Parse the custom dimensions.  This will make the display easier.
```
traces 
| project 
  message,
  severityLevel,
  LoggerName=customDimensions["LoggerName"], 
  LoggingLevel=customDimensions["LoggingLevel"],
  SourceType=customDimensions["SourceType"],
  ThreadName=customDimensions["LoggingLevel"],
  SparkTimestamp=customDimensions["TimeStamp"],
  timestamp 
| order by timestamp desc
```
ß
![alt tag](https://raw.githubusercontent.com/AdamPaternostro/Azure-Databricks-Log4J-To-AppInsights/master/images/formatteddata.png)

6. Run ``` customEvents | order by timestamp  desc ``` to see the custom event your Notebook wrote
7. Run ``` customMetrics | order by timestamp  desc ``` to see the HeartbeatState
8. Don't know which field has your data: ``` traces | where * contains "App Insights on Databricks"    ```

## Things you can do
1. For query help see: https://docs.microsoft.com/en-us/azure/kusto/query/
2. Show this data in Power BI: https://docs.microsoft.com/en-us/azure/azure-monitor/app/export-power-bi
3. You can pin your queries to an Azure Dashboard: https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-dashboards
4. You can configure continuous export your App Insights data and send to other systems. Create a Stream Analytics job to monitor the exported blob location and send from there.
5. Set up alerts: https://docs.microsoft.com/en-us/azure/azure-monitor/platform/alerts-log-query
6. You can get JMX metrics: https://docs.microsoft.com/en-us/azure/azure-monitor/app/java-get-started#performance-counters.  You will need an ApplicationInsights.XML file: https://github.com/Microsoft/ApplicationInsights-Java/wiki/ApplicationInsights.XML.  You probably need to upload this to DBFS and then copy in the appinsights_logging_init.sh to the cluster.  I have not yet tested this setup.
