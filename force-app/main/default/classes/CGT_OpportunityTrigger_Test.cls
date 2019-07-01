@isTest(seeAllData=false)

/*
    @Author: Tieto
    @Class Name: CGT_OpportunityTrigger_Test
    @Created Date: 2nd August 2018
    @Description: This class is used to test the functionality of creating Opportunity vessel nodes if a new Shipyard Project Opportunity is created
     or the shipyard project of an existing Opportunity is updated.Also the updates of Open Opportunities (Shipowner) and Won Opportunities (Shipowner) fields of the Shipowner of Opportunity.
*/

public class CGT_OpportunityTrigger_Test {

    /*
        @Author: Tieto
        @Method Name: createRecords
        @Description: This method is used for creating dummy records for the class for testing purpose.
    */
    
    @testSetup
    public static void createRecords() {
        Account accObj1 = new Account();
        accObj1.name = 'Test Account1';
        accObj1.CGT_Account_Group__c = 'C021';
        accObj1.Type = 'Other';
        insert accObj1;
        
        Account accObj2 = new Account();
        accObj2.name = 'Test Account2';
        accObj2.CGT_Account_Group__c = 'C021';
        accObj2.Type = 'Other';
        insert accObj2;
        
        CGT_Shipyard_Project__c shipyardObj1 = new CGT_Shipyard_Project__c();
        shipyardObj1.name = 'Test Shipyard1';
        shipyardObj1.CGT_Ship_Owner__c = accObj1.id;
        shipyardObj1.CGT_Shipyard_Builder__c = accObj1.id;
        shipyardObj1.CGT_Closing_Date__c = System.today();
        shipyardObj1.CGT_Project_Status__c = 'Lead';
        shipyardObj1.CGT_Vessel_Type__c = 'Bulk Carrier';
        insert shipyardObj1;
        
        CGT_Shipyard_Project__c shipyardObj2 = new CGT_Shipyard_Project__c();
        shipyardObj2.name = 'Test Shipyard2';
        shipyardObj2.CGT_Ship_Owner__c = accObj1.id;
        shipyardObj2.CGT_Shipyard_Builder__c = accObj1.id;
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
        CGT_Shipyard_Project__c shipyardObj2 = [SELECT id,CGT_Number_of_Vessels__c FROM CGT_Shipyard_Project__c WHERE name='Test Shipyard2' limit 1];
        
        Opportunity opportunityObj = new Opportunity();
        opportunityObj.name = 'Test Opportunity';
        opportunityObj.CloseDate = System.today().addDays(2);
        opportunityObj.CGT_Opportunity_Segment_main__c = 'Offshore';
        opportunityObj.StageName = 'Budget Quote';
        opportunityObj.CGT_Shipyard_Project__c = shipyardObj1.id;
        opportunityObj.Probability= 5;
        insert opportunityObj;
        
        List<CGT_Vessel_Node_Opportunity__c> tmpList1 = [SELECT id FROM CGT_Vessel_Node_Opportunity__c WHERE CGT_Opportunity__c =: opportunityObj.id];
        System.assert(tmpList1.size()>0);
        
        opportunityObj.CGT_Shipyard_Project__c = shipyardObj2.id;
        update opportunityObj;
        
        Opportunity opprObj = [SELECT id,CGT_Number_of_Vessels__c FROM Opportunity WHERE id=:opportunityObj.id];
        
        System.assert(opprObj.CGT_Number_of_Vessels__c == shipyardObj2.CGT_Number_of_Vessels__c);
    }
    
    /*
        @Author: Tieto
        @Method Name: shipOwnerCounters_Test
        @Description: This method is used for testing the updates of the Open Opportunities (Shipowner) and Won Opportunities (Shipowner) fields of the Shipowner of Opportunity.
    */
    
    public static testMethod void shipOwnerCounters_Test() {
        
        CGT_Shipyard_Project__c shipyardObj = [SELECT id FROM CGT_Shipyard_Project__c WHERE name='Test Shipyard1' limit 1];
        
        Account accObj1 = [select id from Account where name = 'Test Account1' limit 1];
        
        Account accObj2 = [select id from Account where name = 'Test Account2' limit 1];
        
        Opportunity opportunityObj1 = new Opportunity();
        opportunityObj1.name = 'Test Opportunity 1';
        opportunityObj1.CloseDate = System.today().addDays(2);
        opportunityObj1.CGT_Opportunity_Segment_main__c = 'Offshore';
        opportunityObj1.StageName = 'New / No Enquiry';
        opportunityObj1.CGT_Shipyard_Project__c = shipyardObj.id;
        opportunityObj1.Probability= 5;
        insert opportunityObj1;
        
        Opportunity opportunityObj2 = new Opportunity();
        opportunityObj2.name = 'Test Opportunity 2';
        opportunityObj2.CloseDate = System.today().addDays(2);
        opportunityObj2.CGT_Opportunity_Segment_main__c = 'Offshore';
        opportunityObj2.StageName = 'New / No Enquiry';
        opportunityObj2.AccountId = accObj1.id;
        opportunityObj2.CGT_Ship_Owner_Account__c = accObj1.id;
        opportunityObj2.Probability= 5;
        insert opportunityObj2;
        
        opportunityObj2.CGT_Ship_Owner_Account__c = accObj2.id;
        update opportunityObj2;
        
        opportunityObj2.CGT_Ship_Owner_Account__c = null;
        update opportunityObj2;
        
        opportunityObj1.CGT_Ship_Owner_Account__c = accObj1.id;
        update opportunityObj1;
        
        delete opportunityObj1;
        
        opportunityObj2.StageName = 'Closed Won';
        opportunityObj2.Loss_Reason__c = 'Good relation to owner';
        opportunityObj2.CGT_Ship_Owner_Account__c = accObj1.id;
        update opportunityObj2;
        
        opportunityObj2.CGT_Ship_Owner_Account__c = accObj2.id;
        opportunityObj2.CloseDate = System.today();
        update opportunityObj2;
        
        opportunityObj2.CGT_Ship_Owner_Account__c = null;
        update opportunityObj2;
        
        opportunityObj2.CGT_Ship_Owner_Account__c = accObj2.id;
        update opportunityObj2;
        
        delete opportunityObj2;
    }
}