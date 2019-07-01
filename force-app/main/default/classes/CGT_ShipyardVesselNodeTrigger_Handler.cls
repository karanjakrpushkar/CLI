/*
    @Author: Tieto
    @Class Name: CGT_ShipyardVesselNode_Handler_Test
    @Created Date: 8th August 2018
    @Description: This class is used for the functionality of creating Opportunity vesel node,
     deleting the opportunity vessel node when similar actions are performed on shipyard project vessel nodes and 
     cascading of asset field of shipyard vessel node to opportunity vessel node.
*/

public class CGT_ShipyardVesselNodeTrigger_Handler {

    /*
        @Author: Tieto
        @Method Name: createOpportunityVesselNodes
        @Description: This method is used to retrieve new shipyard vessel nodes and attach them to the linked opportunity.
    */

    public static void createOpportunityVesselNodes(List < CGT_Vessel_Node_Shipyard_Project__c > vesselNodeList) {

        try {

            //Retrieve the opportunities associated with the shipyard project of the newly inserted vessel node
            Set < Id > shipyardProjectList = new Set < Id > ();
            Map < Id, List < Id >> shipyardOpportunityMap = new Map < Id, List < Id >> ();
            List < CGT_Vessel_Node_Opportunity__c > insertVesselNodeOppList = new List < CGT_Vessel_Node_Opportunity__c > ();
            for (CGT_Vessel_Node_Shipyard_Project__c obj: vesselNodeList) {
                shipyardProjectList.add(obj.CGT_Shipyard_Project__c);
            }
            List < Opportunity > opportunityList = [SELECT id, CGT_Shipyard_Project__c FROM Opportunity WHERE CGT_Shipyard_Project__c IN: shipyardProjectList LIMIT 10000];
            for (Opportunity obj: opportunityList) {
                if (shipyardOpportunityMap.containsKey(obj.CGT_Shipyard_Project__c)) {
                    List < Id > tmpList = shipyardOpportunityMap.get(obj.CGT_Shipyard_Project__c);
                    tmpList.add(obj.id);
                    shipyardOpportunityMap.put(obj.CGT_Shipyard_Project__c, tmpList);
                } else {
                    List < Id > tmpList = new List < Id > ();
                    tmpList.add(obj.id);
                    shipyardOpportunityMap.put(obj.CGT_Shipyard_Project__c, tmpList);
                }
            }

            //Insert the new vessel node in the linked opportunities
            for (CGT_Vessel_Node_Shipyard_Project__c vesselObj: vesselNodeList) {
                List < Id > oppList = shipyardOpportunityMap.get(vesselObj.CGT_Shipyard_Project__c);
                if (oppList != null) {
                    for (Id i: oppList) {
                        CGT_Vessel_Node_Opportunity__c obj = new CGT_Vessel_Node_Opportunity__c();
                        obj.CGT_Opportunity__c = i;
                        obj.CGT_Related_Vessel_Node_Shipyard_Project__c = vesselObj.id;
                        obj.CGT_Asset_Functional_Location__c = vesselObj.CGT_Asset_Functional_Location__c;
                        obj.CGT_Inserted_From_Code__c = true;
                        insertVesselNodeOppList.add(obj);
                    }
                }
            }
            if (!insertVesselNodeOppList.isEmpty()) {
                insert insertVesselNodeOppList;
            }
        } catch (Exception ex) {
            LOG_LogMessageUtility.logMessage(ex, 'CRM-CGT_ShipyardVesselNodeTrigger_Handler', 'createOpportunityVesselNodes', 'Failed to display errors while creating new Opportunity vessel node when new shipyard vessel node is added', true);
        }
    }

    /*
        @Author: Tieto
        @Method Name: deleteOpportunityVesselNodes
        @Description: This method is used to delete the opportunity vessel node if the related shipyard vessel node is deleteed.
    */

    public static void deleteOpportunityVesselNodes(List < CGT_Vessel_Node_Shipyard_Project__c > vesselNodeList) {

        try {

            //Retrieve the opportunity vessel nodes associated with the delete shipyard vessel node
            Set < Id > vesselNodeIds = new Set < Id > ();
            System.debug('vessel node list = ' + vesselNodeList);
            for (CGT_Vessel_Node_Shipyard_Project__c obj: vesselNodeList) {
                vesselNodeIds.add(obj.id);
            }

            System.debug('vessel node ids = ' + vesselNodeIds);

            List < CGT_Vessel_Node_Opportunity__c > deleteVesselNodeOppList = [SELECT id, CGT_Inserted_From_Code__c FROM CGT_Vessel_Node_Opportunity__c WHERE CGT_Related_Vessel_Node_Shipyard_Project__c IN: vesselNodeIds LIMIT 10000];
            System.debug('delete vessel node list = ' + deleteVesselNodeOppList);

            //Update the inserted from code checkbox to bypass validation rule
            if (!deleteVesselNodeOppList.isEmpty()) {
                for (CGT_Vessel_Node_Opportunity__c obj: deleteVesselNodeOppList) {
                    obj.CGT_Inserted_From_Code__c = false;
                }
                update deleteVesselNodeOppList;
            }

            //Delete the opportunity vessel nodes

            if (!deleteVesselNodeOppList.isEmpty()) {
                delete deleteVesselNodeOppList;
            }
        } catch (Exception ex) {
            LOG_LogMessageUtility.logMessage(ex, 'CRM-CGT_ShipyardVesselNodeTrigger_Handler', 'deleteOpportunityVesselNodes', 'Failed to display errors while deleting Opportunity vessel node when its related shipyard vessel node is deleted', true);
        }
    }

    /*
        @Author: Tieto
        @Method Name: syncOpportunityVesselNodesOnUpdate
        @Description: This method is used to cascade asset value from shipyard vessel node to opportunity vessel node.
    */

    public static void syncOpportunityVesselNodesOnUpdate(Map < Id, CGT_Vessel_Node_Shipyard_Project__c > newMap, Map < Id, CGT_Vessel_Node_Shipyard_Project__c > oldMap) {
        try {

            Set < Id > updatedVesselNodeSet = new Set < Id > ();
            for (CGT_Vessel_Node_Shipyard_Project__c vnsRecord: newMap.values()) {
                if (vnsRecord.CGT_Asset_Functional_Location__c != oldMap.get(vnsRecord.Id).CGT_Asset_Functional_Location__c) {
                    updatedVesselNodeSet.add(vnsRecord.Id);
                }
            }

            if (updatedVesselNodeSet.size() > 0) {
                List < CGT_Vessel_Node_Opportunity__c > relatedOppVesselNodesList = [SELECT Id, CGT_Inserted_From_Code__c, CGT_Asset_Functional_Location__c, CGT_Related_Vessel_Node_Shipyard_Project__c FROM CGT_Vessel_Node_Opportunity__c WHERE CGT_Related_Vessel_Node_Shipyard_Project__c IN: updatedVesselNodeSet AND CGT_Inserted_From_Code__c = true LIMIT 10000];

                for (CGT_Vessel_Node_Opportunity__c vnoRecord: relatedOppVesselNodesList) {
                    vnoRecord.CGT_Asset_Functional_Location__c = newMap.get(vnoRecord.CGT_Related_Vessel_Node_Shipyard_Project__c).CGT_Asset_Functional_Location__c;
                    vnoRecord.CGT_Inserted_From_Code__c = false; //unlock record for modification to bypass validation rule
                }

                //Bypass validation rule and update. 
                update relatedOppVesselNodesList;

                for (CGT_Vessel_Node_Opportunity__c vnoRecordTemp: relatedOppVesselNodesList) {
                    if (!vnoRecordTemp.CGT_Inserted_From_Code__c)
                        vnoRecordTemp.CGT_Inserted_From_Code__c = true;
                }

                //Enforce validation rule and update. Update can be moved to future call in future, if needed.
                update relatedOppVesselNodesList;
            }

        } catch (Exception ex) {
            LOG_LogMessageUtility.logMessage(ex, 'CRM-CGT_ShipyardVesselNodeTrigger_Handler', 'syncOpportunityVesselNodesOnUpdate', 'Failed to display errors while changing IMO number of shipyard vessel node', true);
        }

    }
}