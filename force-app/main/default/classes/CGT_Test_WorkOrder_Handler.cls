/********************************************************************************************************
* @Author         ext.chandrakanth.reddy@cargotec.com
* @Description    Test class for  CGT_WorkOrder_Handler.
* @CreatedDate    04-11-2018

*********************************************************************************************************/
@isTest(seeAllData = false)
private class CGT_Test_WorkOrder_Handler {

  static  /* testMethod */  void test_workorderValidation() {
		WorkOrder wo_ins = CGT_TestDataCreation.createWorkOrder_TestData2(true);
        ServiceTerritory st = CGT_TestDataCreation.createServiceTerritory_TestData1(true,wo_ins.ServiceTerritoryId);
        ServiceAppointment sa = CGT_TestDataCreation.createServiceAppointment_TestData(st,wo_ins); 
        
        WorkOrderLineItem woli= [Select Id, 
                                        WorkOrderId
                                         from WorkOrderLineItem 
                                         where Id = :sa.ParentRecordId  Limit 1];


         WorkOrder wo =[Select Id,
                               Status
                               from 
                               WorkOrder
                               where Id = : woli.WorkOrderId];


         wo.Status='Closed';

         try{
           update wo;
         }catch(Exception e){
           System.assert(e.getMessage().contains(System.label.CGT_WO_Cannot_Close_SA_Open));
         }

  } 

  static testMethod void Test_updateCase_ClosedWO() {
        Test.startTest();
        //Case cs = CGT_TestDataCreation.createCase_TestData(true);        
        WorkOrder wo_ins = CGT_TestDataCreation.createWorkOrder_TestData(true);
        CGT_Job_Briefing__c jb= CGT_TestDataCreation.createJobBriefing_TestData();
        List<ServiceAppointment> sa = [select id from ServiceAppointment];

        delete sa;

         
         WorkOrder wo =[Select Id,
                               Status,
                               CGT_Job_Briefing__c,
                               CGT_Service_Report_Status__c,
                               CaseId
                               from 
                               WorkOrder
                               Limit 1];

         System.debug('wo: '+wo);
         wo.Status='Closed';
         wo.CGT_Job_Briefing__c=jb.id;
         
           update wo;
        
       

         WorkOrder wo1 =[Select Id,
                               Status,
                               CGT_Job_Briefing__c,
                               CGT_Service_Report_Status__c,
                               CaseId
                               from 
                               WorkOrder
                               Limit 1];

         Case cse= [Select id, 
                             CGT_TF_WO_Closed__c 
                             from Case 
                             where Id = : wo1.CaseId ];

         System.debug('cse :'+cse);

        System.assertEquals(cse.CGT_TF_WO_Closed__c ,True);
        Test.stopTest();

  }  
  
    static testMethod void Test_woli_StartDate_EndDate() {
        Test.startTest();  
        WorkOrder wo_ins = CGT_TestDataCreation.createWorkOrder_TestData(true);
        ServiceTerritory st = CGT_TestDataCreation.createServiceTerritory_TestData1(true,wo_ins.ServiceTerritoryId);
        CGT_WorkOrderLineItem_Handler.notFirstWoli = true;
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId=wo_ins.Id;
        woli.StartDate=DateTime.Now();
        woli.EndDate=null;
        woli.Duration = 48;
        woli.ServiceTerritoryId =st.Id;
        insert woli;
        Test.stopTest();
        
    } 
    static testMethod void Test_woli_NullStartDate() {
        Test.startTest();  
        WorkOrder wo_ins = CGT_TestDataCreation.createWorkOrder_TestData(true);
        ServiceTerritory st = CGT_TestDataCreation.createServiceTerritory_TestData1(true,wo_ins.ServiceTerritoryId);
        CGT_WorkOrderLineItem_Handler.notFirstWoli = true;
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId=wo_ins.Id;
        woli.StartDate=null;
        woli.EndDate=null;
        woli.Duration = 48;
        woli.ServiceTerritoryId =st.Id;
        insert woli;
        Test.stopTest();
        
    }
    
     static testMethod void Test_woli_StartDate_Minutes() {
        WorkOrder wo_ins = CGT_TestDataCreation.createWorkOrder_TestData(true);
        WorkOrder wo =[Select Id,
                               Status,startDate,
                               EndDate,
                               DurationType,
                               CGT_Service_Report_Status__c,
                               CaseId
                               from 
                               WorkOrder
                               Limit 1];    
            
            wo.DurationType = 'Minutes';
            wo.StartDate = System.today();
            wo.Duration = 14400;
           update wo;
        ServiceTerritory st = CGT_TestDataCreation.createServiceTerritory_TestData1(true,wo_ins.ServiceTerritoryId);
        Test.startTest();
        CGT_WorkOrderLineItem_Handler.notfirstWoli = true;
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId=wo.Id;
        woli.DurationType = 'Minutes';
        woli.StartDate=System.today().addDays(2);
        woli.EndDate=null;
        woli.Duration = 1440;
        woli.ServiceTerritoryId =st.Id;
        insert woli;
        Test.stopTest();
        
    } 
    /*static testMethod void Test_SM02_woli_fields() {
        WorkOrder wo_ins = CGT_TestDataCreation.createWorkOrder_TestData2(true);
        ServiceTerritory st = CGT_TestDataCreation.createServiceTerritory_TestData1(true,wo_ins.ServiceTerritoryId);
        WorkOrderLineItem woli = CGT_TestDataCreation.createWorkOrderLineItem_TestData2(st, wo_ins);
        WorkOrder wo =[Select Id,
                               Status,startDate,
                               EndDate,
                               DurationType,
                               CGT_Service_Report_Status__c,
                               CaseId
                               from 
                               WorkOrder
                               Limit 1];    
        Test.startTest();    
        wo.Status = 'Submitted' ;
        update wo;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.stopTest();
        
    } */
}