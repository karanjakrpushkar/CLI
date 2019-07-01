/********************************************************************************************************
* @author         Deloitte
* @date           2017-07-21
* @description    Schedulable Class scheduling the Batch Integration Message job
* @group          Integration Message
*********************************************************************************************************/
global class EVT_IntegrationMessageDelScheduler implements Schedulable 
{ 
    
    //***************************************** PRIVATE PROPERTIES***************************************** 
    
    // List of statuses for which Integration Messages should not be deleted for the test class
    private List<String> statusesToExclude;
    private Integer numberOfDaysBeforeDeletion;

        
    //***************************************** PUBLIC METHODS ***************************************** 
    
    /********************************************************************************************************
    * @author       Deloitte
    * @date         2017-07-21
    * @description  Constructor to define the parameters of the class based on the Custom Metadata
    * @param        /
    * @return       void
    *********************************************************************************************************/
    public EVT_IntegrationMessageDelScheduler()
    {
        // Query the Custom Metadata containing the parameters for the batch SOQL
        EVT_Integration_Message_Parameters__mdt mdtDeletion = [SELECT EVT_Number_Of_Days_Before_Deletion__c, EVT_Status_To_Exclude_For_Deletion__c FROM EVT_Integration_Message_Parameters__mdt LIMIT 1];
    	
        // Parse the custom metada representing the statuses to exclude for deletion in a list of Strings
        if (mdtDeletion.EVT_Status_To_Exclude_For_Deletion__c != null)
                this.statusesToExclude = mdtDeletion.EVT_Status_To_Exclude_For_Deletion__c.split(';');
    	
        // TBC
        this.numberOfDaysBeforeDeletion = mdtDeletion.EVT_Number_Of_Days_Before_Deletion__c.intValue();
    }
        
    /********************************************************************************************************
    * @author       Deloitte
    * @date         2017-07-21
    * @description  Constructor to define the parameters of the class, with parameters to explicitly 
    * 				specify the class variables (method used for test classes)
    * @param        List<String> statusesToExclude : list of statuses to exclude for the deletion
    * @param  		Integer numberOfDaysBeforeDeletion : number of days after creation during which records will not be deleted
    * @return       void
    *********************************************************************************************************/
    public EVT_IntegrationMessageDelScheduler(List<String> statusesToExclude, Integer numberOfDaysBeforeDeletion)
    {
        this.statusesToExclude = statusesToExclude;
        this.numberOfDaysBeforeDeletion = numberOfDaysBeforeDeletion;
    }    
        
    /********************************************************************************************************
    * @author       Deloitte
    * @date         2017-07-21
    * @description  This method is the implementation of the Schedule interface and invokes a Batch apex in order
    *               to delete old messages
    * @param        sc (SchedulableContext): the context of the scheduled job
    * @return       void
    *********************************************************************************************************/
    global void execute(SchedulableContext sc) 
    {        
        Database.executeBatch(new EVT_BatchIntegrationMessageDeletion(numberOfDaysBeforeDeletion, statusesToExclude),200);
    }
}