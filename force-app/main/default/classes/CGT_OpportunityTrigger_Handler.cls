/*
    @Author: Tieto
    @Class Name: CGT_OpportunityTrigger_Handler
    @Created Date: 28th June 2018
    @Description: This class is used to create Opportunity vessel nodes if a new Shipyard Project Opportunity is created
     or the shipyard project of an existing Opportunity is updated.
*/

public class CGT_OpportunityTrigger_Handler {

    /*
        @Author: Tieto
        @Method Name: createOpportunityVesselNodes
        @Description: This method is used to retrieve vessel nodes related to shipyard project and 
         create the same in the opportunity vessel nodes.
    */

    public static void createOpportunityVesselNodes(List < Opportunity > opportunityList) {

        try {

            List < CGT_Vessel_Node_Opportunity__c > deleteVesselNodeOppList = [SELECT id, CGT_Inserted_From_Code__c FROM CGT_Vessel_Node_Opportunity__c WHERE CGT_Opportunity__c IN: opportunityList LIMIT 10000];

            //Update the inserted from code checkbox to bypass validation rule

            if (!deleteVesselNodeOppList.isEmpty()) {
                for (CGT_Vessel_Node_Opportunity__c obj: deleteVesselNodeOppList) {
                    obj.CGT_Inserted_From_Code__c = false;
                }
                update deleteVesselNodeOppList;
            }

            //Delete if there are existing vessel nodes to an opportunity

            if (!deleteVesselNodeOppList.isEmpty()) {
                delete deleteVesselNodeOppList;
            }

            //Retrieve the vessel nodes from the shipyard associated with the opportunity
            List < Id > shipyardProjectList = new List < Id > ();
            for (Opportunity oppObj: opportunityList) {
                if (oppObj.CGT_Shipyard_Project__c != null) {
                    shipyardProjectList.add(oppObj.CGT_Shipyard_Project__c);
                }
            }
            if (!shipyardProjectList.isEmpty()) {
                List < CGT_Vessel_Node_Shipyard_Project__c > shipyardVesselList = [SELECT id, name, CGT_Shipyard_Project__c, CGT_Asset_Functional_Location__c FROM CGT_Vessel_Node_Shipyard_Project__c WHERE CGT_Shipyard_Project__c IN: shipyardProjectList LIMIT 10000];
                Map < String, List < CGT_Vessel_Node_Shipyard_Project__c >> shipyardVesselMap = new Map < String, List < CGT_Vessel_Node_Shipyard_Project__c >> ();
                for (CGT_Vessel_Node_Shipyard_Project__c shipObj: shipyardVesselList) {
                    if (shipyardVesselMap.containsKey(shipObj.CGT_Shipyard_Project__c)) {
                        List < CGT_Vessel_Node_Shipyard_Project__c > tmpList = shipyardVesselMap.get(shipObj.CGT_Shipyard_Project__c);
                        tmpList.add(shipObj);
                        shipyardVesselMap.put(shipObj.CGT_Shipyard_Project__c, tmpList);
                    } else {
                        List < CGT_Vessel_Node_Shipyard_Project__c > tmpList = new List < CGT_Vessel_Node_Shipyard_Project__c > ();
                        tmpList.add(shipObj);
                        shipyardVesselMap.put(shipObj.CGT_Shipyard_Project__c, tmpList);
                    }
                }

                //Copy shipyard vessel nodes to Opportunity vessel nodes
                List < CGT_Vessel_Node_Opportunity__c > insertVesselNodeOppList = new List < CGT_Vessel_Node_Opportunity__c > ();
                for (Opportunity oppObj: opportunityList) {
                    List < CGT_Vessel_Node_Shipyard_Project__c > tmpList = shipyardVesselMap.get(oppObj.CGT_Shipyard_Project__c);
                    if (tmpList != null) {
                        for (CGT_Vessel_Node_Shipyard_Project__c shipObj: tmpList) {
                            CGT_Vessel_Node_Opportunity__c obj = new CGT_Vessel_Node_Opportunity__c();
                            obj.CGT_Opportunity__c = oppObj.id;
                            obj.CGT_Related_Vessel_Node_Shipyard_Project__c = shipObj.id;
                            obj.CGT_Asset_Functional_Location__c = shipObj.CGT_Asset_Functional_Location__c;
                            obj.CGT_Inserted_From_Code__c = true;
                            insertVesselNodeOppList.add(obj);
                        }
                    }
                }
                if (!insertVesselNodeOppList.isEmpty()) {
                    insert insertVesselNodeOppList;
                }
            }
        } catch (Exception exObj) {
            LOG_LogMessageUtility.logMessage(exObj, 'CRM-CGT_OpportunityTrigger_Handler', 'createOpportunityVesselNodes', 'Failed to display errors while adding the Vessel Nodes of Shipyard Project to its Opportunity', true);
        }
    }
    
    /*
        @Author: Tieto
        @Method Name: manageOpenOppCounter
        @Description: This method is used to manage the Open opportunities (Shipowner) counter of Accounts.
    */
    
    public static void manageOpenOppCounter(List<Id> accountIds,String opr) {
    
        try {
        
            List<Account> accountList = [select id,CGT_Open_opportunities_Shipowner__c from Account where ID IN : accountIds];
            for(Account accObj : accountList) {
                if(opr == 'Add') {
                    accObj.CGT_Open_opportunities_Shipowner__c = accObj.CGT_Open_opportunities_Shipowner__c + 1;
                }
                if(opr == 'Reduce') {
                    if(accObj.CGT_Open_opportunities_Shipowner__c > 0) {
                        accObj.CGT_Open_opportunities_Shipowner__c = accObj.CGT_Open_opportunities_Shipowner__c - 1;
                    }
                }
            }
            update accountList;
        
        }
        catch(Exception exObj) {
            LOG_LogMessageUtility.logMessage(exObj, 'CRM-CGT_OpportunityTrigger_Handler', 'manageOpenOppCounter', 'Failed to display errors while managing the Open Opportunities Counter of Shipowner Accounts', true);
        }
    
    }
    
    /*
        @Author: Tieto
        @Method Name: manageOpenOppCounter
        @Description: This method is used to manage the Closed opportunities (Shipowner) counter of Accounts.
    */
    
    public static void manageClosedOppCounter(List<Id> accountIds,String opr) {
        try {
        
            List<Account> accountList = [select id,CGT_Won_opportunities_Shipowner__c from Account where ID IN : accountIds];
            for(Account accObj : accountList) {
                if(opr == 'Add') {
                    accObj.CGT_Won_opportunities_Shipowner__c = accObj.CGT_Won_opportunities_Shipowner__c + 1;
                }
                if(opr == 'Reduce') {
                    if(accObj.CGT_Won_opportunities_Shipowner__c > 0) {
                        accObj.CGT_Won_opportunities_Shipowner__c = accObj.CGT_Won_opportunities_Shipowner__c - 1;
                    }
                }
            }
            update accountList;
        
        }
        catch(Exception exObj) {
            LOG_LogMessageUtility.logMessage(exObj, 'CRM-CGT_OpportunityTrigger_Handler', 'manageClosedOppCounter', 'Failed to display errors while managing the Closed Opportunities Counter of Shipowner Accounts', true);
        }
    }
    
}