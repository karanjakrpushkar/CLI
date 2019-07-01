/*
    @Author: Tieto
    @Trigger Name: CGT_OpportunityVesselNodeTrigger
    @Created Date: 26th July 2018
    @Description: This trigger is used to restrict the user from creating or deleting a vessel node directly in a shipyard project opportunity.
*/

trigger CGT_OpportunityVesselNodeTrigger on CGT_Vessel_Node_Opportunity__c(before insert,before delete) {
    
    if(trigger.isBefore){
        
        //Check if user is trying to create a vessel node
        
        if (trigger.isInsert) {
            CGT_OpportunityVesselNodeTrigger_Handler.restrictAction(trigger.new,'insert');
        }
        
        //Check if user is trying to delete a vessel node
        
        if(trigger.isDelete) {
            CGT_OpportunityVesselNodeTrigger_Handler.restrictAction(trigger.old,'delete');
        }
    }
    
}