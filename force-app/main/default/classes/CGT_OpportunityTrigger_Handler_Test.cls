@isTest(seeAllData=false)

/*
    @Author: Tieto
    @Class Name: CGT_OpportunityTrigger_Handler_Test
    @Created Date: 2nd August 2018
    @Description: This class is used to test the functionality of creating Opportunity vessel nodes if a new Shipyard Project Opportunity is created
     or the shipyard project of an existing Opportunity is updated.
*/

public class CGT_OpportunityTrigger_Handler_Test {

    /*
        @Author: Tieto
        @Method Name: createRecords
        @Description: This method is used for creating dummy records for the class for testing purpose.
    */
    
    @testSetup
    public static void createRecords() {
        Account accObj = new Account();
        accObj.name = 'Test Account';
        accObj.CGT_Account_Group__c = 'C021';
        accObj.Type = 'Other';
        insert accObj;
        
        CGT_Shipyard_Project__c shipyardObj1 = new CGT_Shipyard_Project__c();
        shipyardObj1.name = 'Test Shipyard1';
        shipyardObj1.CGT_Ship_Owner__c = accObj.id;
        shipyardObj1.CGT_Shipyard_Builder__c = accObj.id;
        shipyardObj1.CGT_Closing_Date__c = System.today();
        shipyardObj1.CGT_Project_Status__c = 'Lead';
        shipyardObj1.CGT_Vessel_Type__c = 'Bulk Carrier';
        insert shipyardObj1;
        
        CGT_Shipyard_Project__c shipyardObj2 = new CGT_Shipyard_Project__c();
        shipyardObj2.name = 'Test Shipyard2';
        shipyardObj2.CGT_Ship_Owner__c = accObj.id;
        shipyardObj2.CGT_Shipyard_Builder__c = accObj.id;
        shipyardObj2.CGT_Closing_Date__c = System.today();
        shipyardObj2.CGT_Project_Status__c = 'Lead';
        shipyardObj2.CGT_Vessel_Type__c = 'Bulk Carrier';
        insert shipyardObj2;
        
        List<CGT_Vessel_Node_Shipyard_Project__c> vesselNodeList = new List<CGT_Vessel_Node_Shipyard_Project__c>();
        for(Integer i = 0;i<3;i++) {
            CGT_Vessel_Node_Shipyard_Project__c obj = new CGT_Vessel_Node_Shipyard_Project__c();
            obj.CGT_V_Ship_Delivery_Date__c = System.today();
            obj.CGT_V_Hull_Number__c = '3';
            obj.CGT_Shipyard_Project__c = shipyardObj1.id;
            vesselNodeList.add(obj);
        }
        for(Integer i = 0;i<3;i++) {
            CGT_Vessel_Node_Shipyard_Project__c obj = new CGT_Vessel_Node_Shipyard_Project__c();
            obj.CGT_V_Ship_Delivery_Date__c = System.today();
            obj.CGT_V_Hull_Number__c = '3';
            obj.CGT_Shipyard_Project__c = shipyardObj2.id;
            vesselNodeList.add(obj);
        }
        insert vesselNodeList;
    }
    
    /*
        @Author: Tieto
        @Method Name: OpportunityVesselNode_Test
        @Description: This method is used for creating opportunity with a shipyard project and 
         then updating the shipyard project to test the vessel node creation functionality.
    */
    
    public static testMethod void OpportunityVesselNode_Test() {
        
        CGT_Shipyard_Project__c shipyardObj1 = [SELECT id FROM CGT_Shipyard_Project__c WHERE name='Test Shipyard1' limit 1];
        CGT_Shipyard_Project__c shipyardObj2 = [SELECT id FROM CGT_Shipyard_Project__c WHERE name='Test Shipyard2' limit 1];
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        
        Opportunity opportunityObj = new Opportunity();
        opportunityObj.name = 'Test Opportunity';
        opportunityObj.CloseDate = System.today().addDays(2);
        opportunityObj.CGT_Opportunity_Segment_main__c = 'Offshore';
        opportunityObj.StageName = 'Budget Quote';
        opportunityObj.CGT_Shipyard_Project__c = shipyardObj1.id;
        opportunityObj.Probability= 5;
        opportunityList.add(opportunityObj);
        
        insert opportunityList;
        
        CGT_OpportunityTrigger_Handler.createOpportunityVesselNodes(opportunityList);
        
        List<CGT_Vessel_Node_Opportunity__c> tmpList1 = [SELECT id FROM CGT_Vessel_Node_Opportunity__c WHERE CGT_Opportunity__r.CGT_Shipyard_Project__c =: shipyardObj1.id];
        System.assert(tmpList1.size()>1);
        
        for(Opportunity oppObj : opportunityList) {
            oppObj.CGT_Shipyard_Project__c = shipyardObj2.id;
        }
        update opportunityList;
        
        CGT_OpportunityTrigger_Handler.createOpportunityVesselNodes(opportunityList);
        
        List<CGT_Vessel_Node_Opportunity__c> tmpList2 = [SELECT id FROM CGT_Vessel_Node_Opportunity__c WHERE CGT_Opportunity__r.CGT_Shipyard_Project__c =: shipyardObj2.id];
        System.assert(tmpList2.size()>1);
    }
    
    /*
        @Author: Tieto
        @Method Name: shipOwnerCounters_Test
        @Description: This method is used for testing the updates of the Open Opportunities (Shipowner) and Won Opportunities (Shipowner) fields of the Shipowner of Opportunity.
    */
    
    public static testMethod void shipOwnerCounters_Test() {
        
        CGT_Shipyard_Project__c shipyardObj = [SELECT id FROM CGT_Shipyard_Project__c WHERE name='Test Shipyard1' limit 1];
        
        List<Id> accList = new List<Id>();
        
        Account accObj = [select id from Account where name = 'Test Account' limit 1];
        
        accList.add(accObj.id);
        
        Opportunity opportunityObj = new Opportunity();
        opportunityObj.name = 'Test Opportunity 1';
        opportunityObj.CloseDate = System.today().addDays(2);
        opportunityObj.CGT_Opportunity_Segment_main__c = 'Offshore';
        opportunityObj.StageName = 'New / No Enquiry';
        opportunityObj.CGT_Shipyard_Project__c = shipyardObj.id;
        opportunityObj.Probability= 5;
        insert opportunityObj;
        
        CGT_OpportunityTrigger_Handler.manageOpenOppCounter(accList,'Add');
        CGT_OpportunityTrigger_Handler.manageOpenOppCounter(accList,'Reduce');
        
        opportunityObj.StageName = 'Closed Won';
        opportunityObj.Loss_Reason__c = 'Good relation to owner';
        update opportunityObj;
        
        CGT_OpportunityTrigger_Handler.manageClosedOppCounter(accList,'Add');
        CGT_OpportunityTrigger_Handler.manageClosedOppCounter(accList,'Reduce');
        
    }
    
}