/*
    @Author: Tieto
    @Trigger Name: CGT_ShipyardVesselNodeTrigger
    @Created Date: 5th July 2018
    @Description: This class is used to test the functionality of creating Opportunity vesel node,
     deleting the opportunity vessel node when similar actions are performed on shipyard project vessel nodes and 
     cascading of asset field of shipyard vessel node to opportunity vessel node.
*/
trigger CGT_ShipyardVesselNodeTrigger on CGT_Vessel_Node_Shipyard_Project__c (after insert,before delete, after update) {
    
    if(Trigger.isAfter)
    {
         //Insert opportunity vessel node for newly created shipyard vessel node
        if(Trigger.isInsert) {
            CGT_ShipyardVesselNodeTrigger_Handler.createOpportunityVesselNodes(trigger.new);
        }
        
        if(Trigger.isUpdate)
        {
            CGT_ShipyardVesselNodeTrigger_Handler.syncOpportunityVesselNodesOnUpdate(trigger.newMap, trigger.oldMap);
        }
    }
   
    if(Trigger.isBefore)
    {
        //Delet the opportunity vessel nodes upon deletion of a shipyard vessel node
        if(Trigger.isDelete) {
            CGT_ShipyardVesselNodeTrigger_Handler.deleteOpportunityVesselNodes(trigger.old);
        }
    }
    
}