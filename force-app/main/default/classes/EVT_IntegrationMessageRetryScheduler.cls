/********************************************************************************************************
* @author         Deloitte
* @date           2017-07-21
* @description    Schedulable Class scheduling the Batch Integration Message job for the retry  mechanism
* @group          Integration Message
*********************************************************************************************************/
global class EVT_IntegrationMessageRetryScheduler implements Schedulable
{
    //***************************************** PUBLIC PROPERTIES*****************************************
    
    // List of statuses to exclude in the SOQL query for the test class
    private List<String> statusesToExclude;
    
    
    //***************************************** PUBLIC METHODS ***************************************** 
    
    /********************************************************************************************************
    * @author       Deloitte
    * @date         2017-07-21
    * @description  Constructor to define the parameters of the class based on the Custom Metadata
    * @param        /
    * @return       void
    *********************************************************************************************************/
    public EVT_IntegrationMessageRetryScheduler()
    {
        // Query the Custom Metadata containing the parameters for the batch SOQL
        EVT_Integration_Message_Parameters__mdt mdtRetry = [SELECT EVT_Status_To_Exclude_For_Retry__c FROM EVT_Integration_Message_Parameters__mdt LIMIT 1];
        
        // Parse the custom metada representing the statuses to exclude for deletion in a list of Strings
        if (mdtRetry.EVT_Status_To_Exclude_For_Retry__c != null)
                statusesToExclude = mdtRetry.EVT_Status_To_Exclude_For_Retry__c.split(';');
    }
    
    /********************************************************************************************************
    * @author       Deloitte
    * @date         2017-07-21
    * @description  Constructor to define the parameters of the class, with a parameter to explicitly 
    * 				specify the list of statuses to exclude (method used for test classes)
    * @param        List<String> statusesToExclude : list of statuses to exclude for the retry mechanism
    * @return       void
    *********************************************************************************************************/
    public EVT_IntegrationMessageRetryScheduler(List<String> statusesToExclude)
    {
        this.statusesToExclude = statusesToExclude;
    }
    
    /********************************************************************************************************
    * @author       Deloitte
    * @date         2017-07-21
    * @description  Implementation of the execute method from Schedulable class. Executes the batch job for the retry mechanism
    * @param        SchedulableContext sc : the Context of the Schedulable class
    * @return       void
    *********************************************************************************************************/
    global void execute(SchedulableContext sc) 
    {          
        // Execute Batch Class
        Database.executeBatch(new EVT_BatchIntegrationMessageRetry(statusesToExclude),200);
    }
}