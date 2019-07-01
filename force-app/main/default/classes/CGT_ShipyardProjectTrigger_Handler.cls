/*
    @Author: Tieto
    @Class Name: CGT_ShipyardProjectTrigger_Handler
    @Created Date: 12th July 2018
    @Description: This class is used to restrict user from closing shipyard projects having open opportunities and for cloning a Shipyard Project to create a "Options" Shipyard Project.
*/

public class CGT_ShipyardProjectTrigger_Handler {

    /*
        @Author: Tieto
        @Method Name: showErrorForClosedStatus
        @Description: This method is used to get retrieve updated shipyards and restrict user from closing shipyard projects having open opportunities.
    */

    public static void showErrorForClosedStatus(List < CGT_Shipyard_Project__c > shipyardProjectList) {

        try {

            Set < Id > shipyardList = new Set < Id > ();
            Map < Id, List < Opportunity >> opportunityMap = new Map < Id, List < Opportunity >> ();
            List < Opportunity > opportunityList = new List < Opportunity > ();
            for (CGT_Shipyard_Project__c obj: shipyardProjectList) {
                shipyardList.add(obj.id);
            }

            //Retrieve all the opportunities associated with the updated shipyard project
            opportunityList = [SELECT id, CGT_Shipyard_Project__c, CGT_Project_Status__c FROM Opportunity WHERE CGT_Shipyard_Project__c IN: shipyardList LIMIT 10000];
            if (opportunityList != null) {
                for (Opportunity obj: opportunityList) {
                    if (opportunityMap.containsKey(obj.CGT_Shipyard_Project__c)) {
                        List < Opportunity > tmpList = opportunityMap.get(obj.CGT_Shipyard_Project__c);
                        tmpList.add(obj);
                        opportunityMap.put(obj.CGT_Shipyard_Project__c, tmpList);
                    } else {
                        List < Opportunity > tmpList = new List < Opportunity > ();
                        tmpList.add(obj);
                        opportunityMap.put(obj.CGT_Shipyard_Project__c, tmpList);
                    }
                }
            }

            //Check if the shipyard has any open opportunities and if yes, restrict user from closing the shipyard
            for (CGT_Shipyard_Project__c obj: shipyardProjectList) {
                List < Opportunity > opportunityTempList = opportunityMap.get(obj.id);
                if (opportunityTempList != null) {
                    for (Opportunity opportunityObj: opportunityTempList) {
                        if (opportunityObj.CGT_Project_Status__c != 'Closed' && opportunityObj.CGT_Project_Status__c != 'Inactive') {
                            obj.addError(Label.CGT_ShipyardProject_Close_Error);
                            break;
                        }
                    }
                }
            }
        } catch (Exception exObj) {
            LOG_LogMessageUtility.logMessage(exObj, 'CRM-CGT_ShipyardProjectTrigger_Handler', 'showErrorForClosedStatus', 'Failed to display errors while restricting user from closing shipyard having open opportunities', true);
        }
    }
    
    /*
        @Author: Tieto
        @Method Name: cloneShipyardProject
        @Description: This method is used for cloning a Shipyard Project to create a "Options" Shipyard Project.
    */

    public static void cloneShipyardProject(List < CGT_Shipyard_Project__c > shipyardProjectList) {
        
        try {
        
            List < CGT_Shipyard_Project__c > insertShipyardProjectList = new List < CGT_Shipyard_Project__c >();
            List < CGT_Shipyard_Project__c > updateShipyardProjectList = new List < CGT_Shipyard_Project__c >();
            List<Id> shipyardIds = new List<Id>();
            
            //Clone the original shipyard project
            for(CGT_Shipyard_Project__c obj : shipyardProjectList) {
                CGT_Shipyard_Project__c newObj = obj.clone(false, false, false, false);
                newObj.name = 'OPTION(s) ' + obj.name;
                newObj.CGT_Number_of_Options__c = 0;
                newObj.CGT_Closing_Date__c = obj.CGT_Closing_Date__c.addMonths(3);
                newObj.CGT_Project_Status__c = 'ACTIVE';
                newObj.CGT_Sales_Tool_ID__c = '';
                newObj.CGT_Original_Shipyard_Project__c = obj.id;
                newObj.CGT_Cloned_From__c = null;
                newObj.OwnerId = UserInfo.getUserId();
                insertShipyardProjectList.add(newObj);
                shipyardIds.add(obj.id);
            }
            insert insertShipyardProjectList;
            
            //Update the original shipyard project with the Option shipyard project id and create vessel nodes for the option shipyard project
            
            Map<Id,Id> optionShipyardMap = new Map<Id,Id>();
            List<CGT_Vessel_Node_Shipyard_Project__c> insertVesselNodeList = new List<CGT_Vessel_Node_Shipyard_Project__c>();
            
            List<CGT_Shipyard_Project__c> optionShipyardList = [select id,CGT_Original_Shipyard_Project__c from CGT_Shipyard_Project__c where CGT_Original_Shipyard_Project__c IN : shipyardIds];
            
            for(CGT_Shipyard_Project__c obj : optionShipyardList) {
                optionShipyardMap.put(obj.CGT_Original_Shipyard_Project__c,obj.id);
            }
            
            for(CGT_Shipyard_Project__c obj : shipyardProjectList) {
                obj.CGT_Option_Shipyard_Project__c = optionShipyardMap.get(obj.id);
                updateShipyardProjectList.add(obj);
                for(Integer i = 0 ; i < obj.CGT_Number_of_Options__c ; i++) {
                    CGT_Vessel_Node_Shipyard_Project__c newObj = new CGT_Vessel_Node_Shipyard_Project__c();
                    newObj.CGT_Shipyard_Project__c = optionShipyardMap.get(obj.id);
                    insertVesselNodeList.add(newObj);
                }
            }
            
            insert insertVesselNodeList;
            update updateShipyardProjectList;
            
        } catch(Exception exObj) {
            LOG_LogMessageUtility.logMessage(exObj, 'CRM-CGT_ShipyardProjectTrigger_Handler', 'cloneShipyardProject', 'Failed to display errors while cloning shipyard project', true);
        }
    }
}