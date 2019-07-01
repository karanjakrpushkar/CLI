/********************************************************************************************************
* @Author         ext.chandrakanth.reddy@cargotec.com
* @Description    This is a handler class for CGT_AssignedResource_Trigger trigger
* @TestClass      <TBD>
* @CreatedDate    05-07-2018

*********************************************************************************************************/

public with sharing class CGT_AssignedResource_Handler {


/********************************************************************************************************
* @Author         ext.chandrakanth.reddy@cargotec.com
* @Method          checkServiceTerritory_WO
* @Parameters      List<AssignedResource>
* @description     This method is used for updating the service Territory of Service Appoinment based on the Assigned resources active territory
* @CreatedDate    05-07-2018

*********************************************************************************************************/
   
   public static void checkServiceTerritory_WO (List<AssignedResource> list_AssignedResource){
        Set<Id> saId_set= new Set<Id>();
        Set<Id>serviceResource_Set= new Set<Id>();
        Map<Id,Set<Id>> serviceT_map=new Map<Id,Set<Id>>();
        Map<String,String> serviceResourceToWorkcenterMap= new Map<String,String>();
        Map<String,Map<String,ServiceTerritoryMember>> resourceToMemebershipMap= new Map<String,Map<String,ServiceTerritoryMember>>();
        //Loop through the list of records to store the SaID and srID into the sets
        for(AssignedResource Ar : list_AssignedResource){
            saId_set.add(Ar.ServiceAppointmentId);
            serviceResource_Set.add(Ar.serviceResourceId);
        }
        List<ServiceResource> serviceResourceList=[SELECT Id,LocationId,Location.ParentLocationId,CGT_External_Id__c
                                                                               FROM ServiceResource Where ID IN:serviceResource_Set];

        Map<Id,ServiceResource> serviceResourceMap= new Map<Id,ServiceResource>(serviceResourceList);
   /*Query all the service territory members related to service resource where effective end date is 
   greater than the service appointment scheduled end date or Null. */

        List<ServiceTerritoryMember> sTerritory_list=[
                                                        SELECT 
                                                            Id,ServiceResourceId,ServiceTerritoryId,ServiceTerritory.ParentTerritoryId,ServiceTerritory.CGT_Default_Work_Center__c,
                                                            ServiceResource.LocationId,ServiceResource.Location.ParentLocationId,
                                                            ServiceResource.CGT_External_Id__c
                                                        FROM 
                                                            ServiceTerritoryMember 
                                                        WHERE 
                                                            ServiceResourceId 
                                                        IN :serviceResource_Set 
                                                        AND  
                                                            (EffectiveEndDate >= today OR EffectiveEndDate = Null )
                                                    ];
        for(ServiceTerritoryMember stm : sTerritory_list){
            if(!resourceToMemebershipMap.containsKey(stm.ServiceResourceId)){
                resourceToMemebershipMap.put(stm.ServiceResourceId,new Map<String,ServiceTerritoryMember>{stm.Id =>stm});
            }else{
                if(!resourceToMemebershipMap.get(stm.ServiceResourceId).containsKey(stm.Id)){
                    resourceToMemebershipMap.get(stm.ServiceResourceId).put(stm.Id,stm);
                }
            }
            if(serviceT_map.containsKey(stm.serviceResourceId))
                serviceT_map.get(stm.serviceResourceId).add(stm.ServiceTerritoryId);
            else{
                Set<Id> sTerritory_set= new Set<Id>();
                sTerritory_set.add(stm.ServiceTerritoryId);
                serviceT_map.put(stm.serviceResourceId,sTerritory_set);
            }
            if(String.isNotBlank(stm.ServiceTerritory.ParentTerritoryId)){ 
                // Adding the parent serviceterritory Id to the set.
                serviceT_map.get(stm.serviceResourceId).add(stm.ServiceTerritory.ParentTerritoryId);
                if(!serviceResourceToWorkcenterMap.containsKey(stm.ServiceResourceId)){
                    serviceResourceToWorkcenterMap.put(stm.ServiceResourceId,stm.ServiceTerritoryId);
                }
            }
        }
        //Query work order line items service territory via service appointment query
        List<ServiceAppointment> sa_List=[
                                            SELECT 
                                                Id,CGT_Work_Order_Line_Item__r.Id,CGT_Work_Order_Line_Item__r.WorkOrder.ServiceTerritoryId,
                                                CGT_Work_Order_Line_Item__r.ServiceTerritoryId,CGT_Work_Order_Line_Item__r.ServiceTerritory.ParentTerritoryId,CGT_Work_Order_Line_Item__r.WorkOrder.CGT_External_ID__c,CGT_Work_Order_Line_Item__r.WorkOrder.Id,
                                                SchedStartTime,SchedEndTime,Duration,DurationType,Status 
                                            FROM     
                                                ServiceAppointment 
                                            WHERE
                                                Id 
                                            IN :saId_set
                                        ]; // added CGT_Work_Order_Line_Item__r.WorkOrder.CGT_External_ID__c in query.

        Map<Id,ServiceAppointment> sa_Map= new Map<Id,ServiceAppointment>(sa_List);
        List<WorkOrderLineItem> woliToBeUpdated= new List<WorkOrderLineItem>();
        List<WorkOrder> woToBeUpdated= new List<WorkOrder>();
        for(AssignedResource ar : list_AssignedResource){
            Boolean isServiceTerritoryValid=False; 
            //Check if there is a service territory member entry for the assigned resource.
            if(serviceT_map.containsKey(ar.serviceResourceId)){
                Set<Id> serviceT_id=serviceT_map.get(ar.serviceResourceId);
                if(sa_Map.containsKey(ar.ServiceAppointmentId)){
                    ServiceAppointment sa= sa_Map.get(ar.ServiceAppointmentId);
                    // check if the set serviceT_id contains the work order line items Service territory
                    if(String.isNotBlank(sa.CGT_Work_Order_Line_Item__r.WorkOrder.ServiceTerritoryId)){
                        if(!resourceToMemebershipMap.get(ar.serviceResourceId).isEmpty()){
                            for(ServiceTerritoryMember stm:resourceToMemebershipMap.get(ar.serviceResourceId).values()){
                                if(String.isNotBlank(stm.ServiceTerritory.ParentTerritoryId)){
                                    if(stm.ServiceTerritory.ParentTerritoryId == sa.CGT_Work_Order_Line_Item__r.WorkOrder.ServiceTerritoryId){
                                        isServiceTerritoryValid=true;
                                    }
                                }else{
                                    if(stm.ServiceTerritoryId == sa.CGT_Work_Order_Line_Item__r.WorkOrder.ServiceTerritoryId){
                                        isServiceTerritoryValid=true;
                                    }
                                }
                                if(!isServiceTerritoryValid && sa.CGT_Work_Order_Line_Item__r.WorkOrder.CGT_External_ID__c == null){
                                    WorkOrder wo = new WorkOrder (Id=sa.CGT_Work_Order_Line_Item__r.WorkOrder.Id);
                                    if(stm.ServiceTerritory.ParentTerritoryId != null){
                                        wo.ServiceTerritoryId = stm.ServiceTerritory.ParentTerritoryId;
                                    }else if(stm.ServiceTerritoryId != null){
                                        wo.ServiceTerritoryId = stm.ServiceTerritoryId;
                                    }
                                    woToBeUpdated.add(wo);
                                    isServiceTerritoryValid=true;
                                }
                            }
                            if(isServiceTerritoryValid){
                                WorkOrderLineItem woliInst= new WorkOrderLineItem(Id=sa.CGT_Work_Order_Line_Item__r.Id);
                                woliInst.ServiceTerritoryId=serviceResourceToWorkcenterMap.get(ar.serviceResourceId);
                                String srId=ar.serviceResourceId;
                                woliInst.CGT_Storage_Location__c=String.IsBlank(serviceResourceMap.get(srId).Location.ParentLocationId)?serviceResourceMap.get(srId).LocationId:serviceResourceMap.get(srId).Location.ParentLocationId ; // need to change 
                                woliInst.CGT_Technician_Personnel_Number__c=serviceResourceMap.get(srId).CGT_External_Id__c;
                                woliInst.StartDate=sa.SchedStartTime;
                                woliInst.EndDate=sa.SchedEndTime;
                                woliInst.Duration=sa.Duration;
                                woliInst.DurationType = sa.DurationType;
                               // woliInst.CGT_Scheduling_Status__c=(sa.Status=='Scheduled' || sa.Status=='Dispatched') ? sa.Status : 'Created';
                                woliToBeUpdated.add(woliInst); 
                        
                            }
                            
                        }
                    }
                }   
            }
            
            if(!isServiceTerritoryValid) 
                ar.adderror(system.Label.CGT_Error_Territory_Schedule_Other_Than_WO_ST); 
        }
        if(!woliToBeUpdated.isEmpty() || !woToBeUpdated.isEmpty()){
            try{
                if(!woToBeUpdated.isEmpty()){
                    Update woToBeUpdated;
                }
                
                if(!woliToBeUpdated.isEmpty()){
                    Update woliToBeUpdated;
                }
               
            }catch(DmlException dmlex){
                LOG_LogMessageUtility.logMessage(dmlex,'CGT_AssignedResource_Handler','checkServiceTerritory_WO','work center update to WOLI failed.',true);
            }
        }
        
    }
}