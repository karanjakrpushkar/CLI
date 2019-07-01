/*
    @Author: Tieto
    @Class Name: NC_TaskTrigger_Handler
    @Created Date: 17th April 2019
    @Description: This class is used to update the claim owner of the task.
*/

public class NC_TaskTrigger_Handler {
    
    /*
        @Author: Tieto
        @Method Name: updateClaimOwner
        @Description: This method is used for updating the claim owner field on the task.
    */
    
    public static void updateClaimOwner(List<Task> taskList) {
        try {
        
            List<Task> updateTaskList = new List<Task>();
            
            List<ID> taskIds = new List<ID>();
            
            for(Task obj : taskList) {
                taskIds.add(obj.WhatId);
            }
            
            List<NC_Claim__c> claimList = [select id,Owner.email from NC_Claim__c where ID IN : taskIds];
            
            Map<Id,String> claimMap = new Map<Id,String>();
            
            for(NC_Claim__c claimObj : claimList) {
                claimMap.put(claimObj.id,claimObj.Owner.email);
            }
            
            for(Task obj : taskList) {
                if(obj.NC_Claim_Owner_Email__c!=claimMap.get(obj.WhatId)) {
                    obj.NC_Claim_Owner_Email__c = claimMap.get(obj.WhatId);
                    updateTaskList.add(obj);
                }
            }
            
            if(!updateTaskList.isEmpty()) {
                update taskList;
            }
        
        }
        catch(Exception e) {
            LOG_LogMessageUtility.logMessage(e,'NC Tool-NC_TaskTrigger_Handler','updateClaimOwner','Failed to display errors while updating the claim owner of a task',true);
        }
    }
}