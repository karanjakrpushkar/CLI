Trigger CGT_TimeSheetEntry_Trigger on TimeSheetEntry (before insert,after insert,before update,after update){

        
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            CGT_TimeSheetManagement.beforeInsertTSEFieldUpdates(Trigger.new);
            CGT_TimeSheetManagement.updateTimeSheetEntryStatus(Trigger.new);
        }
        if(Trigger.isUpdate){
            
            CGT_TimeSheetManagement.updateTimeSheetEntryStatus(Trigger.new);
        }
        
    }
    if(Trigger.isAfter ){
        if(trigger.isInsert){
            CGT_TimeSheetManagement.cloneTimeSheetEntries(Trigger.new);
        }
        if(trigger.isUpdate){
           CGT_TimeSheetManagement.deleteTimeSheetEntries(Trigger.new);
        }
    }
    
    
}