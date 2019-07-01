/********************************************************************************************************
* @Author         ext.chandan.singh@cargotec.com
* @Description    Trigger on WorkLineItemOrder Object
* @TriggerHandler CGT_WorkOrderLineItem_Handler 
* @CreatedDate    25-01-2019
* @ModifiedDate   

*********************************************************************************************************/
trigger CGT_WorkOrderLineItemTriggger on WorkOrderLIneItem (before insert, after insert, before update,after update) {
     
     if(Trigger.isBefore){
        if(trigger.isInsert){
            CGT_WorkOrderLineItem_Handler.calculateDurationwoli(Trigger.new,Trigger.oldMap,true,false);
            CGT_WorkOrderLineItem_Handler.populatedefaultworkCenter(Trigger.new);
         }
    }
}