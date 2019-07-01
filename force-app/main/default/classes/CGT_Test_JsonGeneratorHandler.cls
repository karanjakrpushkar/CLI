/********************************************************************************************************
* @Author         
* @Description    Test class for  CGT_JsonGeneratorHandler.
* @CreatedDate    22-06-2018

*********************************************************************************************************/
@isTest(seeAllData = false)
public class CGT_Test_JsonGeneratorHandler {

/********************************************************************************************************
* @author        
* @description   This method will verify the CGT_JsonGeneratorHandler   test coverage.  
* @Paramters     none
* @return        none
*********************************************************************************************************/
    static testMethod void Test_createIntMessageWithJsonPayload(){
        WorkOrder wo_inst = CGT_TestDataCreation.createWorkOrder_TestData(true);
        ServiceTerritory st1 = CGT_TestDataCreation.createServiceTerritory_TestData1(true,wo_inst.serviceterritoryId);
        WorkOrderlineItem woli1 = CGT_TestDataCreation.createWorkOrderLineItem_TestData2(st1,wo_inst);
        List<Workorder> woList=[select Id,CGT_External_Id__c from WorkOrder ];
        List<String> woIntList=new List<String>();
        String WOId='';
        for(WorkOrder wo : woList){
            woIntList.add('WOCREATE:'+wo.Id);
            WOId=wo.Id;
        }
          
        if(! woIntList.isEmpty())
        CGT_JsonGeneratorHandler.createIntMessageWithJsonPayload(woIntList);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        List<EVT_Integration_Message__c> integrationMessage= [select Id,
                                                                    EVT_Event_Type__c,
                                                                    EVT_Record_To_Integrate__c 
                                                              from  EVT_Integration_Message__c 
                                                             ];
        system.assertNotEquals(0,integrationMessage.size());


    }
    
 }