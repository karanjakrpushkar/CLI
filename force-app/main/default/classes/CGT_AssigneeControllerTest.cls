@isTest(seeAllData = false)
public class CGT_AssigneeControllerTest {

    public static testMethod void task1(){
    
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
        
     
      
       Task task = new Task();
        task.WhatId = opportunityObj.id;
        task.Subject = 'Other';
        task.status = 'Open';
        task.description = 'New  Work';
        insert task;
        
        CGT_AssigneeController.taskOwneridUpdate(task.id);
    }
}