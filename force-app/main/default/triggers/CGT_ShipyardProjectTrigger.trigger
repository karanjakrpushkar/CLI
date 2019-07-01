/*
    @Author: Tieto
    @Trigger Name: CGT_ShipyardProjectTrigger
    @Created Date: 12th July 2018
    @Description: This trigger is used to restrict user from closing shipyard projects having open opportunities and for cloning a Shipyard Project to create a "Options" Shipyard Project.
*/

trigger CGT_ShipyardProjectTrigger on CGT_Shipyard_Project__c (after insert,before update) {
    
    if(Trigger.isBefore) {
        if(Trigger.isUpdate) {
            
            //Logic to restrict user from closing shipyard projects having open opportunities
            
            List<CGT_Shipyard_Project__c> shipyardList = new List<CGT_Shipyard_Project__c>();
            for(CGT_Shipyard_Project__c projectObj : trigger.new) {
                if(projectObj.CGT_Project_Status__c=='Closed') {
                    shipyardList.add(projectObj);
                }
            }
            if(shipyardList!=null) {
                CGT_ShipyardProjectTrigger_Handler.showErrorForClosedStatus(shipyardList);
            }
            
            //Logic to clone a Shipyard Project to a Options Shipyard Project
            List<CGT_Shipyard_Project__c> originShipyardList = new List<CGT_Shipyard_Project__c>();
            
            for(CGT_Shipyard_Project__c shipyardObj : trigger.new) {
                if ((shipyardObj.CGT_Project_Status__c != Trigger.oldMap.get(shipyardObj.Id).CGT_Project_Status__c || shipyardObj.CGT_Number_of_Options__c != Trigger.oldMap.get(shipyardObj.Id).CGT_Number_of_Options__c ) && (shipyardObj.CGT_Project_Status__c == 'HOT' || shipyardObj.CGT_Project_Status__c == 'CLOSED') && (shipyardObj.CGT_Number_of_Options__c > 0) && (shipyardObj.CGT_Option_Shipyard_Project__c == NULL)) {
                    originShipyardList.add(shipyardObj);
                }
            }
            if(originShipyardList!=null) {
                CGT_ShipyardProjectTrigger_Handler.cloneShipyardProject(originShipyardList);
            }
        }
    }
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            
            List<CGT_Shipyard_Project__c> originShipyardList = new List<CGT_Shipyard_Project__c>();
            
            String allFields = '';
    
            //Get set of fields
            Set<String> objectFields = Schema.getGlobalDescribe().get('CGT_Shipyard_Project__c').getDescribe().fields.getMap().keySet();
            for(String fieldName:objectFields) {
                allFields = allFields + fieldName + ',';
            }
            
            allFields = allFields.substring(0, allFields.length()-1);
            
            Set<Id> shipyardIDSet = trigger.newMap.keySet();
            
            String queryToExecute = 'SELECT '+allFields+ ' FROM CGT_Shipyard_Project__c WHERE Id IN ';
            queryToExecute = queryToExecute + ': shipyardIDSet';
            
            List<CGT_Shipyard_Project__c> shipyardList = Database.query(queryToExecute);
            
            for(CGT_Shipyard_Project__c projectObj : shipyardList) {
                if((projectObj.CGT_Project_Status__c=='Closed' || projectObj.CGT_Project_Status__c=='Hot') && projectObj.CGT_Number_of_Options__c > 0 && projectObj.CGT_Option_Shipyard_Project__c == NULL) {
                    originShipyardList.add(projectObj);
                }
            }
            
            if(originShipyardList!=null) {
                CGT_ShipyardProjectTrigger_Handler.cloneShipyardProject(originShipyardList);
            }
        }
    }
}