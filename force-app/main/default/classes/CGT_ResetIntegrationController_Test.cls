/********************************************************************************************************
* @author         Prince Kumar
* @date           12-01-2018
* @description    Test class of the CGT_ResetIntegrationController class
*********************************************************************************************************/
@isTest
private class CGT_ResetIntegrationController_Test {
           
  /*********************************************************************************************************
  * @author         Prince Kumar
  * @date           12-01-2018
    * @description    Test the integration message field update on Timesheet
    * @param         null
    * @return        void
    *********************************************************************************************************/
    private static testMethod void testresetIntegrationMessageFields(){
        
       // User user_rec= CGT_TestDataCreation.create_User(true);        
           
    ServiceResource sr = new ServiceResource(Name='Name99',ResourceType='T',RelatedRecordId=UserInfo.getuserId(),IsActive=true , CGT_Personnel_Number__c=101 );
    insert sr;
               
    List<ServiceResource> srList = new List<ServiceResource>();
    srList.add(sr);
    List<TimeSheet> tsList = new List<TimeSheet>();  

        Date startDate = date.today();
    Date endDate = date.today();
        Decimal pn = sr.CGT_Personnel_Number__c;
    Integer pernum = Integer.valueOf(pn);
    String personnel_num = String.valueOf(pernum);
        Date dateInst=startDate;
        String datestring = String.valueof(dateInst.day())+String.valueof(dateInst.month())+String.valueof(dateInst.year());   
        
        TimeSheet ts = new TimeSheet(OwnerId=UserInfo.getuserId(),ServiceResourceId=sr.id,StartDate = startDate,EndDate = endDate,CGT_External_ID__c=personnel_num+datestring);       
        tsList.add(ts);        
        insert tsList;
        List<RecordType> rtList = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType='TimesheetEntry' and DeveloperName = 'CGT_Direct'];
        TimeSheetEntry tse= new TimeSheetEntry(TimesheetId=tsList[0].Id,StartTime=System.Now(),EndTime=System.Now().addHours(2),CGT_Integration_Message__c='Error',
        RecordTypeId = rtList[0].Id,type = 'Direct');
    insert tse;
    Boolean status;
    //start test
       // Test.startTest();
        List<TimeSheetEntry> tseList=[Select Id,TimesheetId from TimeSheetEntry];
    String sObjectNameId='TimeSheetEntry : '+tseList[0].Id;
    status =CGT_ResetIntegrationController.resetIntegrationMessageFields(sObjectNameId);
        // Stop Test
       // Test.stopTest();
        System.assertEquals(False,status);
    }
    
    private static testMethod void resetQuoteIntegrationMessageFields(){
        WorkOrder wo = CGT_TestDataCreation.createWorkOrder_TestData(true);
        wo.CGT_Integration_Message__c = 'Testing';
        update wo;
        String message = CGT_ResetIntegrationController.resetQuoteIntegrationMessageFields(wo.Id);
        System.assertEquals(Message,'You can not create an Estimate/Quote for a non-integrated Work Order');

    }
    private static testMethod void resetQuoteIntegrationMessageFields2(){
            WorkOrder wo = CGT_TestDataCreation.createWorkOrder_TestData(true);
            wo.CGT_Integration_Message__c = null;
            wo.CGT_External_ID__c = '123123214';
            wo.CGT_Synchronize__c = true;
            wo.CGT_Quotation_Integration_Message__c = 'TestError';
            wo.CGT_Estimate_Quote_External_Id__c = '12345';
            update wo;
        //test.startTest();
        String message2 = CGT_ResetIntegrationController.resetQuoteIntegrationMessageFields(wo.Id);
        System.assertEquals(message2,'You can create only one Estimate/Quote for a Work Order');
            
    }
}