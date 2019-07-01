/**************************************************************************
 @Name : CGT_Batch_CreateTimeSheet
 @Description : This batch class creates Timesheet records for each day upfront. The number of Timesheet records to be created 
                is fetched from the custom setting "CGT_TimeSheet_Instance__c".
 @Developed by : ext.Leo.Johnson@cargotec.com
 @Created date : 20/11/2017
 
 @Last Modified : ext.manoj.gupta@cargotec.com
 @Date          : 24/11/2018
 @Reason        : check for resource personnel number was replaced by its ExternalId

**************************************************************************/



public class CGT_BatchCreateTimeSheet implements Database.Batchable<sObject>{
       
    
     /**********************************************************************
     Creating an instance of custom metadata-type which stores the details regarding
     number of Timesheet records to be created
     ***********************************************************************/   
     list<CGT_TimeSheet_Instance_data__mdt> tid = new list<CGT_TimeSheet_Instance_data__mdt>([Select CGT_Number__c from CGT_TimeSheet_Instance_data__mdt LIMIT 1]);
     Decimal timesheet_instances = tid[0].CGT_Number__c;
        
                 
     public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([ SELECT Id,CGT_Personnel_Number__c ,CGT_External_ID__c,RelatedRecordId FROM ServiceResource where IsActive = true]);  
     }

    
     public void execute(Database.BatchableContext BC, List<ServiceResource> scope) {
        List<TimeSheet> tsList = new List<TimeSheet>();
        Integer startDateYear = Integer.valueOf(System.Label.CGT_Timesheet_StartDate_Year);
        Integer startDateMonth = Integer.valueOf(System.Label.CGT_Timesheet_StartDate_Month);
        Integer startDateDay = Integer.valueOf(System.Label.CGT_Timesheet_StartDate_Day);
          
        for(ServiceResource sr : scope){ 
                                                
             String extid         = sr.CGT_External_ID__c;              
            /**************************************************************************
             This for-loop will create 'TimeSheet' instances for the Service Resource, 
             whose 'Personnel number' is not null and populating External Id and OwnerId field 
            **************************************************************************/
            for(Integer i=0;i<timesheet_instances ;i++){
                
                if(extid !=null && extid !=''){
                    Date dateInst;
                    if(System.Label.CGT_TimeSheetFirstBatch == 'Yes'){
                        dateInst = CGT_FSM_Utility.timeSheetStartDate(date.newInstance(startDateYear, startDateMonth, startDateDay)).addDays(i*7);
                    }else{
                        dateInst= CGT_FSM_Utility.timeSheetStartDate(Date.today()).addDays(i*7);
                    }
                    String day= dateInst.day() <=9 ?'0'+String.valueof(dateInst.day()):String.valueof(dateInst.day());
                    String month= dateInst.month() <=9?'0'+String.valueof(dateInst.month()):String.valueof(dateInst.month());
                    String datestring = day+month+String.valueof(dateInst.year());
                    System.debug(datestring);
                    TimeSheet ts = new TimeSheet(ServiceResourceId = sr.Id ,CGT_External_ID__c = extid+'_'+datestring , StartDate = dateInst,EndDate = dateInst.addDays(6) ,OwnerId = sr.RelatedRecordId);                                                    
                    tsList.add(ts);
                }
            }
        }
                                     
                if(!tsList.isEmpty()) {           
                   
                    Database.SaveResult[] srList = Database.insert(tsList, false);
                    String logMessageString='';  
                    for (Database.SaveResult sr : srList) {
                        
                      if (sr.isSuccess()) {
                          // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                            logMessageString+= 'Success record id :'+ sr.getId() +','+'\n';
                            }
                      else {
                             // Operation failed, so get all errors                                                                                                                                                                                   
                                for(Database.Error err : sr.getErrors()) {
                                    logMessageString+= err.getMessage()+','+'\n';
                                }
                            }                        
                    }
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Info, 'CGT_BatchCreateTimeSheet Class has been executed inserting timesheet','',logMessageString,'', true);                                
                }            
      }
    
    public void finish(Database.BatchableContext BC) {
                
        AsyncApexJob aj = [SELECT id, ApexClassId, 
                       JobItemsProcessed, TotalJobItems, 
                       NumberOfErrors, CreatedBy.Email 
                       FROM AsyncApexJob 
                       WHERE id = :BC.getJobId()];
                        
        String jip = String.valueOf(aj.JobItemsProcessed);
        String tji = String.valueOf(aj.TotalJobItems);
        String noe = String.valueOf(aj.NumberOfErrors);

        try{            
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Info,'CGT_BatchCreateTimeSheet has finished ', jip, tji, noe ,aj, true);           
          }catch(DmlException errorMessage){
                    LOG_LogMessageUtility.logMessage(errorMessage,'CGT_BatchCreateTimeSheet','finish','Error happened while logging AsyncApexJob records',true );
             }             

    }    
       
}