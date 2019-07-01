@isTest(seeAllData = false)
public class CGT_CreateRecordControllerTest {

    public static testMethod void creatrecord(){
    
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
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        
        Opportunity opportunityObj = new Opportunity();
        opportunityObj.name = 'Test Opportunity';
        opportunityObj.CloseDate = System.today().addDays(2);
        opportunityObj.CGT_Opportunity_Segment_main__c = 'Offshore';
        opportunityObj.StageName = 'Budget Quote';
        opportunityObj.CGT_Shipyard_Project__c = shipyardObj1.id;
        opportunityObj.Probability= 5;
       insert opportunityObj;
       
       CGT_CreateRecordController.createRec(opportunityObj.id);
       
       
     
      
       
    }
    public static testMethod void creatrecord1(){
    
       CGT_CreateRecordController.createRec(null);
        
     
      
       
    }
}