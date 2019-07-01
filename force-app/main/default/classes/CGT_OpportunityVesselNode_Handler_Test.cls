@isTest(seeAllData = false)

/*
    @Author: Tieto
    @Class Name: CGT_OpportunityVesselNodeTrigger_Test
    @Created Date: 2nd August 2018
    @Description: This class is used to test the functionality of restricting the user FROM 
     creating or deleting a vessel node directly in a shipyard project opportunity.
*/

public class CGT_OpportunityVesselNode_Handler_Test {

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

        Opportunity opportunityObj = new Opportunity();
        opportunityObj.name = 'Test Opportunity';
        opportunityObj.CloseDate = System.today().addDays(2);
        opportunityObj.CGT_Opportunity_Segment_main__c = 'Offshore';
        opportunityObj.StageName = 'Budget Quote';
        opportunityObj.CGT_Shipyard_Project__c = shipyardObj.id;
        opportunityObj.Probability= 5;
        insert opportunityObj;

    }
    
    /*
        @Author: Tieto
        @Method Name: OpportunityVesselNodeInsert_Test
        @Description: This method is used for testing restricting users access FROM directly creating a vessel node for Shipyard project opportunity.
    */

    public static testMethod void OpportunityVesselNodeInsert_Test() {

        Opportunity opportunityObj = [SELECT id FROM Opportunity WHERE name = 'Test Opportunity'
            limit 1
        ];
        
        List<CGT_Vessel_Node_Opportunity__c> vesselNodeDeleteList = [SELECT id FROM CGT_Vessel_Node_Opportunity__c WHERE CGT_Opportunity__c=:opportunityObj.id];

        try {
            List<CGT_Vessel_Node_Opportunity__c> vesselNodeInsertList = new List<CGT_Vessel_Node_Opportunity__c>();
            CGT_Vessel_Node_Opportunity__c obj = new CGT_Vessel_Node_Opportunity__c();
            obj.CGT_Opportunity__c = opportunityObj.id;
            obj.CGT_Inserted_FROM_Code__c = false;
            vesselNodeInsertList.add(obj);
            insert vesselNodeInsertList;
            
            CGT_OpportunityVesselNodeTrigger_Handler.restrictAction(vesselNodeInsertList,'insert');
            
        } catch(Exception e) {
            System.debug(e);
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.CGT_VesselNode_Insert_Error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    /*
        @Author: Tieto
        @Method Name: OpportunityVesselNodeDelete_Test
        @Description: This method is used for testing restricting users access FROM directly deleting a vessel node FROM Shipyard project opportunity.
    */
    
    public static testMethod void OpportunityVesselNodeDelete_Test() {

        Opportunity opportunityObj = [SELECT id FROM Opportunity WHERE name = 'Test Opportunity'
            limit 1
        ];
        
        List<CGT_Vessel_Node_Opportunity__c> vesselNodeDeleteList = [SELECT id,CGT_Inserted_FROM_Code__c FROM CGT_Vessel_Node_Opportunity__c WHERE CGT_Opportunity__c=:opportunityObj.id];

        try {
            
            delete vesselNodeDeleteList;
            CGT_OpportunityVesselNodeTrigger_Handler.restrictAction(vesselNodeDeleteList,'delete');
            
        } catch(Exception e) {
            System.debug('Exception in code = '+e);
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.CGT_VesselNode_Delete_Error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }

}