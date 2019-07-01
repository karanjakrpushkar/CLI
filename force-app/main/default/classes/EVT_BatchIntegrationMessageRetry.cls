/********************************************************************************************************
* @author         Deloitte
* @date           2017-07-21
* @description    Batchable Class for re-sending integration messages that failed to deliver
* @group 		  Integration Message
*********************************************************************************************************/
global class EVT_BatchIntegrationMessageRetry implements Database.Batchable<sObject>, Database.Stateful
{
    //***************************************** PRIVATE PROPERTIES*****************************************
    
    // Store the number of messages for which a retry is needed
    private Integer totalBatchSize;  
    
    // String used to query the records for which a retry is needed
    private String query;
    
    // List of statuses to ingnore for the retry
    private List<String> statusToIgnoreList; 
    
    //***************************************** PUBLIC METHODS***************************************** 
    
    /********************************************************************************************************
    * @author		Deloitte
    * @date			2017-07-21
    * @description	Executes the batch job
    * @param		statusToIgnoreList (List<String>) : the list of statuses for which the messages should not be re-sent
    * @return		void
    *********************************************************************************************************/
	global EVT_BatchIntegrationMessageRetry(List<String> statusToIgnoreList) 
	{
        this.statusToIgnoreList = statusToIgnoreList;
		query = 'SELECT Id FROM EVT_Integration_Message__c WHERE EVT_Status__c NOT IN : StatusToIgnoreList AND EVT_Message_Send_Date_Older_24__c = TRUE ORDER BY CreatedDate ASC';
	}
	
    /********************************************************************************************************
    * @author		Deloitte
    * @date			2017-07-21
    * @description	This is the implementation of the start method of the batchable interface which initializes the batch
    * 				and returns the querylocator of the SOQL query provided as input of the class constructor
    * @param		bc (database.batchableContext): the context of the batch
    * @return		database.querylocator: the query locator of the SOQL query provided as input of the class constructor
    *********************************************************************************************************/    
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		totalBatchSize = 0;
		return Database.getQueryLocator(query);
	}
	
    /********************************************************************************************************
    * @author		Deloitte
    * @date			2017-07-21
    * @description	This is the implementation of the execute method of the batchable interface which performs the
    * 				retry mechanim for records slected in the query
    * @param		recordsToRetry (List<EVT_Integration_Message__c>): the List of EVT_Integration_Message__c for which a retry should be done
    * @return		void
    *********************************************************************************************************/
   	global void execute(Database.BatchableContext BC, List<EVT_Integration_Message__c> recordsToRetry) 
   	{
		try
        { 
            // Loop through all Integration Messages to retry, and update the flag 'EVT_Re_Send_Outbound_Message__c' to trigger the sending of Outbound Messages
            for (EVT_Integration_Message__c message : recordsToRetry)
            {
                message.EVT_Re_Send_Outbound_Message__c = TRUE;
            }
            
            // Update all the Integration Messages
            update recordsToRetry;
            totalBatchSize += recordsToRetry.size();
        } 
        
        // If an error happened in the process, it will be catched and create a LOG Message
        catch(Exception e) 
        {
        	LOG_LogMessageUtility.logMessage(e,'Apex Batch - Retry To Send Integration Messages','EVT_BatchIntegrationMessageRetry.execute','Unexpected exception while retrying to send Integration Messages',true);        
        }
	}
    
	/********************************************************************************************************
    * @author		Deloitte
    * @date			2017-07-21
    * @description	This is the implementation of the finish method of the batchable interface which is logging the outcome of the batch 
    * @param		bc (database.batchableContext): the context of the batch
    * @return		void
    *********************************************************************************************************/  
	global void finish(Database.BatchableContext BC) 
	{
		LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Info,'Apex Batch - Retry To Send Integration Messages','EVT_BatchIntegrationMessageRetry.finish','Batch "Retry To Send Integration Messages" executed. Total number of messages retried: ' + totalBatchSize,true);
	}
}