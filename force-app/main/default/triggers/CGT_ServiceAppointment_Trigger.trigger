/********************************************************************************************************
    * @author    
    * @date          07-10-2018
    * @description   This trigger is to be executed whenever the Service Appointment is inserted or Updated, the Duration field gets populated
                     based on the Start and End Date
    * @Events        before insert,before Update
    
    *********************************************************************************************************/   
 trigger CGT_ServiceAppointment_Trigger on ServiceAppointment (before insert,before update) {
   if(trigger.isbefore){
        if(trigger.isUpdate){
           CGT_ServiceAppointment_Handler.updateDuration(Trigger.new);
        }
  
        if(trigger.isInsert){
           CGT_ServiceAppointment_Handler.insertDuration(Trigger.new);
        }      
  }
}