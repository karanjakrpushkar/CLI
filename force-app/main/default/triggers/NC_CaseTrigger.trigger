trigger NC_CaseTrigger on Case (before insert, after insert) {
    
    //populate record type of cases based on input from google form
    if(Trigger.isBefore && Trigger.isInsert){
        NC_CaseHelper.assignRecordType(Trigger.new);
        
    }
    
    //get file attachments from external object based on unique file Id from google form
    if(Trigger.isAfter && Trigger.isInsert){
       set<id> keys = Trigger.newMap.keyset();
        NC_CaseHelper.getFileAttachment(keys); 
    }
}