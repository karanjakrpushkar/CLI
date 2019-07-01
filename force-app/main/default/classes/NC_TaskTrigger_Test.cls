@isTest(seeAllData=false)

/*
    @Author: Tieto
    @Class Name: NC_TaskTrigger_Test
    @Created Date: 18th April 2019
    @Description: This class is used to test the functionality of creating a task and then populating its claim owner from the parent claim.
*/

public class NC_TaskTrigger_Test {

    /*
        @Author: Tieto
        @Method Name: createRecords
        @Description: This method is used for creating dummy records for the class for testing purpose.
    */
    
    @testSetup
    public static void createRecords() {
    
        Profile userProfile = [select id from Profile where name like '%System Admin%' limit 1];
             
        //Insert test account record
    
        Account acc = new Account();
        acc.Name = 'Test Account Claim Helper';
        acc.CGT_Account_Group__c = 'C021';
        acc.Type = 'Other';
        insert acc;
        
        List<User> userList = new List<User>();
        
        User testUser1 = new User();
        testUser1.firstname = 'Test';
        testUser1.lastName = 'User 1';
        testUser1.email = 'test_user1456@example.com';
        testUser1.Username = 'test_user1456@example.com.username';
        testUser1.EmailEncodingKey = 'ISO-8859-1';
        testUser1.Alias ='test1';
        testUser1.TimeZoneSidKey = 'America/Los_Angeles';
        testUser1.LocaleSidKey = 'en_US';
        testUser1.LanguageLocaleKey = 'en_US';
        testUser1.ProfileId = userProfile.id;
        testUser1.isActive = true;
        //insert testUser1;
        userList.add(testUser1);
        
        User testUser2 = new User();
        testUser2.firstname = 'Test';
        testUser2.lastName = 'User 2';
        testUser2.email = 'test_user2456@example.com';
        testUser2.Username = 'test_user2456@example.com.username';
        testUser2.EmailEncodingKey = 'ISO-8859-1';
        testUser2.Alias ='test2';
        testUser2.TimeZoneSidKey = 'America/Los_Angeles';
        testUser2.LocaleSidKey = 'en_US';
        testUser2.LanguageLocaleKey = 'en_US';
        testUser2.ProfileId = userProfile.id;
        testUser2.isActive = true;
        //insert testUser2;
        userList.add(testUser2);
        
        insert userList;
    }
    
    /*
        @Author: Tieto
        @Method Name: claimOwnerChange_Test
        @Description: This method is used for creating a task related to a claim and then changing its related claim.
    */
    
    public static testMethod void claimOwnerChange_Test() {
        
        User testUser1 = [select id,Email from User where username = 'test_user1456@example.com.username' limit 1];
        
        User testUser2 = [select id,Email from User where username = 'test_user2456@example.com.username' limit 1];
        
        Account acc = [select id from Account where name = 'Test Account Claim Helper' limit 1];
        
        test.startTest();
        
        NC_Claim__c claimObj1 = new NC_Claim__c();
        claimObj1.NC_Status__c = 'New';
        claimObj1.NC_Project_Number__c = '12345';
        claimObj1.NC_Hull_Number__c = '12345';
        claimObj1.NC_IMO_Number__c = '12121';
        claimObj1.NC_Subject__c = 'Test Claim 1';
        claimObj1.NC_Description__c = 'Test Claim 1';
        claimObj1.NC_Date_of_Event__c = '12/12/2018';
        claimObj1.NC_Priority__c = 'Low';
        claimObj1.NC_Division__c = 'AOS Advanced Offshore Solutions';
        claimObj1.Origin_of_Claim__c = 'MCG Warehouse';
        claimObj1.NC_Estimated_value_class__c = 'EUR 0-499';
        claimObj1.OwnerId = testUser1.id;
        claimObj1.NC_Customer_Lookup__c = acc.id;
        insert claimObj1;
        
        NC_Claim__c claimObj2 = new NC_Claim__c();
        claimObj2.NC_Status__c = 'New';
        claimObj2.NC_Project_Number__c = '12345';
        claimObj2.NC_Hull_Number__c = '12345';
        claimObj2.NC_IMO_Number__c = '12121';
        claimObj2.NC_Subject__c = 'Test Claim 2';
        claimObj2.NC_Description__c = 'Test Claim 2';
        claimObj2.NC_Date_of_Event__c = '12/12/2018';
        claimObj2.NC_Priority__c = 'Low';
        claimObj2.NC_Division__c = 'AOS Advanced Offshore Solutions';
        claimObj2.Origin_of_Claim__c = 'MCG Warehouse';
        claimObj2.NC_Estimated_value_class__c = 'EUR 0-499';
        claimObj2.OwnerId = testUser2.id;
        claimObj2.NC_Customer_Lookup__c = acc.id;
        insert claimObj2;
        
        Task taskObj = new Task();
        taskObj.WhatId = claimObj1.id;
        taskObj.Subject = 'Other';
        taskObj.Status = 'Open';
        taskObj.Description = 'Test Task';
        insert taskObj;
        
        taskObj.WhatId = claimObj2.id;
        update taskObj;
        
        test.stopTest();
    }
    
}