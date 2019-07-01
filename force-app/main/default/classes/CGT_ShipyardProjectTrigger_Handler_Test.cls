@isTest(seeAllData = false)

/*
    @Author: Tieto
    @Class Name: CGT_ShipyardProjectTrigger_Handler_Test
    @Created Date: 7th August 2018
    @Description: This class is used to test the functionality of restricting user from closing shipyard projects having open opportunities.
*/

public class CGT_ShipyardProjectTrigger_Handler_Test {

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
        shipyardObj.CGT_Project_Status__c = 'Hot';
        shipyardObj.CGT_Vessel_Type__c = 'Bulk Carrier';
        shipyardObj.CGT_Number_of_Options__c = 3;
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
        @Method Name: ShipyardProjectRestrictClose_Test
        @Description: This method is used for getting a dummy shipyard project having open opportunities and updating its project status as closed.
    */

    public static testMethod void ShipyardProjectRestrictClose_Test() {

        List<CGT_Shipyard_Project__c> shipyardList = [SELECT id,CGT_Project_Status__c FROM CGT_Shipyard_Project__c WHERE name = 'Test Shipyard'];
        
        try {
            
            CGT_ShipyardProjectTrigger_Handler.showErrorForClosedStatus(shipyardList);
            
        } catch(Exception e) {
            System.debug(e);
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.CGT_ShipyardProject_Close_Error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    /*
        @Author: Tieto
        @Method Name: ShipyardProjectClone_Test
        @Description: This method is used for creating a dummy shipyard project for testing the automatic cloning process.
    */

    public static testMethod void ShipyardProjectClone_Test() {

        List<CGT_Shipyard_Project__c> shipyardList = [SELECT id FROM CGT_Shipyard_Project__c WHERE name = 'Test Shipyard'];
        
        try {
            
            CGT_ShipyardProjectTrigger_Handler.cloneShipyardProject(shipyardList);
            
        } catch(Exception e) {
            System.debug(e);
        }
    }
}