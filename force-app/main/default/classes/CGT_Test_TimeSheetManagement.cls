/********************************************************************************************************
* @author         Deloitte
* @description    Test class for the Time Sheet Management Class
* @date           2018-04-05
* @Last Update    2018-06-05
* @group          Time Sheet
*********************************************************************************************************/
@isTest
public class CGT_Test_TimeSheetManagement{

    public static testMethod void test_beforeInsertTSEFieldUpdates()
    {
        User user_rec= CGT_TestDataCreation.create_User(true); 
        
        ServiceResource sr = new ServiceResource(Name='Name99',ResourceType='T',RelatedRecordId=user_rec.id,IsActive=true ,CGT_External_ID__c='101' );
        insert sr;
        
        Date sd = CGT_FSM_Utility.timeSheetStartDate(System.Today().addDays(-6));
        Date ed = sd.addDays(6);
        Date sd1 = CGT_FSM_Utility.timeSheetStartDate(System.Today());
        system.debug('sd1'+sd1);
        Date ed1 = sd1.addDays(6);
        system.debug('ed1'+ed1);

        TimeSheet ts = new TimeSheet(ServiceResourceId=sr.id,StartDate = sd,EndDate = ed,CGT_External_ID__c='temp');       
        insert ts;
        TimeSheet ts1 = new TimeSheet(ServiceResourceId=sr.id,StartDate = sd1,EndDate = ed1,CGT_External_ID__c='temp1');       
        insert ts1;
         
         WorkOrder wo = CGT_TestDataCreation.createWorkOrder_TestData(true);
         ServiceTerritory st1 = CGT_TestDataCreation.createServiceTerritory_TestData1(true,wo.serviceTerritoryId);
         WorkOrderlineItem woli1 = CGT_TestDataCreation.createWorkOrderLineItem_TestData2(st1,wo);
         ServiceAppointment sa = CGT_TestDataCreation.createServiceAppointment_TestData(st1,wo);
        ServiceTerritoryMember stm = new ServiceTerritoryMember();
        stm.ServiceResourceId = sr.Id;
        stm.ServiceTerritoryId = st1.Id;
        stm.TerritoryType = 'P';
        stm.EffectiveStartDate=sd.addDays(-5);
        insert stm;
        system.debug('stm'+stm.id);
        

        
        //List<RecordType> rtList = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType='TimesheetEntry' and DeveloperName = 'CGT_Direct'];
        Id RecTypeId = Schema.SObjectType.TimesheetEntry.getRecordTypeInfosByDeveloperName().get('CGT_Direct').getRecordTypeId();   
        Test.startTest();
        list<TimeSheetEntry> tselst=new list<TimeSheetEntry>();
        
        TimeSheetEntry tse1 = new TimeSheetEntry();
        tse1.StartTime = datetime.now().addHours(2);
        tse1.Endtime = datetime.now().addHours(3);
        tse1.CGT_Service_Resource_Name__c = sr.Id;
        tse1.Status='New';
        tse1.CGT_IS_Delete__c=true;
        tse1.WorkOrderLineItemId = woli1.Id;
        tse1.recordtypeId = RecTypeId;
        tselst.add(tse1);
        String Day = datetime.now().format('EEEE');
        String CloneDays;
        if(Day == 'Monday'){
            CloneDays = 'Tuesday;Wednesday;Thursday;Friday;Saturday';
        }else if (Day == 'Tuesday'){
            CloneDays = 'Monday;Wednesday;Thursday;Friday;Saturday';
        }else if (Day == 'Wednesday'){
            CloneDays = 'Monday;Tuesday;Thursday;Friday;Saturday';
        }else if (Day == 'Thursday'){
            CloneDays = 'Monday;Tuesday;Wednesday;Friday;Saturday';
        }else if (Day == 'Friday'){
            CloneDays = 'Monday;Tuesday;Wednesday;Thursday;Saturday';
        }else if (Day == 'Saturday'){
            CloneDays = 'Monday;Tuesday;Wednesday;Thursday;Friday';
        }
        CGT_Activity_Type_Grouping__c acti  = new CGT_Activity_Type_Grouping__c();
        acti.CGT_Activity_Type__c = 'L110';
        acti.CGT_Activity_Type_Group__c = 'test';
        acti.Name = 'Testing';
        acti.CGT_External_ID__c = 'Test012';
        insert acti;
        
        TimeSheetEntry tse = new TimeSheetEntry();
        Date startdate = CGT_FSM_Utility.timeSheetStartDate(System.Today().addDays(-6));
        DateTime tseStartTime = DateTime.newInstance(startDate, datetime.now().Time());
        tse.StartTime = tseStartTime.addDays(6);
        tse.Endtime =   tse.StartTime.addHours(3);
        tse.WorkOrderLineItemId = woli1.Id;
        tse.CGT_Service_Resource_Name__c= sr.Id;
        tse.Clone_for_Days__c = CloneDays;
        tse.recordtypeId = RecTypeId;
         
        tselst.add(tse);
        
  
        //try{
            insert tselst;
            //CGT_TimeSheetManagement.cloneTimeSheetEntries(tselst);
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            tse1.CGT_Is_Delete__c = true;
            tse1.CGT_External_Id__c = null;
            tse1.CGT_Integration_Message__c = null;
            update tse1;
       /* }
        catch(Exception e)
        {

        }*/
        Test.stopTest();
        system.assertEquals(woli1.Id,tse.WorkOrderLineItemId);
        }
    
   
}