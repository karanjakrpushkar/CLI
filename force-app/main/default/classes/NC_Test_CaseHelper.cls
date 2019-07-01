@isTest
private class NC_Test_CaseHelper {

    //Create a test record

    static testMethod void testgetFileAttachment() {
        try {
            Id customerRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NC Customer Claim').getRecordTypeId();
            Case caseObj = new Case(Status = 'New', NC_Project_Number__c = '12345', NC_Hull_Number__c = '12345', Subject = 'Test Subject',
                Description = 'Test Description', NC_Cost_Type__c = 'Rework', NC_Date_of_Event__c = '12/12/2018',
                Priority = 'Low', NC_Division__c = 'Advanced Offshore Solutions', Origin = 'Web',
                NC_Customer__c = 'test cust', NC_Estimated_value_class__c = 'EUR 0-500', NC_Google_Attachment_URL__c = 'https://drive.google.com/open?id=1G9AC60SfWfroBcOckvSklBoLQgYTpynE',
                NC_Claim_type_from_form__c = 'Customer', NC_Submitted_From_Google_Form__c = 'Yes', NC_Reporter_Email__c = 'test@test.com', NC_Created_From_Claim__c = true, NC_Claim_Record_Type_Name__c = 'NC Customer Claim',
                NC_Google_Attachment_URL_Int__c = 'https://drive.google.com/open?id=1G9AC60SfWfroBcOckvSklBoLQgYTpynE');
            Insert caseObj;

            // Retrieve case record
            caseObj = [SELECT Status, RecordTypeId FROM Case WHERE Id =: caseObj.Id];
            System.debug('Price after trigger fired: ' + caseObj.Status);

            // assert if record type is updated
            //System.assertEquals(customerRecordtypeId, caseObj.RecordTypeId);
        } catch (Exception e) {}
    }
}