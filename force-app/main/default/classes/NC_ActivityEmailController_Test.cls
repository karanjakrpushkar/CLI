@isTest(seeAllData=false)

/*
    @Author: Tieto
    @Class Name: NC_ActivityEmailController_Test
    @Created Date: 7th June 2019
    @Description: This class is used to test the functionality of returning the email messages associated with claims.
*/

public class NC_ActivityEmailController_Test {
     /*
        @Author: Tieto
        @Method Name: EmailMessageInsertion_Test
        @Description: This method is used for creating email messages and associating them with a claim record.
    */
    
    public static testMethod void EmailMessageInsertion_Test() {
        
        Account acc = new Account();
        acc.Name = 'Test Account Claim';
        acc.CGT_Account_Group__c = 'C021';
        acc.Type = 'Other';
        insert acc;
        
        NC_Claim__c claimObj = new NC_Claim__c();
        claimObj.NC_Status__c = 'New';
        claimObj.NC_Project_Number__c = '12345';
        claimObj.NC_Hull_Number__c = '12345';
        claimObj.NC_IMO_Number__c = '12121';
        claimObj.NC_Subject__c = 'Test Claim';
        claimObj.NC_Description__c = 'Test Claim';
        claimObj.NC_Date_of_Event__c = '12/12/2018';
        claimObj.NC_Priority__c = 'Low';
        claimObj.NC_Division__c = 'AOS Advanced Offshore Solutions';
        claimObj.Origin_of_Claim__c = 'MCG Warehouse';
        claimObj.NC_Estimated_value_class__c = 'EUR 0-499';
        claimObj.NC_Customer_Lookup__c = acc.id;
        insert claimObj;
        
        EmailMessage emailObj = new EmailMessage();
        emailObj.FromAddress = 'test@abc.org';
        emailObj.Incoming = True;
        emailObj.ToAddress= 'test@xyz.org';
        emailObj.Subject = 'Test email';
        emailObj.HtmlBody = 'Test email body';
        emailObj.RelatedToId = claimObj.Id; 
        insert emailObj;
        
        NC_ActivityEmailController.getEmails(claimObj.id);
    }
    
}