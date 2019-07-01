/********************************************************************************************************
* @author         Tieto
* @description    Time Sheet Management Class
* @date           2019-03-20
* @group          Time Sheet
*********************************************************************************************************/
public class CGT_TimeSheetManagement {
    public static String subcontractorTimesheetId ;
    public static void beforeInsertTSEFieldUpdates(List<TimeSheetEntry> tseList){
        if(CGT_FSM_Utility.isNotAfterInsert){
            Set<Id> woIdSet = new Set<Id>();
            Set<Id> woliIdSet = new Set<Id>();
            Map<Id,Id> tseIdtosrIdMap = new Map<Id,Id>(); // added for pre filled Service Resource.
            Set<Id> srIdSet = new Set<Id>(); 
            Map<Id, Id> woIdwoliIdMap = new Map<Id, Id>();
            Map<Id, Id> woliSAIdMap = new Map<Id, Id>();
            Map<Id, Id> saSRIdMap = new Map<Id, Id>();
            Map<String, Id> srDateTSIdMap = new Map<String, Id>();
            Map<Id, String> srNameMap = new Map<Id, String>();
            Map<String, Id> timesheetNameTSIdMap = new Map<String, Id>();
            Map<Id, String> recordtypeIdNameMap = new Map<Id, String>();
            
            Date minDT;
            Date maxDT;
            
            // Retrieve the set of Woli Ids
            for(TimeSheetEntry tse : tseList)
            {
                woIdSet.add(tse.WorkOrderId);
                if(tse.StartTime != null){
                if(minDT ==  null)
                {
                    minDT = tse.StartTime.date();
                }
                else if (minDT > tse.StartTime.date())
                {
                    minDT = tse.StartTime.date();
                }
                }
                if(tse.EndTime != null){
                
                if(maxDT ==  null)
                {
                    maxDT = tse.EndTime.date();
                }
                else if (maxDT < tse.EndTime.date())
                {
                    maxDT = tse.EndTime.date();
                }
                
                }
                if(tse.CGT_Service_Resource_Name__c != null){
                    tseIdtosrIdMap.put(tse.Id,tse.CGT_Service_Resource_Name__c);
                    srIdSet.add(tse.CGT_Service_Resource_Name__c);
                }
            }
            
            List<ServiceResource> srList =  [SELECT
                                                Id,Name
                                                FROM
                                                ServiceResource
                                                WHERE
                                                Id IN :tseIdtosrIdMap.Values() 
                                            ];
            for(ServiceResource sr:srList){
                srNameMap.put(sr.Id,sr.Name);
            }
            
            // Retrieve the required woli data
            List<WorkOrder> workOrderList = [SELECT
                                                Id,(Select Id from WorkOrderLineItems)
                                                FROM
                                                WorkOrder
                                                WHERE
                                                Id IN :woIdSet
                                            ];
            
            // Process the retrieved woli data
            for(WorkOrder wo : workOrderList)
            {   if(wo.WorkOrderLineItems != null){
                    woIdwoliIdMap.put(wo.id,wo.WorkOrderLineItems[0].Id);
                    woliIdSet.add(wo.WorkOrderLineItems[0].Id);
                }
            }
            
            // Retrieve the required SA data
            List<ServiceAppointment> saList = [
                                                SELECT
                                                        Id,
                                                        ParentRecordId
                                                FROM
                                                        ServiceAppointment
                                                WHERE
                                                        ParentRecordId IN :woliIdSet AND Status != 'Canceled'                  
            ];
            
            
            // Process the retrieved sa data
            for(ServiceAppointment sa : saList)
            {
                woliSAIdMap.put(sa.ParentRecordId, sa.id);
            }
            
            // Retrieve the required Assigned Service Resource data
            List<AssignedResource> arList = [
                                                SELECT
                                                        ServiceAppointmentId,
                                                        ServiceResourceId,
                                                        ServiceResource.Name
                                                FROM
                                                        AssignedResource
                                                WHERE
                                                        ServiceAppointmentId IN :woliSAIdMap.values()
                                            ];
            
            // Process the retrieved Assigned Service Resource data
            for(AssignedResource ar : arList)
            {   if (!srIdSet.contains(ar.Id)){
                    saSRIdMap.put(ar.ServiceAppointmentId, ar.ServiceResourceId);
                    srNameMap.put(ar.ServiceResourceId, ar.ServiceResource.Name);
                    srIdSet.add(ar.ServiceResourceId);
                }
            }
            
            // Retrieve Time Sheet information
            Date minimumDate = CGT_FSM_Utility.timeSheetStartDate(minDT);
            Date maximumDate = CGT_FSM_Utility.timeSheetStartDate(maxDT);
            List<TimeSheet> tsList = [
                                        SELECT
                                                Id,
                                                ServiceResourceId,
                                                StartDate,
                                                TimeSheetNumber
                                        FROM
                                                TimeSheet
                                        WHERE
                                                ((ServiceResourceId IN :srIdSet
                                                AND
                                                StartDate >= :minimumDate
                                                AND
                                                StartDate <= :maximumDate) OR TimeSheetNumber = :system.label.CGT_SubContractorTimeSheet)
                                                 
                                    ];

            
                                    
                // Process the retrieved Assigned Service Resource data
                for(TimeSheet ts : tsList)
                {
                    srDateTSIdMap.put(ts.ServiceResourceId+''+ts.StartDate, ts.id);
                    if(ts.TimeSheetNumber == system.label.CGT_SubContractorTimeSheet){
                        subcontractorTimesheetId = ts.Id;
                    }
                    
                }
                
                //getting TimesheetEntry RecordtypeName
                List<RecordType> rtList = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType='TimesheetEntry'];
                for(RecordType rt:rtList){
                    recordtypeIdNameMap.put(rt.Id,rt.DeveloperName);
                }
                
                // Update the TSE values
                    for(TimeSheetEntry tse : tseList){           
                        tse.WorkOrderLineItemId = woIdwoliIdMap.get(tse.WorkOrderId);
                        if(recordtypeIdNameMap.containsKey(tse.RecordTypeId) && recordtypeIdNameMap.get(tse.RecordTypeId) != 'CGT_Subcontractor'){
                            if(tseIdtosrIdMap.containsKey(tse.Id) && tseIdtosrIdMap.get(tse.Id) != null){
                                if(tse.startTime!=null){
                                    if((srDateTSIdMap.get(tseIdtosrIdMap.get(tse.Id) + '' + CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.date())) == null) && (tse.recordType.Name == system.label.CGT_TSE_RecordType )) {                                
                                        tse.addError(system.Label.CGT_TSE_NoTimesheet1 + ' ' +srNameMap.get(tseIdtosrIdMap.get(tse.Id)) + ' '+ system.Label.CGT_TSE_NoTimesheet2 + ' ' + CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.date()));
                                    } 
                                    else  if(tse.StartTime.date() <= system.Today().addDays(1) && (srDateTSIdMap.get(tseIdtosrIdMap.get(tse.Id) + '' + CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.date()))!= null)){ // modified for SFF-776                      
                                            tse.TimeSheetId = srDateTSIdMap.get(tseIdtosrIdMap.get(tse.Id) + '' + CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.date()));                                    
                                    }
                                    else if((srDateTSIdMap.get(tseIdtosrIdMap.get(tse.Id) + '' + CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.date())) != null)){
                                            tse.addError(system.Label.CGT_TSE_GreaterDate);
                                    }
                                }  
                                
                            }else{
                                tse.CGT_Service_Resource_Name__c = saSRIdMap.get(woliSAIdMap.get(tse.WorkOrderLineItemId));
                                if(tse.startTime!=null){
                                    if((srDateTSIdMap.get(saSRIdMap.get(woliSAIdMap.get(tse.WorkOrderLineItemId)) + '' + CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.date())) == null) && (tse.recordType.Name == system.label.CGT_TSE_RecordType )) {                                
                                        tse.addError(system.Label.CGT_TSE_NoTimesheet1 + ' ' +srNameMap.get(saSRIdMap.get(woliSAIdMap.get(tse.WorkOrderLineItemId))) + ' '+ system.Label.CGT_TSE_NoTimesheet2 + ' ' + CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.date()));
                                    } 
                                    else  if(tse.StartTime.date() <= system.Today().addDays(1) && (srDateTSIdMap.get(saSRIdMap.get(woliSAIdMap.get(tse.WorkOrderLineItemId)) + '' + CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.date()))!= null)){  // modified for SFF-776                  
                                            tse.TimeSheetId = srDateTSIdMap.get(saSRIdMap.get(woliSAIdMap.get(tse.WorkOrderLineItemId)) + '' + CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.date()));                                    
                                    }
                                    else if((srDateTSIdMap.get(saSRIdMap.get(woliSAIdMap.get(tse.WorkOrderLineItemId)) + '' + CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.date())) != null)){
                                            tse.addError(system.Label.CGT_TSE_GreaterDate);
                                    }
                                }  
                            }
                            if (recordtypeIdNameMap.containsKey(tse.RecordTypeId) && recordtypeIdNameMap.get(tse.RecordTypeId) == 'CGT_Direct'){        
                                tse.Type = 'Direct';
                            }else if (recordtypeIdNameMap.containsKey(tse.RecordTypeId) && recordtypeIdNameMap.get(tse.RecordTypeId) == 'CGT_Indirect'){
                                tse.Type = 'Indirect';
                            } else if (recordtypeIdNameMap.containsKey(tse.RecordTypeId) && recordtypeIdNameMap.get(tse.RecordTypeId) == 'CGT_Absence'){
                                tse.Type = 'Absence';
                            }
                        
                        }else if (recordtypeIdNameMap.containsKey(tse.RecordTypeId) && recordtypeIdNameMap.get(tse.RecordTypeId) == 'CGT_Subcontractor'){
                            tse.TimeSheetId = subcontractorTimesheetId;
                            tse.Type = 'Subcontractor';
                        }
                    
                    }
            
            
        }
    }
/********************************************************************************************************
* @author        Tieto 
* @description    Clone Time Sheet Entries
* @date           2019-03-25
* @group          Time Sheet
* @parameters     List<TimeSheetEntry> timesheetEntryList
*********************************************************************************************************/    
    public static void cloneTimeSheetEntries(List<TimeSheetEntry> timesheetEntryList ){ 
        List<TimeSheetEntry> newTseList = new List<TimeSheetEntry>();
        for(TimeSheetEntry tse :timesheetEntryList){
            if(tse.Clone_for_Days__c != null){
                for(String tseDay: tse.Clone_for_Days__c.Split(';')){
                    Date startDate;
                    TimesheetEntry newTse = new TimesheetEntry();
                    if(tseDay.equalsIgnoreCase(CGT_FSM_Utility.CGT_Monday)){
                        startDate = CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.Date());
                    }
                    if(tseDay.equalsIgnoreCase(CGT_FSM_Utility.CGT_Tuesday)){
                        startDate = CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.Date()).addDays(1);
                    }
                    if(tseDay.equalsIgnoreCase(CGT_FSM_Utility.CGT_Wednesday)){
                        startDate = CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.Date()).addDays(2);
                    }
                    if(tseDay.equalsIgnoreCase(CGT_FSM_Utility.CGT_Thursday)){
                        startDate = CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.Date()).addDays(3);
                    }
                    if(tseDay.equalsIgnoreCase(CGT_FSM_Utility.CGT_Friday)){
                        startDate = CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.Date()).addDays(4);
                    }
                    if(tseDay.equalsIgnoreCase(CGT_FSM_Utility.CGT_Saturday)){
                        startDate = CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.Date()).addDays(5);
                    }
                    if(tseDay.equalsIgnoreCase(CGT_FSM_Utility.CGT_Sunday)){
                        startDate = CGT_FSM_Utility.timeSheetStartDate(tse.StartTime.Date()).addDays(6);
                    }
                    newTse.TimeSheetId = tse.TimeSheetId;
                    newTse.CGT_Service_Resource_Name__c = tse.CGT_Service_Resource_Name__c;
                    newTse.CGT_No_of_persons__c = tse.CGT_No_of_persons__c;
                    newTse.CGT_Sub_Contractor__c = tse.CGT_Sub_Contractor__c;
                    newTse.Type = tse.Type;
                    newTse.RecordTypeId = tse.RecordTypeId;
                    newTse.CGT_Activity_Type__c = tse.CGT_Activity_Type__c;
                    newTse.CGT_Travel_Time__c = tse.CGT_Travel_Time__c;
                    newTse.WorkOrderLineItemId = tse.WorkOrderLineItemId;
                    newTse.WorkOrderId = tse.WorkOrderId;
                    newTse.StartTime = DateTime.newInstance(startDate, tse.StartTime.Time()); 
                    newTse.EndTime = newTse.StartTime.addMinutes(tse.DurationInMinutes);
                    newTseList.add(newTse);
                }
            }

        }
        try{ 
            if(!newTseList.isEmpty()){
                CGT_FSM_Utility.isNotAfterInsert = false;
                insert newTseList;
            }
        }catch(DmlException errorMessage){
                        LOG_LogMessageUtility.logMessage(errorMessage,'CGT_TimeSheetManagement','cloneTimeSheetEntries','Error happened while cloning Time sheet Entry',true );
        } 
    }       

 
    
/********************************************************************************************************
* @author        Nawal 
* @description    Delete time sheet entry method
* @date           2019-02-01
* @group          Time Sheet
*********************************************************************************************************/    
    public static void deleteTimeSheetEntries(List<TimeSheetEntry> lstTSEntries){
        list<TimeSheetEntry> tseLstToDelete = new list<TimeSheetEntry>();
        for(TimeSheetEntry tse:lstTSEntries){
            if(tse.CGT_Is_Delete__c && tse.CGT_External_Id__c == null && tse.CGT_Integration_Message__c==null ){
                tseLstToDelete.add(new TimeSheetEntry(id=tse.Id));
            }
        }
        if(!tseLstToDelete.isEmpty()){
            database.delete(tseLstToDelete);
        }
    }
    
/********************************************************************************************************
* @author        Tieto 
* @description    Updating status to Submitted when StartTime and EndTime are added.
* @date           2019-02-01
* @group          Time Sheet
*********************************************************************************************************/    
    public static void updateTimeSheetEntryStatus(List<TimeSheetEntry> lstTSEntries){

        for(TimeSheetEntry tse:lstTSEntries){
            if(tse.StartTime!=null && tse.EndTime != null && tse.Status=='New' ){
               tse.Status='Submitted';
            }
        }
        
    }
    
}