/*
 @Name : CGT_Test_BatchCreateTimeSheet
 @Description : This test class will do the code coverage for the classes 'CGT_BatchCreateTimeSheet' and 
                'CGT_ScheduleBatchCreateTimeSheet'.
 @Developed by : ext.Leo.Johnson@cargotec.com
 @Created date : 27/11/2017

 @Last Modified : ext.manoj.gupta@cargotec.com
 @Date          : 24/11/2018
 @Reason        : check for resource personnel number was replaced by its ExternalId

*/

@isTest
private class CGT_Test_BatchCreateTimeSheet {
     
    //This method will cover the class CGT_BatchCreateTimeSheet
    static testMethod void myTestBatch() {
               
        
        User user_rec= CGT_TestDataCreation.create_User(true);        
        System.runAs (user_rec){
            ServiceResource sr = new ServiceResource(Name='Name99',ResourceType='T',RelatedRecordId=user_rec.id,IsActive=true ,CGT_External_ID__c='101' );
            insert sr;
                   
            List<ServiceResource> srList = new List<ServiceResource>();
            srList.add(sr);
            List<TimeSheet> tsList = new List<TimeSheet>();  

            Date sd = date.today();
            Date ed = date.today();
            String extid   = sr.CGT_External_ID__c;
            Date dateInst=sd;
            String datestring = String.valueof(dateInst.day())+String.valueof(dateInst.month())+String.valueof(dateInst.year());   
            
            TimeSheet ts = new TimeSheet(ServiceResourceId=sr.id,StartDate = sd,EndDate = ed,CGT_External_ID__c=extid+datestring);       
            tsList.add(ts);        
            insert tsList;
            
            CGT_TimeSheet_Instance_data__mdt tsid = new CGT_TimeSheet_Instance_data__mdt();
            Decimal timesheet_entries = tsid.CGT_Number__c;  
                   
            CGT_BatchCreateTimeSheet batchc = new CGT_BatchCreateTimeSheet();
            database.executeBatch(batchc);
        }
                                                              
    }
      
    //This method will cover the class CGT_ScheduleBatchCreateTimeSheet
    static testMethod void myTestSchedule(){
        String CRON_EXP = '0 0 0 15 3 ? *';    
        CGT_ScheduleBatchCreateTimeSheet sbct = new CGT_ScheduleBatchCreateTimeSheet();                
        Test.startTest();
            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, sbct);
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
}