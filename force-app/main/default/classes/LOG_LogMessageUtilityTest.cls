/********************************************************************************************************
* @author		Deloitte
* @description	This is the test class of the LOG_LogMessageUtility class
* @date			2015-06-29
* @group 		Message Logs - Test Classes
*********************************************************************************************************/
@isTest
public class LOG_LogMessageUtilityTest {  
    
  
   /********************************************************************************************************
   * @author		Karolinski Stephane
   * @date			2015-08-17
   * @description	This test method tests the getLogSettings method
   * @return		void
   *********************************************************************************************************/
   @isTest
   public static void getLogSettingsTest() 
   {         
       LOG_TestDataUtility.generateErrorMgtCustomSetting(true, false, false, true, 95);
       
       LOG_LogMessageSettings__c resultSetg = LOG_LogMessageUtility.getLogSettings();
       System.assert(resultSetg != null); 
       System.assertEquals(true, resultSetg.LOG_Debug__c); 
       System.assertEquals(true, resultSetg.LOG_Error__c); 
       System.assertEquals(false, resultSetg.LOG_Info__c); 
       System.assertEquals(false, resultSetg.LOG_Warning__c);
       System.assertEquals(95, resultSetg.LOG_Log_Purge__c); 
   }
   
   /********************************************************************************************************
   * @author		Karolinski Stephane
   * @date			2015-08-17
   * @description	This test method tests the automatic generation of the custom settings
   * @return		void
   *********************************************************************************************************/
   @isTest
   public static void insertLogSettingsTest() 
   {         
       LOG_LogMessageSettings__c setg = LOG_LogMessageUtility.insertLogSettings();       
       LOG_LogMessageSettings__c resultSetg = LOG_LogMessageUtility.getLogSettings();
       System.assert((setg != null) && (resultSetg != null)); 
       System.assertEquals(true, resultSetg.LOG_Debug__c); 
       System.assertEquals(true, resultSetg.LOG_Error__c); 
       System.assertEquals(true, resultSetg.LOG_Info__c); 
       System.assertEquals(true, resultSetg.LOG_Warning__c);
       System.assertEquals(365, resultSetg.LOG_Log_Purge__c); 
   }


   /********************************************************************************************************
   * @author		Karolinski Stephane
   * @date			2015-08-17
   * @description	This test method tests the behaviour of the different logMessage methods overload 
   * @return		void
   *********************************************************************************************************/
    @isTest
   public static void logMessageTestSuccess()   
   {  
        //build test data: Account and Contacts
       Account acc = LOG_TestDataUtility.generateAccounts(1, 'Test Account', true)[0];
	   List<Contact> contactsToLog =  LOG_TestDataUtility.generateContacts(2, 'Test Contact', acc, true);      
       
       Test.startTest();
       
       String logMessage = 'exception Message 123';
       LOG_LogMessageUtility.LOG_LogLevel logLevel = LOG_LogMessageUtility.LOG_LogLevel.Debug;
       String sourceComponent = 'sourceComponent 123';
       MyException exc = new MyException('This is an exception');
       LOG_TestDataUtility.generateErrorMgtCustomSetting(true, true, true, true, 95);
           
       List<LOG_LogMessage__c> msgToInsert = LOG_LogMessageUtility.logMessage(exc, sourceComponent, 'sourceFunction1', 'Log Message test 890', true); 
       System.assert((msgToInsert != null) && (msgToInsert.size() > 0));
       
       LOG_LogMessage__c insertedMsg = LOG_TestDataUtility.getInsertedLog(msgToInsert[0].Id);
       System.assert(insertedMsg != null);
       System.assertEquals(msgToInsert[0].LOG_Source__c, insertedMsg.LOG_Source__c);
       System.assertEquals(msgToInsert[0].LOG_Source_Function__c, insertedMsg.LOG_Source_Function__c);
       System.assertEquals('sourceFunction1', insertedMsg.LOG_Source_Function__c);
       System.assertEquals(msgToInsert[0].LOG_Message__c, insertedMsg.LOG_Message__c);
       System.assert(insertedMsg.LOG_Message__c.contains('Message: Log Message test 890'));
       System.assert(insertedMsg.LOG_Message__c.contains(exc.getMessage()));
       System.assert(insertedMsg.LOG_Stack_Trace__c != null);
       System.assertEquals(msgToInsert[0].LOG_Log_Code__c, insertedMsg.LOG_Log_Code__c);
       System.assertEquals(0, insertedMsg.LOG_Age__c);
  	   System.assertEquals(null, insertedMsg.LOG_Reference_Id__c);
       System.assertEquals(null, insertedMsg.LOG_Reference_Info__c);
       System.assertEquals(msgToInsert[0].LOG_Debug_Level__c, insertedMsg.LOG_Debug_Level__c);
       System.assertEquals('Error', insertedMsg.LOG_Debug_Level__c);
             
       List<LOG_LogMessage__c> msgToInsert3 = LOG_LogMessageUtility.logMessage(exc, sourceComponent, 'Function1()', 'test logMessage', '<xml>payLoad</xml>',  9999, true);
       System.assert((msgToInsert3 != null) && (msgToInsert3.size() > 0));
       LOG_LogMessage__c insertedMsg3 = LOG_TestDataUtility.getInsertedLog(msgToInsert3[0].Id);
       System.assert(insertedMsg3 != null);     
       System.assertEquals('<xml>payLoad</xml>', insertedMsg3.LOG_Integration_Payload__c);  
       
       LOG_LogMessage__c msgToInsert2 = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'source function()', 'logMessage', '<payLoad/>', '[stack trace]', 100, 'Ref Id 00001', '00001', 'logCode',true);  
       LOG_LogMessage__c insertedMsg2 = LOG_TestDataUtility.getInsertedLog(msgToInsert2.Id);              
       System.assert(insertedMsg2 != null);
       System.assert(!String.isBlank(insertedMsg2.LOG_Message__c));
       System.assertEquals(100, insertedMsg2.LOG_Timer__c);       
       System.assert(insertedMsg2.LOG_Stack_Trace__c != null);
       System.assertEquals(0, insertedMsg2.LOG_Age__c);
       System.assertEquals('Ref Id 00001',insertedMsg2.LOG_Reference_Id__c);
       System.assertEquals('00001', insertedMsg2.LOG_Reference_Info__c);
       System.assertEquals('Debug', insertedMsg2.LOG_Debug_Level__c);
       
       msgToInsert[0].Id = null;
       LOG_LogMessageUtility.logMessage(msgToInsert[0]);
       
       LOG_LogMessage__c msgToInsert5 = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', false); 
       System.assert(msgToInsert5.Id == null);
       msgToInsert5 = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', true); 
       System.assert(msgToInsert5.Id != null);
       LOG_LogMessage__c insertedMsg5 = LOG_TestDataUtility.getInsertedLog(msgToInsert5.Id); 
       System.assert(insertedMsg5 != null);
       System.assertEquals('Debug', insertedMsg5.LOG_Debug_Level__c);
       
      
       List<LOG_LogMessage__c> msgToInsert6 = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', 'logCode', contactsToLog, true); 
       System.assert(msgToInsert6 != null);
       System.assert(msgToInsert6.size() == 2);
       System.assert(msgToInsert6[0].LOG_Reference_Info__c.contains('Contact'));
       LOG_LogMessage__c insertedMsg6 = LOG_TestDataUtility.getInsertedLog(msgToInsert6[0].Id); 
       System.assert(insertedMsg6 != null);
       LOG_LogMessage__c insertedMsg7 = LOG_TestDataUtility.getInsertedLog(msgToInsert6[1].Id); 
       System.assert(insertedMsg7 != null);
       System.assertEquals('logCode', insertedMsg7.LOG_Log_Code__c);
       
       LOG_LogMessage__c msgToInsert8 = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', 'logCode', acc, true); 
       System.assert((msgToInsert8 != null) && (LOG_TestDataUtility.getInsertedLog(msgToInsert8.Id) != null));       
       System.assert(msgToInsert8.LOG_Reference_Info__c.contains('Account'));
       
       LOG_LogMessage__c msgToInsert9 = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', 'logCode', true); 
       System.assert((msgToInsert9 != null) && (LOG_TestDataUtility.getInsertedLog(msgToInsert9.Id) != null));
       
       LOG_LogMessage__c msgToInsert10 = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', 'logCode', '<xml>payLoad</xml>', true); 
       System.assert((msgToInsert10 != null) && (LOG_TestDataUtility.getInsertedLog(msgToInsert10.Id) != null));
       
       //test DML exception logging
       try{
           insert new Lead();
       }
       catch(DmlException dmlExc)
       {
			List<LOG_LogMessage__c> msgToInsertDml = LOG_LogMessageUtility.logMessage(dmlExc, sourceComponent, 'Function1()', 'test logMessage', '<xml>payLoad</xml>',  9999, true);
       		System.assert((msgToInsertDml != null) && (msgToInsertDml.size() > 0));   
           
            LOG_LogMessage__c insertedMsgDml = LOG_TestDataUtility.getInsertedLog(msgToInsertDml[0].Id);
       		System.assert(insertedMsgDml != null);    
            System.assert(insertedMsgDml.LOG_Message__c.contains('System.DmlException'));
            System.assert(insertedMsgDml.LOG_Log_Code__c.startsWith('REQUIRED_FIELD_MISSING'));
            System.assertEquals(insertedMsgDml.LOG_Source_Function__c, msgToInsertDml[0].LOG_Source_Function__c);
            System.assert((insertedMsgDml.LOG_Timer__c == msgToInsertDml[0].LOG_Timer__c) && (insertedMsgDml.LOG_Timer__c == 9999));
            System.assert(insertedMsgDml.LOG_Stack_Trace__c != null);
       }
       
       Test.stopTest();
       
   }
    
   /********************************************************************************************************
   * @author		Karolinski Stephane
   * @date			2015-09-25
   * @description	This test method tests the Log Queuing functionality 
   * @return		void
   *********************************************************************************************************/
    @isTest
   public static void queueLogMessageTest() 
   {
       //Queue Log Message
       LOG_LogMessageUtility.queueDMLRequests = true;
       
       //Log 2 messages
       LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'Queue Message', 'queueLogMessageTest', 'Test Log 1', true); 
       LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'Queue Message', 'queueLogMessageTest', 'Test Log 1', true); 
       
	   //Check that no message has been logged at that stage
	   List<LOG_LogMessage__c> insertedLogs = [SELECT Id FROM LOG_LogMessage__c LIMIT 5];
       System.assertEquals(0, insertedLogs.size());
       
       LOG_LogMessageUtility.commitQueuedLogsToDatabase();
       
       //Check that the 2 Logs have been inserted and that the Queue is now empty
       insertedLogs = [SELECT Id FROM LOG_LogMessage__c LIMIT 5];
       System.assertEquals(2, insertedLogs.size());
       System.assertEquals(0,LOG_LogMessageUtility.pendingLogsForUpsert.size());
       
       LOG_LogMessageUtility.queueDMLRequests = false;
   }
    
   
   /********************************************************************************************************
   * @author		Deloitte
   * @description	Defines a custom exception class used to simulate the exception logMessage method overload
   * @date			2015-06-29
   * @group 		Message Logs - Test Classes
   *********************************************************************************************************/
   private class MyException extends Exception {}

}