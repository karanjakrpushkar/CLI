public class NC_ContactQueryAction{
	//Method to populate account, asset and contact based on form input

	@InvocableMethod(label='Get Related Records' description='Updates Related records based on form input')

	public static void getContact(List<case> CaseRecords){
        SYSTEM.debug('&&&&&&&&& PROCESS BUILDER CALLED');

		//populate case ids form case records
		set<Id> caseId = new Map<Id, Case>(CaseRecords).keySet();
        
        //asset record type id
        Id functionLocationId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Functional Location').getRecordTypeId();
 
		//query cases based on ids to get related fields
		List<Case> caseQuery = [SELECT Id, NC_Reporter_Email__c, NC_Contact_Email__c ,AccountId, NC_Customer__c, NC_IMO_Number__c, NC_Contact_FirstName__c, NC_Contact_LastName__c FROM Case WHERE Id IN: caseId];
        system.debug('this is case initially ************' + caseQuery );

		//set<String> accountNames = new set<String>();
		set<String> assetNames = new set<String>();
		set<String> contactEmail = new set<String>();

		//List<Account> accounts = new List<Account>();
		List<Asset> assets = new List<Asset>();
		List<Contact> contacts = new List<Contact>();

		//updated case list
		List<Case> caseListUpd = new List<Case>();
		//Contact list to be inserted
		//List<Contact> insertContactList = new List<Contact>();

		//Iterate over the caseQuerty to populate collections
		for(Case obj: caseQuery){
            
            if(obj.NC_IMO_Number__c != null)
                assetNames.add(obj.NC_IMO_Number__c);
            if(obj.NC_Contact_Email__c != null)
                contactEmail.add(obj.NC_Contact_Email__c);
		}

		//Query related records.

		if(assetNames != null)
			assets = [SELECT Id, CGT_IMO_Number__c,CGT_Functional_Location__c,AccountId from Asset WHERE CGT_Functional_Location__c IN: assetNames AND RecordtypeId =: functionLocationId];
        SYSTEM.debug('assets '+ assets);

		if(contactEmail != null)
			contacts = [SELECT Id, Email, AccountId, FirstName, LastName, Name from Contact where Email IN: contactEmail];
        SYSTEM.debug('contacts '+ contacts);

		//iterate over the cases to popualate related records.
        if(caseQuery.size() > 0){
                for(case obj : caseQuery){
                Boolean isfound = false;
                //Boolean isContactFound = false;
                system.debug('hasaccount '+ obj.AccountId);
                if(assets!= null && !assets.isEmpty() && assets.size() == 1){
                    obj.CGT_Vessel__c = assets[0].Id;
                    obj.AccountId = assets[0].AccountId;
                    isfound = true;
            	}				
            
                if(contacts != null && !contacts.isEmpty() && contacts.size() == 1){
                    system.debug('inside contact ' +contacts);
                    obj.NC_Contact__c = contacts[0].Id;                    
                    isfound = true;
                }
            system.debug('isfound '+ isfound);
            //system.debug('updatedlist '+ caseListUpd);
                    if(isfound){
                        caseListUpd.add(obj); 
                    }				           
			}
        }
		

		try{
            system.debug('caselistupda '+ caseListUpd);
        	update caseListUpd;
        }catch(dmlException ex){
        	system.debug('DML Exception '+ ex.getMessage());
        }

	}
}