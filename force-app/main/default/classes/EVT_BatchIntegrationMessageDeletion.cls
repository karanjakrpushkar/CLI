/********************************************************************************************************
* @author         Deloitte
* @date           2017-07-21
* @description    Batchable Class for deleting records from the Integration Message table 
* @group 		  Integration Message
*********************************************************************************************************/
global class EVT_BatchIntegrationMessageDeletion implements Database.Batchable<sObject>, Database.Stateful
{
    //***************************************** PRIVATE PROPERTIES*****************************************
    
	// Store the number of logs that will be deleted
    private Integer totalBatchSize;    
    
    // String used to query the records that need to be deleted
    private String query;
    
    // Declare the variables that are necessary from the Custom Metadata
    private Integer numberOfDaysBeforeDeletion; 
    private List<String> statusToIgnoreList; 

	/********************************************************************************************************
    * @author		Deloitte
    * @date			2017-07-21
    * @description	Executes the batch job
    * @param		numberOfDaysBeforeDeletion (Integer) : the number of days during which the Integration Messages should not be deleted
    * @param		statusToIgnoreList (List<String>) : the list of statuses for which the messages should not be deleted
    * @return		void
    *********************************************************************************************************/
	global EVT_BatchIntegrationMessageDeletion(Integer numberOfDaysBeforeDeletion,  List<String> statusToIgnoreList) 
	{
		// Initilaize the private state variables
		this.numberOfDaysBeforeDeletion = numberOfDaysBeforeDeletion;
		this.statusToIgnoreList = statusToIgnoreList;
		query = 'SELECT Id FROM EVT_Integration_Message__c WHERE EVT_Status__c NOT IN :statusToIgnoreList AND EVT_Age__c > :numberOfDaysBeforeDeletion';
        totalBatchSize = 0;
	}
	
	/********************************************************************************************************
    * @author		Deloitte
    * @date			2017-07-21
    * @description	This is the implementation of th start method of the batchable interface which initializes the batch
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
    * 				deletion of the Integration Messages
    * @param		recordsToDelete (List<EVT_Integration_Message__c>): the List of EVT_Integration_Message__c to be deleted
    * @return		void
    *********************************************************************************************************/
   	global void execute(Database.BatchableContext BC, List<EVT_Integration_Message__c> recordsToDelete) 
   	{
        // Try to delete the list of Integration Messages
		try
        { 
            delete recordsToDelete;
            totalBatchSize += recordsToDelete.size(); 
        } 
        
        // If an error happened in the process, it will be catched and create a LOG Message
        catch(Exception e) 
        {
        	LOG_LogMessageUtility.logMessage(e,'Apex Batch - Delete Old Integration Messages','EVT_BatchIntegrationMessageDeletion.execute','Unexpected exception while deleting Integration Messages',true);        
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
		LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Info,'Apex Batch - Delete Old Integration Messages','EVT_BatchIntegrationMessageDeletion.finish','Batch "Delete Old Integration Messages" executed. Total number of logs deleted: ' + totalBatchSize,true);
	}
}