/*
    @Author: Tieto
    @Trigger Name: NC_TaskTrigger
    @Created Date: 17th April 2019
    @Description: This trigger is used to update the Claim Owner on a Task if a created task is related to a Claim.
*/

trigger NC_TaskTrigger on Task (before insert,before update) {
    
    List<Task> taskList = new List<Task>();
    
    
    if(Trigger.isInsert) {
        for(Task obj : trigger.new) {
            if(obj.RecordType.DeveloperName == 'NC_Claim_Task' || obj.Consolidated_information__c != NULL) {
                taskList.add(obj);
            }
        }
    }
    
    if(Trigger.isUpdate) {
        for(Task obj : trigger.new) {
            
            task oldTask = Trigger.oldMap.get(obj.ID);

            if (obj.WhatId != oldTask.WhatId) {
                if(obj.RecordType.DeveloperName == 'NC_Claim_Task' || obj.Consolidated_information__c != NULL) {
                    taskList.add(obj);
                }
            }
        }
    }
    
    if(!taskList.isEmpty()) {
        NC_TaskTrigger_Handler.updateClaimOwner(taskList);
    }
}