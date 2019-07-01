@isTest(seeAllData = false)

/*
    @Author: Tieto
    @Class Name: CGT_ShipyardVesselNodeTrigger_Test
    @Created Date: 8th August 2018
    @Description: This class is used to test the functionality of creating Opportunity vesel node,
     deleting the opportunity vessel node when similar actions are performed on shipyard project vessel nodes and 
     cascading of asset field of shipyard vessel node to opportunity vessel node.
*/

public class CGT_ShipyardVesselNodeTrigger_Test {
    
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

        CGT_Shipyard_Project__c shipyardObj = new CGT_Shipyard_Project__c();
        shipyardObj.name = 'Test Shipyard';
        shipyardObj.CGT_Ship_Owner__c = accObj.id;
        shipyardObj.CGT_Shipyard_Builder__c = accObj.id;
        shipyardObj.CGT_Closing_Date__c = System.today();
        shipyardObj.CGT_Project_Status__c = 'Lead';
        shipyardObj.CGT_Vessel_Type__c = 'Bulk Carrier';
        insert shipyardObj;
        
        CGT_Vessel_Node_Shipyard_Project__c vesselNodeObj = new CGT_Vessel_Node_Shipyard_Project__c();
        vesselNodeObj.CGT_V_Ship_Delivery_Date__c = System.today();
        vesselNodeObj.CGT_V_Hull_Number__c = '3';
        vesselNodeObj.CGT_Shipyard_Project__c = shipyardObj.id;
        insert vesselNodeObj;

        List<Opportunity> opportunityList = new List<Opportunity>();
        
        for(Integer i=0;i<5;i++) {
            Opportunity opportunityObj = new Opportunity();
            opportunityObj.name = 'Test Opportunity '+i;
            opportunityObj.CloseDate = System.today().addDays(2);
            opportunityObj.CGT_Opportunity_Segment_main__c = 'Offshore';
            opportunityObj.StageName = 'Budget Quote';
            opportunityObj.CGT_Shipyard_Project__c = shipyardObj.id;
            opportunityObj.Probability= 5;
            opportunityList.add(opportunityObj);
        }
        
        insert opportunityList;
    }
    
    /*
        @Author: Tieto
        @Method Name: createOpportunityVesselNode_Test
        @Description: This method is used for testing creation of opportunity vessel nodes on creation of shipyard vessel node.
    */

    public static testMethod void createOpportunityVesselNode_Test() {

        CGT_Shipyard_Project__c shipyardObj = [SELECT id FROM CGT_Shipyard_Project__c WHERE name = 'Test Shipyard' limit 1];
        
        CGT_Vessel_Node_Shipyard_Project__c vesselNodeObj = new CGT_Vessel_Node_Shipyard_Project__c();
        vesselNodeObj.CGT_V_Ship_Delivery_Date__c = System.today();
        vesselNodeObj.CGT_V_Hull_Number__c = '3';
        vesselNodeObj.CGT_Shipyard_Project__c = shipyardObj.id;
        insert vesselNodeObj;
        
        List<CGT_Vessel_Node_Opportunity__c> tmpList = [SELECT id FROM CGT_Vessel_Node_Opportunity__c WHERE CGT_Related_Vessel_Node_Shipyard_Project__c=:vesselNodeObj.id];
        System.assert(tmpList.size()>0);

    }
    
    /*
        @Author: Tieto
        @Method Name: updateOpportunityVesselNode_Test
        @Description: This method is used for testing cascading of asset field on opportunity vessel nodes when asset on shipyard vessel node is changed.
    */
    
    public static testMethod void updateOpportunityVesselNode_Test() {

        Account accountObj = [SELECT id FROM Account WHERE name='Test Account' LIMIT 1];
        
        CGT_Shipyard_Project__c shipyardObj = [SELECT id FROM CGT_Shipyard_Project__c WHERE name = 'Test Shipyard' LIMIT 1];
        
        List<CGT_Vessel_Node_Shipyard_Project__c> vesselList = [SELECT id,CGT_Asset_Functional_Location__c FROM CGT_Vessel_Node_Shipyard_Project__c WHERE CGT_Shipyard_Project__c = :shipyardObj.id];
        
        Id RecordTypeIdAsset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Functional Location').getRecordTypeId();
        
        Asset assetObj = new Asset();
        assetObj.name='Test Asset';
        assetObj.AccountId = accountObj.id;
        assetObj.recordtypeid = RecordTypeIdAsset;
        insert assetObj;
        
        for(CGT_Vessel_Node_Shipyard_Project__c obj : vesselList) {
            obj.CGT_Asset_Functional_Location__c = assetObj.id;
        }
        
        update vesselList;
        
        List<CGT_Vessel_Node_Opportunity__c> tmpList = [SELECT id,CGT_Asset_Functional_Location__c FROM CGT_Vessel_Node_Opportunity__c WHERE CGT_Related_Vessel_Node_Shipyard_Project__r.CGT_Shipyard_Project__c = :shipyardObj.id];
        System.assert(tmpList[0].CGT_Asset_Functional_Location__c == assetObj.id);
    }
    
    /*
        @Author: Tieto
        @Method Name: deleteOpportunityVesselNode_Test
        @Description: This method is used for testing deletion of opportunity vessel nodes on deletion of shipyard vessel node.
    */
    
    public static testMethod void deleteOpportunityVesselNode_Test() {

        CGT_Shipyard_Project__c shipyardObj = [SELECT id FROM CGT_Shipyard_Project__c WHERE name = 'Test Shipyard' LIMIT 1];
        
        List<CGT_Vessel_Node_Shipyard_Project__c> vesselList = [SELECT id FROM CGT_Vessel_Node_Shipyard_Project__c WHERE CGT_Shipyard_Project__c = :shipyardObj.id];
        
        delete vesselList;
        
        List<CGT_Vessel_Node_Opportunity__c> tmpList = [SELECT id FROM CGT_Vessel_Node_Opportunity__c WHERE CGT_Related_Vessel_Node_Shipyard_Project__r.CGT_Shipyard_Project__c = :shipyardObj.id];
        System.assert(tmpList.size()==0);
        
    }

}