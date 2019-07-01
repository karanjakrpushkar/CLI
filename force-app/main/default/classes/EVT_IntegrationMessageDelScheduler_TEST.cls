/********************************************************************************************************
* @author         Deloitte
* @date           2017-07-21
* @description    Test class of the EVT_BatchIntegrationMessageDeletion class
* @group          Test Classes
*********************************************************************************************************/
@isTest
public class EVT_IntegrationMessageDelScheduler_TEST 
{
    //***************************************** PRIVATE PROPERTIES***************************************** 
    
    // Hardcoded values for test data
    private static final String EVENT_TYPE  = 'I01 - First Integration Flow';
    private static final String STATUS_PENDING  = 'Pending';
    private static final String STATUS_ERROR = 'In Error';
    private static final String STATUS_CANCELLED  = 'Cancelled';
    private static final String STATUS_SUCCESS  = 'Success';
    private static final Boolean RESEND_MESSAGE  = FALSE;
    private static final Integer DAYS_MINUS = -1;
   
    /*********************************************************************************************************
    * @author        Deloitte
    * @date          2017-07-21
    * @description   The method creates test data for the test methods
    * @param         /
    * @return        void
    *********************************************************************************************************/
    @testSetup static void initializeTestData() 
    {
        List<EVT_Integration_Message__c> messagesListDel = new List<EVT_Integration_Message__c>();
        
        // Create 3 Integration Messages with different statuses
        Map<String,Object> fieldnameValueMap_IMPending = new Map<String,Object>();
        fieldnameValueMap_IMPending.put('EVT_Event_Type__c',EVENT_TYPE);
        fieldnameValueMap_IMPending.put('EVT_Status__c',STATUS_PENDING);
		EVT_Integration_Message__c testMessagePending = EVT_TestDataUtility.generateIntegrationMessage(fieldnameValueMap_IMPending,false);
		messagesListDel.add(testMessagePending);        
        
        Map<String,Object> fieldnameValueMap_IMError = new Map<String,Object>();
        fieldnameValueMap_IMError.put('EVT_Event_Type__c',EVENT_TYPE);
        fieldnameValueMap_IMError.put('EVT_Status__c',STATUS_ERROR);
       	EVT_Integration_Message__c testMessageError = EVT_TestDataUtility.generateIntegrationMessage(fieldnameValueMap_IMError,false);
        messagesListDel.add(testMessageError);
        
        Map<String,Object> fieldnameValueMap_IMCancelled = new Map<String,Object>();
        fieldnameValueMap_IMCancelled.put('EVT_Event_Type__c',EVENT_TYPE);
        fieldnameValueMap_IMCancelled.put('EVT_Status__c',STATUS_CANCELLED);
        fieldnameValueMap_IMCancelled.put('EVT_Re_Send_Outbound_Message__c',RESEND_MESSAGE);
       	EVT_Integration_Message__c testMessageCancelled = EVT_TestDataUtility.generateIntegrationMessage(fieldnameValueMap_IMCancelled,false);
        messagesListDel.add(testMessageCancelled);
        
        Map<String,Object> fieldnameValueMap_IMSuccess = new Map<String,Object>();
        fieldnameValueMap_IMSuccess.put('EVT_Event_Type__c',EVENT_TYPE);
        fieldnameValueMap_IMSuccess.put('EVT_Status__c',STATUS_SUCCESS);
        fieldnameValueMap_IMSuccess.put('EVT_Re_Send_Outbound_Message__c',RESEND_MESSAGE);
       	EVT_Integration_Message__c testMessageSuccess = EVT_TestDataUtility.generateIntegrationMessage(fieldnameValueMap_IMSuccess,false);
        messagesListDel.add(testMessageSuccess);
        
        insert messagesListDel;
    }
           
    /*********************************************************************************************************
    * @author        Deloitte
    * @date          2017-07-21
    * @description   The method test the deletion batch
    * @param         /
    * @return        void
    *********************************************************************************************************/
	private static testMethod void testIntegrationMessageBatchDeletion() 
    {
       	// Start Test 
       	Test.startTest();
       	
        // Invoke for code coverage
       	EVT_IntegrationMessageDelScheduler schedulerForDeletion = new EVT_IntegrationMessageDelScheduler();
        
        // Invoke to for real testing
        schedulerForDeletion = new EVT_IntegrationMessageDelScheduler(new List<String> {STATUS_PENDING, STATUS_ERROR},DAYS_MINUS);
        schedulerForDeletion.execute(null);

        // Stop Test
       	Test.stopTest();  

        // Query all the Integration Messages still in the table
       	List<EVT_Integration_Message__c> retIntegrationMessage = 	[SELECT Name, 
					       													EVT_Status__c, 
					       													CreatedDate 
					       											FROM 	EVT_Integration_Message__c];
        
		// Verify that the only remainting Integration Messages in the table have the status 'Pending' or 'In Error' (all the others were deleted)
        System.assertEquals(retIntegrationMessage.size(), 2);
		for(EVT_Integration_Message__c IM:retIntegrationMessage)
		{
			System.assertEquals((IM.EVT_Status__c == STATUS_PENDING) || (IM.EVT_Status__c == STATUS_ERROR),TRUE); 
		}
	}
}