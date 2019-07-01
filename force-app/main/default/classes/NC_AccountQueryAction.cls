public class NC_AccountQueryAction {
    
    // Method to Query accounts based on Name and populate account lookup on case.
	@InvocableMethod(label='Get Account based on Names' description='Updates account lookup on case through web to case')
    
    public static void getAccountNames(List<case> CaseRecords) {
        List<Case> caseListUpd = new List<Case>();
    	Map<String, Case> caseMap = new Map<String, Case>();
        List<Account> accounts = new List<Account>();
        set<Id> caseId = new Map<Id, Case>(CaseRecords).keySet();
        
        // query cases to update account lookup       
        List<Case> caseQuery = [select id, AccountId, NC_Customer__c FROM Case WHERE Id IN: caseId];
                        
        //Iterate over cases to get account Name from Google Form
        for (Case objCase : CaseRecords) {
        	caseMap.put(objCase.NC_Customer__c, objCase);
        }
        
        // Query Accounts based on customer name
        if(caseMap.keySet() != null)
    	accounts = [SELECT Id, Name FROM Account WHERE Name IN: caseMap.keySet()];
        
        if(accounts!= null && !accounts.isEmpty() && accounts.size() == 1 && caseQuery.size() > 0){
            for (Case obj: caseQuery){
                obj.AccountId = accounts[0].Id;
                caseListUpd.add(obj);
            }
        }            
        update caseListUpd;
    }
}