/*****************************************************************************************************
 *
 * Author       : Tieto India Pvt Ltd
 * Created Date : 21st May 2018
 * Purpose      : This is helper class for NC_ClaimTrigger 
 * Modified By : 
 * Purpose     : Helper methods for Claim Trigger. 
 ******************************************************************************************************/
public class NC_Claim_Helper {

    private Static FINAL String STR_STATUS_CLOSED = 'Closed';
    private Static FINAL String STR_STATUS_DISCARDED = 'Discarded';
    private Static FINAL String STR_VAL_ERROR_MSG = 'Claim with open related Tasks can not be closed or Discarded';
    //private Static FINAL String STR_VAL_ERROR_MSG1 = 'Claim can not be closed or discarded, if the necessary activities have not been completed. Please verify that they are completed by selecting "Corrections completed" and "Corrective actions completed"';
    private Static FINAL String STR_CUST_REC_TYPE = 'NC Customer Claim';
    private Static FINAL String STR_VEND_REC_TYPE = 'NC Vendor Claim';
    private Static FINAL String STR_INT_REC_TYPE = 'NC Internal Claim';

    /******************************************************
     * validateClosedClaims Method to validate for open claims
     *******************************************************/

    public static void validateClosedClaims(List < NC_Claim__c > newClaims, Map < Id, NC_Claim__c > oldClaims) {
        Map < Id, Task > taskMap = new Map < Id, Task > ();

        //Qiery task with claim id's
        for (Task t: [SELECT Id, WhatId FROM Task WHERE IsClosed = false AND WhatId IN: trigger.newMap.keySet()]) {
            taskMap.put(t.WhatId, t);
        }

        //iterate through updated cases and add errors if open tasks exist

        for (NC_Claim__c obj: newClaims) {

            //check if the case has any open tasks and has just been changed to closed
            if (taskMap.containsKey(obj.Id) && (obj.NC_Status__c == STR_STATUS_CLOSED || obj.NC_Status__c == STR_STATUS_DISCARDED) && obj.NC_Status__c != oldClaims.get(obj.Id).NC_Status__c)
                obj.addError(STR_VAL_ERROR_MSG);
        }
    }

    /******************************************************
     * subClaimValidaiton Method to validate for open sub Claims.
     *******************************************************/

    public static void subClaimValidaiton(List < NC_Claim__c > newClaims, Map < Id, NC_Claim__c > oldCliams) {

        try {

            Map < Id, NC_Claim__c > childMap = new Map < Id, NC_Claim__c > ();

            //Query claims to get the subClaim
            List < NC_Claim__c > childClaims = [SELECT Id, NC_Status__c, NC_Parent_Claim__c FROM NC_Claim__c WHERE NC_Parent_Claim__c IN: newClaims AND NC_Status__c != 'Closed' AND NC_Status__c != 'Discarded'];

            //Iterate over the child list to populate collection
            for (NC_Claim__c obj: childClaims) {
                childMap.put(obj.NC_Parent_Claim__c, obj);
            }

            for (NC_Claim__c objClaim: newClaims) {
                if (childMap.containsKey(objClaim.Id) && (objClaim.NC_Status__c == STR_STATUS_CLOSED || objClaim.NC_Status__c == STR_STATUS_DISCARDED) && objClaim.NC_Status__c != oldCliams.get(objClaim.Id).NC_Status__c)
                    objClaim.addError(Label.NC_Claim_Close_Error);
            }
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    
    /******************************************************
     * correctionTasksValidation Method to validate for open Correction tasks.
     *******************************************************/

    public static void correctionTasksValidation(Set < NC_Claim__c > claimsSet) {

        try {

            Map < Id, Task > childMap = new Map < Id, Task > ();

            //Query tasks to get sub tasks for claims of type "Correction"
            List < Task > childTasks = [SELECT Id, NC_Claim_Task_Type__c,WhatId FROM Task WHERE NC_Claim_Task_Type__c = 'Correction' AND WhatID IN:claimsSet AND Status = 'Open'];

            //Iterate over the child list to populate collection
            for (Task obj: childTasks) {
                childMap.put(obj.WhatId, obj);
            }

            for (NC_Claim__c objClaim: claimsSet) {
                if (childMap.containsKey(objClaim.Id))
                    objClaim.addError(Label.NC_Correction_Task_Open_Error);
            }
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    
    /******************************************************
     * correctionActionTasksValidation Method to validate for open Corrective Action tasks.
     *******************************************************/

    public static void correctionActionTasksValidation(Set < NC_Claim__c > claimsSet) {

        try {

            Map < Id, Task > childMap = new Map < Id, Task > ();

            //Query tasks to get sub tasks for claims of type "Corrective Actions"
            List < Task > childTasks = [SELECT Id, NC_Claim_Task_Type__c,WhatId FROM Task WHERE NC_Claim_Task_Type__c = 'Corrective Action' AND WhatID IN:claimsSet AND Status = 'Open'];

            //Iterate over the child list to populate collection
            for (Task obj: childTasks) {
                childMap.put(obj.WhatId, obj);
            }

            for (NC_Claim__c objClaim: claimsSet) {
                if (childMap.containsKey(objClaim.Id))
                    objClaim.addError(Label.NC_Corrective_Action_Task_Open_Error);
            }
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    
    /*
        @Author: Tieto
        @Method Name: updateRelatedTaskOwner
        @Description: This method is used to copy attachments from parent claim to sub-claim on sub-claim creation.
    */
    public static void updateRelatedTaskOwner(Set<String> claimList) {
        try {
            
            List<Id> claimIds = new List<Id>();
            List<Id> ownerIds = new List<Id>();
            Map<Id,String> claimMap = new Map<Id,String>();
            Map<Id,String> ownerMap = new Map<Id,String>();
            
            for(String obj : claimList) {
                claimIds.add(obj.substringBefore('ownerId'));
                ownerIds.add(obj.substringAfter('ownerId'));
                claimMap.put(obj.substringBefore('ownerId'),obj.substringAfter('ownerId'));
            }
            
            List<User> userList = [select id,Email from User where id IN : ownerIds];
            for(User obj : userList) {
                ownerMap.put(obj.id,obj.Email);
            }
            
            List<Task> updateTaskList = new List<Task>();
            
            List<Task> taskList = [select id,WhatId,NC_Claim_Owner_Email__c from Task where WhatID IN : claimIds];
            
            for(Task taskObj : taskList) {
                taskObj.NC_Claim_Owner_Email__c = ownerMap.get(claimMap.get(taskObj.WhatId));
            }
            update taskList;
        
        } catch(Exception e) {
            System.debug('Exception = '+e);
        }
    }
    
     /*
        @Author: Tieto
        @Method Name: copyAttachmentsToSubClaim
        @Description: This method is used to copy attachments from parent claim to sub-claim on sub-claim creation.
    */
    
    @InvocableMethod
    public static void copyAttachmentsToSubClaim(List<List<NC_Claim__c>> subClaimList) {

        try {
        
            //Retrieve the parent claims of the sub-claims created
            
            Set<NC_Claim__c> subClaimObjList = new Set<NC_Claim__c>();
            Set<Id> claimParentIds = new Set<Id>();
            for(Integer i=0;i<subClaimList.size();i++) {
                List<NC_Claim__c> tmpClaimList = subClaimList[i];
                for(NC_Claim__c c : tmpClaimList) {
                    if(c.NC_Parent_Claim__c!=null) {
                        claimParentIds.add(c.NC_Parent_Claim__c);
                        subClaimObjList.add(c);
                    }
                }
            }
            
            //Get the attachments which are attached to the parent claims
            
            List<ContentDocumentLink> attachmentList = [select id,ContentDocumentId,LinkedEntityId,ShareType from ContentDocumentLink where LinkedEntityId IN : claimParentIds];
            
            Map<Id,List<ContentDocumentLink>> attachmentMap = new Map<Id,List<ContentDocumentLink>>();
            
            for(ContentDocumentLink obj : attachmentList) {
                if (attachmentMap.containsKey(obj.LinkedEntityId)) {
                    List < ContentDocumentLink > tmpList = attachmentMap.get(obj.LinkedEntityId);
                    tmpList.add(obj);
                    attachmentMap.put(obj.LinkedEntityId, tmpList);
                } else {
                    List < ContentDocumentLink > tmpList = new List < ContentDocumentLink > ();
                    tmpList.add(obj);
                    attachmentMap.put(obj.LinkedEntityId, tmpList);
                }
            }
            
            List<ContentDocumentLink> newContentDocumentLinks = new List<ContentDocumentLink>();
            
            //Copy all the attachments from the parent claim to the sub-claim
            
            for(NC_Claim__c claimObj : subClaimObjList) {
                List < ContentDocumentLink > documentList = attachmentMap.get(claimObj.NC_Parent_Claim__c);
                for(ContentDocumentLink doc : documentList) {
                    ContentDocumentLink newLink = new ContentDocumentLink();
                    newLink.ContentDocumentId = doc.ContentDocumentId;
                    newLink.LinkedEntityId = claimObj.id;
                    newLink.ShareType = 'V';
                    newContentDocumentLinks.add(newLink);
                }
            }
            
            insert newContentDocumentLinks;

        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    
    /******************************************************
     * Method to populate record type based on case record type.
     *******************************************************/

    public static void populateRecordType(Set < Id > newClaims) {
        //get the record type ids based on names
        try {

            Id customerRecordtypeId = Schema.SObjectType.NC_Claim__c.getRecordTypeInfosByName().get(STR_CUST_REC_TYPE).getRecordTypeId();
            Id internalRecrodtypeId = Schema.SObjectType.NC_Claim__c.getRecordTypeInfosByName().get(STR_INT_REC_TYPE).getRecordTypeId();
            Id vendorRecordTypeId = Schema.SObjectType.NC_Claim__c.getRecordTypeInfosByName().get(STR_VEND_REC_TYPE).getRecordTypeId();

            List < NC_Claim__c > newClaimsList = [SELECT Id, NC_Case__c, NC_Case__r.RecordTypeId, NC_Case__r.RecordType.Name, NC_Case__r.NC_Claim_type_from_form__c FROM NC_Claim__c WHERE Id IN: newClaims];
            List < NC_Claim__c > updatedClaims = new List < NC_Claim__c > ();

            Map < String, Id > recordTypeMap = new Map < String, Id > {
                'Customer' => customerRecordtypeId,
                'Internal' => internalRecrodtypeId,
                'Vendor' => vendorRecordTypeId
            };
            if (!newClaimsList.isEmpty())
                for (NC_Claim__c obj: newClaimsList) {
                    if (obj.NC_Case__c != null) {
                        String name = obj.NC_Case__r.NC_Claim_type_from_form__c;
                        if (! String.isBlank(name) && recordTypeMap.containsKey(name)) {
                            obj.RecordTypeId = recordTypeMap.get(name);
                            updatedClaims.add(obj);
                        }
                    }
                }
            update updatedClaims;
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

    }
    
    
    
    /******************************************************
    * Mehod to populate Date of Event perfectly w.r.t Locale
    *******************************************************/
     public static void dateFormate(List < NC_Claim__c > newClaims) {
         
         List<Case> caseList = [Select id,NC_Date_of_Event__c from case where id =: newClaims[0].NC_Case__c and NC_Created_From_Claim__c = false ];
    
      Map<String, Integer> monthsMap = new Map<String, Integer>{
   'Jan'  => 1,
       'Feb' => 2,
       'Mar' => 3,
       'Apr' => 4,
       'May' => 5,
       'Jun' => 6,
       'Jul' => 7,
       'Aug' => 8,
       'Sep' => 9,
       'Oct' => 10,
       'Nov' => 11,
       'Dec' => 12

       };
  if(caseList.size()>0 && caseList[0].NC_Date_of_Event__c!=null){
string s=caseList[0].NC_Date_of_Event__c;
string[] s1=s.split(' ');
string newDate= s1[5] + '-'  + monthsMap.get(s1[1]) + '-'  + s1[2] ;

System.debug('newDate>>>'+newDate);

newClaims[0].NC_Input_Date_Of_Event__c = Date.valueOf(newDate);
}

//date d= date.parse(newDate);
    
     }
    

    /******************************************************
     * Method to populate caes Id's on claim record
     *******************************************************/

    @future
    public static void poopulateCaseId(Set < Id > newClaims) {
        try {
            List < NC_Claim__c > cliamListUpd = new List < NC_Claim__c > ();

            //query claims to get the values
            List < NC_Claim__c > cliamList = [SELECT Id, NC_Case__c FROM NC_Claim__c WHERE Id IN: newClaims];

            //query cases with claim ids        
            List < Case > caseList = [SELECT Id, NC_Claim_Id__c FROM Case WHERE NC_Claim_Id__c IN: newClaims];
            system.debug('caseLIst ' + caseList);
            Map < String, Case > claimCaseMap = new Map < String, Case > ();

            //iterate over the caseList to populate colleciton
            if (!caseList.isEmpty())
                for (Case obj: caseList) {
                    claimCaseMap.put(obj.NC_Claim_Id__c, obj);
                }

            //udpate claim records with cases
            if (claimCaseMap != null && !caseList.isEmpty())
                for (NC_Claim__c cliamObj: cliamList) {
                    cliamObj.NC_Case__c = claimCaseMap.get(cliamObj.Id).Id;
                    cliamListUpd.add(cliamObj);
                }
            update cliamListUpd;
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

    }
}