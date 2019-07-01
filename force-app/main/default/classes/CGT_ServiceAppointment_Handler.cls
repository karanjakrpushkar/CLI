/********************************************************************************************************
* @author         
* @date           07-10-2018
* @description    Handler class for CGT_ServiceAppointment_Trigger.
          Class has method which sets the duration field to value set by the user.
*                 
*********************************************************************************************************/
public class CGT_ServiceAppointment_Handler {
   
  /********************************************************************************************************
    * @author    
    * @date          07-10-2018
    * @description   This method is executed whenever the Service Appointment is inserted, the Duration field gets populated
                     based on the Start and End Date
    * @param         List<ServiceAppointment>
    * @return        Void
    *********************************************************************************************************/   
    public static void insertDuration(List<ServiceAppointment> saList)
    {
     
        for(ServiceAppointment sa:saList)
        {  
		    if(sa.SchedEndTime != null && sa.SchedStartTime!= null){ 
                    sa.CGT_Duration__c = CGT_FSM_Utility.calculateDuration (sa.SchedStartTime,sa.SchedEndTime,sa.DurationType);
                    sa.Duration=sa.CGT_Duration__c;
            }
        }
                
    }
  /********************************************************************************************************
    * @author    
    * @date          07-10-2018
    * @description   This method is executed whenever the Service Appointment is updated, the Duration field gets populated
                     based on the Start and End Date
    * @param         List<ServiceAppointment>
    * @return        Void
    * ModifiedDate : Modified on 01-02-2019 because calculation logic is moved in CGT_FSM_Utility Class.
    *********************************************************************************************************/     
    public static void updateDuration(List<ServiceAppointment> saList){
        for(ServiceAppointment sa:saList){   
            if(sa.CGT_TF_SchedEndDate__c != null && sa.SchedStartTime!= null){
                sa.SchedEndTime =sa.CGT_TF_SchedEndDate__c;
                sa.CGT_Duration__c = CGT_FSM_Utility.calculateDuration (sa.SchedStartTime,sa.SchedEndTime,sa.DurationType);
                sa.Duration=sa.CGT_Duration__c;
            }
        }
                
    }
    
}