trigger NC_Claim_Trigger on NC_Claim__c (before update, after insert, before insert) {
    
    //Method to validate closed claims and sub-tasks
    if(Trigger.isBefore && Trigger.isUpdate) {
        
        //Used for passing the claim records for validation of their sub-tasks
        Set<NC_Claim__c> correctionTasksSet = new Set<NC_Claim__c>();
        Set<NC_Claim__c> correctionActionTasksSet = new Set<NC_Claim__c>();
        Set<String> updateOwnerTasksSet = new Set<String>();
        
        NC_Claim_Helper.validateClosedClaims(Trigger.New, Trigger.oldMap);
        NC_Claim_Helper.subClaimValidaiton(Trigger.New, Trigger.oldMap);
        NC_Claim_Helper.dateFormate(Trigger.New);
        
        //Check if the claim is marked as "Corrections Done" or "Corrective Actions Done"
        for(NC_Claim__c claimObj : trigger.new) {
            if(claimObj.NC_Corrections_completed__c == true) {
                correctionTasksSet.add(claimObj);
            }
            if(claimObj.NC_Corrective_actions_completed__c == true) {
                correctionActionTasksSet.add(claimObj);
            }
        }
        
        //Pass the claim records to the helper class for validation
        if(!correctionTasksSet.isEmpty()) {
            NC_Claim_Helper.correctionTasksValidation(correctionTasksSet);
        }
        if(!correctionActionTasksSet.isEmpty()) {
            NC_Claim_Helper.correctionActionTasksValidation(correctionActionTasksSet);
        }
        
        //Check if claim owner is updated on the claim
        for(NC_Claim__c claimObj : trigger.new) {
            if(claimObj.OwnerId!=Trigger.oldMap.get(claimObj.ID).OwnerId) {
                updateOwnerTasksSet.add(claimObj.id+'ownerId'+claimObj.OwnerId);
            }
        }
        if(!updateOwnerTasksSet.isEmpty()) {
            NC_Claim_Helper.updateRelatedTaskOwner(updateOwnerTasksSet);
        }
    }
    
    //populate claim record type if created form cases after insert 
    if(Trigger.isAfter && Trigger.isInsert) {
        
        Set<String> updateOwnerTasksSet = new Set<String>();
        
        Set<Id> newCliamId = Trigger.newMap.keyset();
        NC_Claim_Helper.populateRecordType(newCliamId);

        //populate case Id for manualy created claims
        NC_Claim_Helper.poopulateCaseId(newCliamId);
        
        for(NC_Claim__c claimObj : trigger.new) {
            updateOwnerTasksSet.add(claimObj.id+'ownerId'+claimObj.OwnerId);
        }
        if(!updateOwnerTasksSet.isEmpty()) {
            NC_Claim_Helper.updateRelatedTaskOwner(updateOwnerTasksSet);
        }      
    }
}