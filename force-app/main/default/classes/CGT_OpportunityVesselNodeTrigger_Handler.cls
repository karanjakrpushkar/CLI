/*
    @Author: Tieto
    @Class Name: CGT_OpportunityVesselNodeTrigger_Handler
    @Created Date: 26th July 2018
    @Description: This class is used to restrict the user from creating or deleting a vessel node directly in a shipyard project opportunity.
*/

public class CGT_OpportunityVesselNodeTrigger_Handler {
    
    /*
        @Author: Tieto
        @Method Name: restrictAction
        @Description: This method is used for checking if the user is performing an insert or a delete 
         and restrict him if the vessel node is added directly to the opportunity.
    */
    
    public static void restrictAction(List < CGT_Vessel_Node_Opportunity__c > vesselNodeList, String opr) {
        try {
            
            //Retrieve the opportunitiesof the vessel nodes the user is trying to create or delete
            
            Set < Id > opportunitySet = new Set < Id > ();
            Map < Id, Opportunity > opportunityMap = new Map < Id, Opportunity > ();
            for (CGT_Vessel_Node_Opportunity__c obj: vesselNodeList) {
                opportunitySet.add(obj.CGT_Opportunity__c);
            }
            
            List < Opportunity > opportunityList = [SELECT id, name, CGT_Shipyard_Project__c, CGT_Number_of_Vessels__c, CGT_Shipyard_Project__r.CGT_Number_of_Vessels__c FROM Opportunity WHERE id IN: opportunitySet and CGT_Shipyard_Project__c != null LIMIT 10000];
            for (Opportunity obj: opportunityList) {
                opportunityMap.put(obj.id, obj);
            }
            
            //Retrieve the opportunity of the vessel node user is trying to insert or delete 
            //and show error if he is trying to do it directly from opportunity.
            
            if (opportunityMap != null) {
                for (CGT_Vessel_Node_Opportunity__c obj: vesselNodeList) {
                    Opportunity opportunityObj = opportunityMap.get(obj.CGT_Opportunity__c);
                    if (opportunityObj != null) {
                        if (opr == 'insert') {
                            if (obj.CGT_Inserted_From_Code__c == false) {
                                obj.addError(Label.CGT_VesselNode_Insert_Error);
                            }
                        }
                        if (opr == 'delete') {
                            if(obj.CGT_Inserted_From_Code__c == true && opportunityObj.CGT_Number_of_Vessels__c <= opportunityObj.CGT_Shipyard_Project__r.CGT_Number_of_Vessels__c) {
                                obj.addError(Label.CGT_VesselNode_Delete_Error);
                            }
                        }
                    }
                }
            }
        } 
        catch (Exception exObj) 
        {
            LOG_LogMessageUtility.logMessage(exObj,'CRM-CGT_OpportunityVesselNodeTrigger_Handler','restrictAction','Failed to display errors while adding or deleting Vessel Nodes on Shipyard Project Opportunity',true);
        }
    }

}