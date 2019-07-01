@isTest
public class NC_Test_AccountQueryAction {
    
    public static testmethod void testNC(){
        
    List<case> CaseRecords = new List<case>();
    
    //crate account record
    Account acc = new account();
    acc.name = 'Test';
    acc.CGT_Account_Group__c = 'C006';
    insert acc;
    
    //crate case record
    Id customerRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NC Customer Claim').getRecordTypeId();
    case cs = new case();
    cs.AccountId = acc.Id;
    cs.NC_Customer__c = acc.Name;
    cs.RecordTypeId = customerRecordtypeId;
    insert cs;
        
    CaseRecords.add(cs);
        
    NC_AccountQueryAction.getAccountNames(CaseRecords);
    //verify if account assigned corrently
    cs = [SELECT Id, AccountId FROM Case WHERE Id=: cs.Id];
        system.assertEquals(cs.AccountId,  acc.Id);
    }
}