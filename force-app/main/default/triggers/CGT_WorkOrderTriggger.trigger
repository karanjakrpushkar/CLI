/********************************************************************************************************
* @Author         ext.chandrakanth.reddy@cargotec.com
                  ext.leo.johnson@cargotec.com
* @Description    Trigger on WorkOrder Object
* @TriggerHandler CGT_WorkOrder_Handler 
* @TestClass      <TBC>
* @CreatedDate    05-07-2018
* @ModifiedDate    07-10-2018 for US SF-2314

*********************************************************************************************************/

trigger CGT_WorkOrderTriggger on WorkOrder (before insert, after insert, before update,after update) {
     
     if(Trigger.isBefore){
        if(Trigger.isUpdate){
            CGT_WorkOrder_Handler.workorderValidation(Trigger.new,Trigger.oldMap);
            CGT_WorkOrder_Handler.calculateDurationWO(Trigger.new,Trigger.oldMap,false,true);
            CGT_WorkOrder_Handler.externalWOLIfieldValidation(Trigger.newMap,Trigger.oldMap);
        }
        // added for US SF-2314 #Start
        if(trigger.isInsert){
            CGT_WorkOrder_Handler.autoPopulateTerritory(Trigger.new);
            CGT_WorkOrder_Handler.calculateDurationWO(Trigger.new,Trigger.oldMap,true,false);
        }
        // added for US SF-2314 #END
     }
     if(Trigger.isAfter){
        if(Trigger.isUpdate){
            
            CGT_WorkOrder_Handler.updateCase_ClosedWO(Trigger.new,Trigger.oldMap);
        }
        // added for US SF-2314 #Start
        if(trigger.isInsert){
            list<WorkOrder> woList=new List<WorkOrder>();
                for(WorkOrder wo:Trigger.new)
                {
                    if( String.isEmpty(wo.CGT_External_ID__c))
                    {
                        woList.add(wo);
                    }
                }
                if(!woList.isEmpty()){
                    CGT_workOrder_Handler.autoCreateWOLI(woList);
                      
                }
                CGT_WorkOrder_Handler.autoCreateOpportunity(Trigger.new);
                
            }
          
            // added for US SF-2314 #END
     }
}