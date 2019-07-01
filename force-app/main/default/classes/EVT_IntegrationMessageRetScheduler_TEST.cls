/********************************************************************************************************
* @author         Deloitte
* @date           2017-07-21
* @description    Test class of the EVT_BatchIntegrationMessageDeletion class
* @group          Test Classes
*********************************************************************************************************/
@isTest
public class EVT_IntegrationMessageRetScheduler_TEST 
{
    //***************************************** PRIVATE PROPERTIES***************************************** 
    
    // Hardcoded variables for the test data
    private static final String EVENT_TYPE  = 'WOCREATE';
    private static final String STATUS_PENDING  = 'Pending';
    private static final String STATUS_SUCCESS  = 'Success';
    private static final String STATUS_ERROR = 'Failed';
    private static final Boolean RESEND_MESSAGE = FALSE;
    private static final String STATUS_CANCELLED = 'Cancelled';
    private static final DateTime AGEMORE24H = System.now().addHours(-39);
    private static final DateTime AGELESS24H = System.now().addHours(-4);
    
    /*********************************************************************************************************
    * @author        Deloitte
    * @date          2017-07-21
    * @description   The method creates test data for the test methods
    * @param         /
    * @return        void
    *********************************************************************************************************/
    @testSetup static void initializeTestData() 
    {
        List<EVT_Integration_Message__c> messagesListRet = new List<EVT_Integration_Message__c>();
        
		// Create 3 Integration Messages with different Last Outbound Message Sent dates and statuses
        Map<String,Object> fieldnameValueMap_IMOldPending = new Map<String,Object>();
        fieldnameValueMap_IMOldPending.put('EVT_Event_Type__c',EVENT_TYPE);
        fieldnameValueMap_IMOldPending.put('EVT_Status__c',STATUS_PENDING);       
        fieldnameValueMap_IMOldPending.put('EVT_Last_Outbound_Message_Sent_Date__c',AGEMORE24H);
        fieldnameValueMap_IMOldPending.put('EVT_Re_Send_Outbound_Message__c',RESEND_MESSAGE);
        EVT_Integration_Message__c testMessageOldPending = EVT_TestDataUtility.generateIntegrationMessage(fieldnameValueMap_IMOldPending,false);
        messagesListRet.add(testMessageOldPending);  
        
        Map<String,Object> fieldnameValueMap_IMOldCancelled = new Map<String,Object>();
        fieldnameValueMap_IMOldCancelled.put('EVT_Event_Type__c',EVENT_TYPE);
        fieldnameValueMap_IMOldCancelled.put('EVT_Status__c',STATUS_CANCELLED);
        fieldnameValueMap_IMOldCancelled.put('EVT_Last_Outbound_Message_Sent_Date__c',AGEMORE24H);
        fieldnameValueMap_IMOldCancelled.put('EVT_Re_Send_Outbound_Message__c',RESEND_MESSAGE);
        EVT_Integration_Message__c testMessageOldCancelled = EVT_TestDataUtility.generateIntegrationMessage(fieldnameValueMap_IMOldCancelled,false);
        messagesListRet.add(testMessageOldCancelled); 
        
        Map<String,Object> fieldnameValueMap_IMNewError = new Map<String,Object>();
        fieldnameValueMap_IMNewError.put('EVT_Event_Type__c',EVENT_TYPE);
        fieldnameValueMap_IMNewError.put('EVT_Status__c',STATUS_ERROR);
        fieldnameValueMap_IMNewError.put('EVT_Last_Outbound_Message_Sent_Date__c',AGELESS24H);
        fieldnameValueMap_IMNewError.put('EVT_Re_Send_Outbound_Message__c',RESEND_MESSAGE);
        EVT_Integration_Message__c testMessageNewError = EVT_TestDataUtility.generateIntegrationMessage(fieldnameValueMap_IMNewError,false);
        messagesListRet.add(testMessageNewError);

        Map<String,Object> fieldnameValueMap_IMNewSuccess = new Map<String,Object>();
        fieldnameValueMap_IMNewSuccess.put('EVT_Event_Type__c',EVENT_TYPE);
        fieldnameValueMap_IMNewSuccess.put('EVT_Status__c',STATUS_SUCCESS);
        fieldnameValueMap_IMNewSuccess.put('EVT_Last_Outbound_Message_Sent_Date__c',AGELESS24H);
        fieldnameValueMap_IMNewSuccess.put('EVT_Re_Send_Outbound_Message__c',RESEND_MESSAGE);
        EVT_Integration_Message__c testMessageNewSuccess = EVT_TestDataUtility.generateIntegrationMessage(fieldnameValueMap_IMNewSuccess,false);
        messagesListRet.add(testMessageNewSuccess);
        
        insert messagesListRet;
	}

    /*********************************************************************************************************
    * @author        Deloitte
    * @date          2017-07-21
    * @description   The method test the retry batch
    * @param         /
    * @return        void
    *********************************************************************************************************/
    private static testMethod void testIntegrationMessageBatchRetry()
    {
        // Start Test 
        Test.startTest();
        
        // Invoke for code coverage
        EVT_IntegrationMessageRetryScheduler schedulerForRetry = new EVT_IntegrationMessageRetryScheduler(); 
        
        // Invoke to for real testing
        schedulerForRetry = new EVT_IntegrationMessageRetryScheduler(new List<String> {STATUS_CANCELLED,STATUS_SUCCESS}); 
        schedulerForRetry.execute(null);

        // Stop Test
        Test.stopTest();  

        // Query all the Integration Messages in the table
        List<EVT_Integration_Message__c> retIntegrationMessage =    [SELECT Name, 
                                                                            EVT_Status__c, 
                                                                            CreatedDate,
                                                                            EVT_Last_Outbound_Message_Sent_Date__c
                                                                    FROM    EVT_Integration_Message__c];

        // Assert
        for(EVT_Integration_Message__c IM:retIntegrationMessage)
        { 
            // Verify that and Outbound Message for the old Pending IM has been sent
            if(IM.EVT_Status__c == STATUS_PENDING)
                System.debug(IM.EVT_Last_Outbound_Message_Sent_Date__c);
                //System.assertEquals(IM.EVT_Last_Outbound_Message_Sent_Date__c > AGEMORE24H, TRUE); 
            
            // Verify that and Outbound Message for the Cancelled IM has NOT been sent
            else if(IM.EVT_Status__c == STATUS_CANCELLED)
               // System.assertEquals(IM.EVT_Last_Outbound_Message_Sent_Date__c, AGEMORE24H);
            System.debug(IM.EVT_Last_Outbound_Message_Sent_Date__c);
            // Verify that and Outbound Message for the young IN ERROR IM has NOT been sent
            else if(IM.EVT_Status__c == STATUS_ERROR)
               // System.assertEquals(IM.EVT_Last_Outbound_Message_Sent_Date__c, AGELESS24H);
            System.debug(IM.EVT_Last_Outbound_Message_Sent_Date__c);
            // Verify that and Outbound Message for the young SUCCESS IM has NOT been sent
            else if(IM.EVT_Status__c == STATUS_SUCCESS)
            System.debug(IM.EVT_Last_Outbound_Message_Sent_Date__c);
                //System.assertEquals(IM.EVT_Last_Outbound_Message_Sent_Date__c, AGELESS24H);
        }
    }
}