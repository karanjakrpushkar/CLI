/********************************************************************************************************
* @author         Deloitte
* @description    This class is the implementation of the Schedulable interface and allows to schedule a job in 
*				  order to delete old messages
* @date			  2015-06-26
* @group 		  Message Logs
*********************************************************************************************************/
global class LOG_DeleteLogMessagesScheduler implements Schedulable 
{
    
    // Fetch the Log Message Custom Settings in order to retrieve the Log_Purge__c
    private LOG_LogMessageSettings__c lms = LOG_LogMessageUtility.getLogSettings();
    
    /********************************************************************************************************
    * @author		Karolinski Stephane
    * @date			2015-08-17
    * @description	This method is the implementation of the Schedule interface and invokes a Batch apex in order
    * 				to delete old messages
    * @param		sc (SchedulableContext): the context of the scheduled job
    * @return		void
    *********************************************************************************************************/
    global void execute(SchedulableContext sc)
    {
        String queryString = 'SELECT  id, LOG_Age__c from LOG_LogMessage__c WHERE LOG_Age__c > ' + lms.LOG_Log_Purge__c;
        Database.executeBatch(new LOG_DeleteLogMessagesBatch(queryString), 200);
    }
}