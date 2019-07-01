/********************************************************************************************************
* @Author         ext.chandrakanth.reddy@cargotec.com
* @Description    Trigger on AssignedResource Object
* @TriggerHandler CGT_AssignedResource_Handler 
* @TestClass      <TBC>
* @CreatedDate    05-07-2018

*********************************************************************************************************/

trigger CGT_AssignedResource_Trigger on AssignedResource (before insert, before update,after insert,after update) {
    
    if(trigger.isBefore ){
        if(trigger.isInsert || trigger.isUpdate){
            CGT_AssignedResource_Handler.checkServiceTerritory_WO(Trigger.new);
         }
   }
   
}