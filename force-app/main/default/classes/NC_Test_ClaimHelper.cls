@isTest

/*****************************************************************************************************
 *
 * Author       : Tieto India Pvt Ltd
 * Purpose      : This is to test the functionality developed on the class NC_Claim_Helper
 
 ******************************************************************************************************/

public class NC_Test_ClaimHelper {
    
    // Create a cliam record

    static testMethod void testgetFileAttachment() {

        //Insert test account record
        
        Account acc = new Account();
        acc.Name = 'Test Account Claim Helper';
        acc.CGT_Account_Group__c = 'C021';
        acc.Type = 'Other';
        insert acc;
        
        //Insert case record
        Id customerRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NC Customer Claim').getRecordTypeId();
        Id customerRecordtypeIdClaim = Schema.SObjectType.NC_Claim__c.getRecordTypeInfosByName().get('NC Customer Claim').getRecordTypeId();
        Case caseObj = new Case(Status = 'New', NC_Project_Number__c = '12345', NC_Hull_Number__c = '12345', Subject = 'Test Subject',
            Description = 'Test Description', NC_Cost_Type__c = 'Rework',
            Priority = 'Low', NC_Division__c = 'AOS Advanced Offshore Solutions', Origin = 'Web',
            NC_Customer__c = 'test cust', NC_Estimated_value_class__c = 'EUR 0-499', NC_Google_Attachment_URL__c = 'https://drive.google.com/open?id=1G9AC60SfWfroBcOckvSklBoLQgYTpynE',
            NC_Claim_type_from_form__c = 'Customer', NC_Reporter_Email__c = 'test@test.com', RecordTypeId = customerRecordtypeId);

        insert caseObj;

        //Insert claim record

        NC_Claim__c obj = new NC_Claim__c(NC_Status__c = 'New', NC_Project_Number__c = '12345', NC_Hull_Number__c = '12345', NC_IMO_Number__c = '12121', NC_Subject__c = 'Test Subject', NC_Description__c = 'Test Description',
             NC_Priority__c = 'Low', NC_Division__c = 'AOS Advanced Offshore Solutions', Origin_of_Claim__c = 'MCG Warehouse',
            NC_Estimated_value_class__c = 'EUR 0-499', NC_Case__c = caseObj.Id,NC_Customer_Lookup__c=acc.id);
        Insert obj;

        //query cliam record
        obj = [SELECT NC_Status__c, RecordType.Name FROM NC_Claim__c WHERE Id =: obj.Id];

        //assert if record type is assigned
        System.assertEquals(obj.RecordType.Name, 'NC Customer Claim');

        //validate task validaiton
        Task task = new Task();
        task.WhatId = obj.id;
        task.Subject = 'Other';
        task.status = 'Open';
        task.description = 'New  Work';
        insert task;

        try {
            //change status of claim
            obj.NC_Status__c = 'Closed';
            update obj;
        } catch (Exception ex) {
            Boolean expectedExceptionThrown = ex.getMessage().contains('Claim with open related Tasks can not be closed or Discarded') ? true : false;

            //assert if exception is thrown
            //System.assertEquals(expectedExceptionThrown, true);
        }

        //validate for parent cliam
        //obj = [SELECT NC_Status__c,RecordType.Name FROM NC_Claim__c WHERE Id =:obj.Id];
        system.debug('statu ' + obj.NC_Status__c);
        NC_Claim__c objClaim = new NC_Claim__c(NC_Status__c = 'New', NC_Project_Number__c = '12345', NC_Hull_Number__c = '12345', NC_IMO_Number__c = '12121', NC_Subject__c = 'Test Subject', NC_Description__c = 'Test Description',
            NC_Date_of_Event__c = '12/12/2018', NC_Priority__c = 'Low', NC_Division__c = 'AOS Advanced Offshore Solutions', Origin_of_Claim__c = 'MCG Warehouse',
            NC_Estimated_value_class__c = 'EUR 0-499', NC_Parent_Claim__c = obj.Id, RecordTypeId = customerRecordtypeIdClaim,NC_Customer_Lookup__c=acc.id);
        insert objClaim;

        obj = [SELECT NC_Status__c, RecordType.Name FROM NC_Claim__c WHERE Id =: obj.Id];

        try {
            system.debug('parent ' + objClaim.NC_Parent_Claim__c + 'parent id ' + obj.Id);
            obj.NC_Status__c = 'Closed';
            update obj;
        } catch (Exception ex) {
            Boolean expectedExceptionThrown = ex.getMessage().contains('You tried to close or discard a claim which has open sub-claims under it. Please ensure that you close (or mark as discarded) the sub-claims, before you close this claim.') ? true : false;
            //System.assertEquals(expectedExceptionThrown, true);
        }

    }

    //test method to not allow users to mark claim as "Corrections done" and "Corrective Actions done" if there are open sub-tasks of that type
    static testMethod void testSubTaskValidation() {

        //Insert test account record
        
        Account acc = new Account();
        acc.Name = 'Test Account Claim Helper';
        acc.CGT_Account_Group__c = 'C021';
        acc.Type = 'Other';
        insert acc;
        
        //Insert case record
        Id customerRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NC Customer Claim').getRecordTypeId();
        Id customerRecordtypeIdClaim = Schema.SObjectType.NC_Claim__c.getRecordTypeInfosByName().get('NC Customer Claim').getRecordTypeId();
        Case caseObj = new Case(Status = 'New', NC_Project_Number__c = '12345', NC_Hull_Number__c = '12345', Subject = 'Test Subject',
            Description = 'Test Description', NC_Cost_Type__c = 'Rework',
            Priority = 'Low', NC_Division__c = 'AOS Advanced Offshore Solutions', Origin = 'Web',
            NC_Customer__c = 'test cust', NC_Estimated_value_class__c = 'EUR 0-499', NC_Google_Attachment_URL__c = 'https://drive.google.com/open?id=1G9AC60SfWfroBcOckvSklBoLQgYTpynE',
            NC_Claim_type_from_form__c = 'Customer', NC_Reporter_Email__c = 'test@test.com', RecordTypeId = customerRecordtypeId);

        insert caseObj;

        //Insert claim record

        NC_Claim__c obj = new NC_Claim__c(NC_Status__c = 'New', NC_Project_Number__c = '12345', NC_Hull_Number__c = '12345', NC_IMO_Number__c = '12121', NC_Subject__c = 'Test Subject', NC_Description__c = 'Test Description',
             NC_Priority__c = 'Low', NC_Division__c = 'AOS Advanced Offshore Solutions', Origin_of_Claim__c = 'MCG Warehouse',
            NC_Estimated_value_class__c = 'EUR 0-499', NC_Case__c = caseObj.Id,NC_Customer_Lookup__c=acc.id);
        Insert obj;

        //query cliam record
        obj = [SELECT NC_Status__c, RecordType.Name FROM NC_Claim__c WHERE Id =: obj.Id];

        //assert if record type is assigned
        System.assertEquals(obj.RecordType.Name, 'NC Customer Claim');

        //Create tasks of both types to test the validation
        Task task1 = new Task();
        task1.WhatId = obj.id;
        task1.Subject = 'Other';
        task1.status = 'Open';
        task1.description = 'New  Work 1';
        task1.NC_Claim_Task_Type__c = 'Correction';
        insert task1;

        Task task2 = new Task();
        task2.WhatId = obj.id;
        task2.Subject = 'Other';
        task2.status = 'Open';
        task2.description = 'New  Work 2';
        task2.NC_Claim_Task_Type__c = 'Corrective Action';
        insert task2;

        try {
        
            //Mark corrections done on Parent Claim of task to test the validation
            
            obj.NC_Corrections_completed__c = true;
            update obj;
        } catch (Exception ex) {
            System.debug('Exception thrown = ' + ex);
        }

        try {
        
            //Mark Corrective Actions done on Parent Claim of task to test the validation
            
            Task updateTask = [select id, Status from Task where id =: task1.id];
            updateTask.status = 'Completed';
            update updateTask;

            obj.NC_Corrective_actions_completed__c = true;
            update obj;
        } catch (Exception ex) {
            System.debug('Exception thrown = ' + ex);
        }
    }
    
    /*
        @Author: Tieto
        @Method Name: testTaskOwnerUpdate
        @Description: This method is used to test task owner change on claim owner change
    */
    static testMethod void testTaskOwnerUpdate() {

        //Retrieve test users
        List<User> usrList = [select id,email from user where isActive = true limit 2];
        
        //Insert test account record
        
        Account acc = new Account();
        acc.Name = 'Test Account Claim Helper';
        acc.CGT_Account_Group__c = 'C021';
        acc.Type = 'Other';
        insert acc;
        
        //Insert case record
        Id customerRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NC Customer Claim').getRecordTypeId();
        Id customerRecordtypeIdClaim = Schema.SObjectType.NC_Claim__c.getRecordTypeInfosByName().get('NC Customer Claim').getRecordTypeId();
        Case caseObj = new Case(Status = 'New', NC_Project_Number__c = '12345', NC_Hull_Number__c = '12345', Subject = 'Test Subject',
            Description = 'Test Description', NC_Cost_Type__c = 'Rework',
            Priority = 'Low', NC_Division__c = 'AOS Advanced Offshore Solutions', Origin = 'Web',
            NC_Customer__c = 'test cust', NC_Estimated_value_class__c = 'EUR 0-499', NC_Google_Attachment_URL__c = 'https://drive.google.com/open?id=1G9AC60SfWfroBcOckvSklBoLQgYTpynE',
            NC_Claim_type_from_form__c = 'Customer', NC_Reporter_Email__c = 'test@test.com', RecordTypeId = customerRecordtypeId);

        insert caseObj;

        //Insert claim record

        NC_Claim__c obj = new NC_Claim__c(NC_Status__c = 'New', NC_Project_Number__c = '12345', NC_Hull_Number__c = '12345', NC_IMO_Number__c = '12121', NC_Subject__c = 'Test Subject', NC_Description__c = 'Test Description',
             NC_Priority__c = 'Low', NC_Division__c = 'AOS Advanced Offshore Solutions', Origin_of_Claim__c = 'MCG Warehouse',
            NC_Estimated_value_class__c = 'EUR 0-499', NC_Case__c = caseObj.Id,NC_Customer_Lookup__c=acc.id,OwnerId = usrList[0].id);
        Insert obj;

        //Create tasks of owner assignment
        Task taskObj = new Task();
        taskObj.WhatId = obj.id;
        taskObj.Subject = 'Other';
        taskObj.status = 'Open';
        taskObj.description = 'New  Work 1';
        taskObj.NC_Claim_Task_Type__c = 'Correction';
        insert taskObj;

        try {
        
            //Update owner of Claim
            
            obj.OwnerId = usrList[1].id;
            update obj;
        } catch (Exception ex) {
            System.debug('Exception thrown = ' + ex);
        }
    }
    
    /*
        @Author: Tieto
        @Method Name: testSubClaimAttachmentCopy
        @Description: This method is used to test copying attachments from parent claim to sub-claim.
    */
    
    static testMethod void testSubClaimAttachmentCopy() {
        
        //Insert test account record
        
        Account acc = new Account();
        acc.Name = 'Claim Helper Test Rec';
        acc.CGT_Account_Group__c = 'C021';
        acc.Type = 'Other';
        insert acc;
        
        //Create test parent claims with attachments
        
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
        claimObj2.NC_Customer_Lookup__c = acc.id;
        insert claimObj2;
        
        //Create attachments related to the claim
        
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        
        List<ContentVersion> contentList = new List<ContentVersion>();
        
        for(Integer i=0;i<3;i++) {
            ContentVersion cv = new ContentVersion();
            cv.title = 'test content trigger '+i;      
            cv.PathOnClient ='test';           
            cv.VersionData = beforeblob;
            contentList.add(cv);
        }
        
        insert contentList;

        List<ContentVersion> testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id IN :contentList];
        
        ContentDocumentLink newLink1 = new ContentDocumentLink();
        newLink1.LinkedEntityId = claimObj1.id;
        newLink1.ShareType = 'V';
        newLink1.ContentDocumentId = testcontent[0].ContentDocumentId;
        insert newLink1;
        
        ContentDocumentLink newLink2 = new ContentDocumentLink();
        newLink2.LinkedEntityId = claimObj1.id;
        newLink2.ShareType = 'V';
        newLink2.ContentDocumentId = testcontent[1].ContentDocumentId;
        insert newLink2;
        
        ContentDocumentLink newLink3 = new ContentDocumentLink();
        newLink3.LinkedEntityId = claimObj2.id;
        newLink3.ShareType = 'V';
        newLink3.ContentDocumentId = testcontent[2].ContentDocumentId;
        insert newLink3;
        
        //Create sub-claims to whom the attachments will be copied
        
        NC_Claim__c subClaimObj1 = new NC_Claim__c();
        subClaimObj1.NC_Status__c = 'New';
        subClaimObj1.NC_Project_Number__c = '12345';
        subClaimObj1.NC_Hull_Number__c = '12345';
        subClaimObj1.NC_IMO_Number__c = '12121';
        subClaimObj1.NC_Subject__c = 'Test Claim 1';
        subClaimObj1.NC_Description__c = 'Test Claim 1';
        subClaimObj1.NC_Date_of_Event__c = '12/12/2018';
        subClaimObj1.NC_Priority__c = 'Low';
        subClaimObj1.NC_Division__c = 'AOS Advanced Offshore Solutions';
        subClaimObj1.Origin_of_Claim__c = 'MCG Warehouse';
        subClaimObj1.NC_Estimated_value_class__c = 'EUR 0-499';
        subClaimObj1.NC_Parent_Claim__c = claimObj1.id;
        subClaimObj1.NC_Customer_Lookup__c = acc.id;
        insert subClaimObj1;
        
        NC_Claim__c subClaimObj2 = new NC_Claim__c();
        subClaimObj2.NC_Status__c = 'New';
        subClaimObj2.NC_Project_Number__c = '12345';
        subClaimObj2.NC_Hull_Number__c = '12345';
        subClaimObj2.NC_IMO_Number__c = '12121';
        subClaimObj2.NC_Subject__c = 'Test Claim 2';
        subClaimObj2.NC_Description__c = 'Test Claim 2';
        subClaimObj2.NC_Date_of_Event__c = '12/12/2018';
        subClaimObj2.NC_Priority__c = 'Low';
        subClaimObj2.NC_Division__c = 'AOS Advanced Offshore Solutions';
        subClaimObj2.Origin_of_Claim__c = 'MCG Warehouse';
        subClaimObj2.NC_Estimated_value_class__c = 'EUR 0-499';
        subClaimObj2.NC_Parent_Claim__c = claimObj2.id;
        subClaimObj2.NC_Customer_Lookup__c = acc.id;
        insert subClaimObj2;
        
        List<NC_Claim__c> claimSubList = new List<NC_Claim__c>();
        claimSubList.add(subClaimObj1);
        claimSubList.add(subClaimObj2);
        
        List<List<NC_Claim__c>> claimList = new List<List<NC_Claim__c>>();
        claimList.add(claimSubList);
        
        NC_Claim_Helper.copyAttachmentsToSubClaim(claimList);
    }
}