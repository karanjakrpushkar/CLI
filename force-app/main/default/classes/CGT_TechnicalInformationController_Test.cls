@isTest(seeAllData=false)

/*
    @Author: Tieto
    @Class Name: CGT_TechnicalInformationController_Test
    @Created Date: 6th June 2019
    @Description: This class is used to test the functionality of returning the opportunity information for the technical information record to be created based on the Opportunity Type value.
*/

public class CGT_TechnicalInformationController_Test {
     /*
        @Author: Tieto
        @Method Name: TechnicalInformationInsertion_Test
        @Description: This method is used for creating opportunity with a opportunity type and returning this information for creating the technical information record.
    */
    
    public static testMethod void TechnicalInformationInsertion_Test() {
        
        Account accObj = new Account();
        accObj.name = 'Test Account';
        accObj.CGT_Account_Group__c = 'C021';
        accObj.Type = 'Other';
        insert accObj;
        
        CGT_Shipyard_Project__c shipyardObj = new CGT_Shipyard_Project__c();
        shipyardObj.name = 'Test Shipyard1';
        shipyardObj.CGT_Ship_Owner__c = accObj.id;
        shipyardObj.CGT_Shipyard_Builder__c = accObj.id;
        shipyardObj.CGT_Closing_Date__c = System.today();
        shipyardObj.CGT_Project_Status__c = 'Lead';
        shipyardObj.CGT_Vessel_Type__c = 'Bulk Carrier';
        insert shipyardObj;
        
        Opportunity opportunityObj = new Opportunity();
        opportunityObj.name = 'Test Opportunity';
        opportunityObj.CloseDate = System.today().addDays(2);
        opportunityObj.CGT_Opportunity_Segment_main__c = 'Merchant';
        opportunityObj.CGT_Opportunity_Type__c = 'Compressors';
        opportunityObj.StageName = 'New / No Enquiry';
        opportunityObj.CGT_Shipyard_Project__c = shipyardObj.id;
        opportunityObj.Probability= 5;
        insert opportunityObj;
        
        Opportunity opprObj = [select id,CGT_Opportunity_Segment_main__c,CGT_Opportunity_Type__c from Opportunity where id=:opportunityObj.id limit 1];
        
        CGT_TechnicalInformationController.getRecordTypeInfo(opprObj.id);
        
        opprObj.CGT_Opportunity_Type__c = 'Deck Machinery';
        update opprObj;
        
        CGT_TechnicalInformationController.getRecordTypeInfo(opprObj.id);
        
        opprObj.CGT_Opportunity_Type__c = 'Steering Gear';
        update opprObj;
        
        CGT_TechnicalInformationController.getRecordTypeInfo(opprObj.id);
        
        opprObj.CGT_Opportunity_Segment_main__c = 'Offshore';
        opprObj.CGT_Opportunity_Type__c = 'Offshore BHS';
        update opprObj;
        
        CGT_TechnicalInformationController.getRecordTypeInfo(opprObj.id);
        
        try {
        
            opprObj.CGT_Opportunity_Type__c = 'Davits';
            update opprObj;
            
            CGT_TechnicalInformationController.getRecordTypeInfo(opprObj.id);
        
        } catch(Exception e) {
            System.debug(e);
        }
    }
}