/*
    @Author: Tieto
    @Trigger Name: CGT_OpportunityTrigger
    @Created Date: 28th June 2018
    @Description: This trigger is used to create Opportunity vessel nodes if a new Shipyard Project Opportunity is created
     or the shipyard project of an existing Opportunity is updated.Also it tests the updates of the Open Opportunities (Shipowner) and Won Opportunities (Shipowner) fields of the Shipowner of Opportunity.
*/
trigger CGT_OpportunityTrigger on Opportunity(after insert, after update,before delete) {

    //Check if the opportunity is a shipyard project opportunity and if yes,
    //then replicate the vessel nodes from the associated shipyard to the opportunity vessel nodes

    if (Trigger.isInsert) {
        
        //Call Helper class method to create vessel nodes
        List < Opportunity > opportunityList = new List < Opportunity > ();
        for (Opportunity obj: trigger.new) {
            if (obj.CGT_Shipyard_Project__c != null) {
                opportunityList.add(obj);
            }
        }
        
        if (opportunityList != null) {
            CGT_OpportunityTrigger_Handler.createOpportunityVesselNodes(trigger.new);
        }
        //CGT_OpportunityTrigger_Handler.manageOpportunityPartners(trigger.newMap, null);
        
        //Call helper class method to increment the Open and Won Opportunities counter of Shipowner Account
        
        List<Opportunity> newOpportunityList = [select id,CGT_Ship_Owner_Account__c,IsClosed,StageName,CGT_Shipyard_Project__r.CGT_Ship_Owner__c,CGT_Shipyard_Project__c from Opportunity where ID IN:trigger.new];
        
        List < Id > openOppList = new List < Id > ();
        
        for(Opportunity obj: newOpportunityList) {
            if(obj.CGT_Ship_Owner_Account__c!=null || obj.CGT_Shipyard_Project__r.CGT_Ship_Owner__c!=null) {
                if(obj.IsClosed == FALSE && obj.StageName != 'INACTIVE') {
                    if(obj.CGT_Shipyard_Project__c!=null) {
                        openOppList.add(obj.CGT_Shipyard_Project__r.CGT_Ship_Owner__c);
                    } else {
                        openOppList.add(obj.CGT_Ship_Owner_Account__c);
                    }
                }
            }
        }
        
        if(!openOppList.isEmpty()) {
            CGT_OpportunityTrigger_Handler.manageOpenOppCounter(openOppList,'Add');
        }
    }

    if (Trigger.isUpdate) {
    
        List < Id > reduceOpenOppList = new List < Id > ();
        List < Id > reduceClosedOppList = new List < Id > ();
        List < Id > addOpenOppList = new List < Id > ();
        List < Id > addClosedOppList = new List < Id > ();
    
        //Check if the shipyard project of the opportunity is updated and if yes,then delete the earlier opportunity vessel nodes
        //and create new ones from the associated shipyard
    
        //Call Helper class method to create vessel nodes
        List < Opportunity > oppList = new List < Opportunity > ();
        for (Opportunity oppObj: Trigger.new) {
            if (oppObj.CGT_Shipyard_Project__c != Trigger.oldMap.get(OppObj.Id).CGT_Shipyard_Project__c) {
                oppList.add(oppObj);
            }
        }
        if (!oppList.isEmpty()) {
            CGT_OpportunityTrigger_Handler.createOpportunityVesselNodes(oppList);
        }

        //CGT_OpportunityTrigger_Handler.manageOpportunityPartners(trigger.newMap, trigger.oldMap);
        
        //Call helper class method to reduce the Open and Won Opportunities counter of Shipowner Account if current Shipowner Account is null and previous Shipowner Account != null
        
        reduceOpenOppList.clear();
        reduceClosedOppList.clear();
        
        List<Opportunity> newOpportunityList = [select id,CGT_Ship_Owner_Account__c,IsClosed,StageName from Opportunity where ID IN:trigger.new];
        
        for(Opportunity obj: newOpportunityList) {
            Opportunity oldOpp = Trigger.oldMap.get(obj.Id);
            if(obj.CGT_Ship_Owner_Account__c == NULL && oldOpp.CGT_Ship_Owner_Account__c != NULL) {
                if(oldOpp.IsClosed == FALSE && oldOpp.StageName != 'INACTIVE') {
                    reduceOpenOppList.add(oldOpp.CGT_Ship_Owner_Account__c);
                }
                if(oldOpp.StageName == 'Closed Won') {
                    reduceClosedOppList.add(oldOpp.CGT_Ship_Owner_Account__c);
                }
            }
        }
        
        if(!reduceOpenOppList.isEmpty()) {
            CGT_OpportunityTrigger_Handler.manageOpenOppCounter(reduceOpenOppList,'Reduce');
        }
        if(!reduceClosedOppList.isEmpty()) {
            CGT_OpportunityTrigger_Handler.manageClosedOppCounter(reduceClosedOppList,'Reduce');
        }
        
        //Call helper class method to add the Open and Won Opportunities counter of Shipowner Account if current Shipowner Account is not null and previous Shipowner Account = null
        
        addOpenOppList.clear();
        addClosedOppList.clear();
        
        for(Opportunity obj: newOpportunityList) {
            Opportunity oldOpp = Trigger.oldMap.get(obj.Id);
            if(obj.CGT_Ship_Owner_Account__c != NULL && oldOpp.CGT_Ship_Owner_Account__c == NULL) {
                if(obj.IsClosed == FALSE && obj.StageName != 'INACTIVE') {
                    addOpenOppList.add(oldOpp.CGT_Ship_Owner_Account__c);
                }
                if(obj.StageName == 'Closed Won') {
                    addClosedOppList.add(oldOpp.CGT_Ship_Owner_Account__c);
                }
            }
        }
        
        if(!addOpenOppList.isEmpty()) {
            CGT_OpportunityTrigger_Handler.manageOpenOppCounter(addOpenOppList,'Add');
        }
        if(!addClosedOppList.isEmpty()) {
            CGT_OpportunityTrigger_Handler.manageClosedOppCounter(addClosedOppList,'Add');
        }
        
        //Call helper class method to manage the Open and Won Opportunities counters of old and new Shipowner Accounts if current Shipowner Account is not null and previous Shipowner Account also was not null
        
        reduceOpenOppList.clear();
        reduceClosedOppList.clear();
        addOpenOppList.clear();
        addClosedOppList.clear();
        
        for(Opportunity obj: newOpportunityList) {
            Opportunity oldOpp = Trigger.oldMap.get(obj.Id);
            if(obj.CGT_Ship_Owner_Account__c != NULL && oldOpp.CGT_Ship_Owner_Account__c != NULL && obj.CGT_Ship_Owner_Account__c != oldOpp.CGT_Ship_Owner_Account__c) {
                if(obj.IsClosed == FALSE && obj.StageName != 'INACTIVE') {
                    addOpenOppList.add(obj.CGT_Ship_Owner_Account__c);
                }
                if(obj.StageName == 'Closed Won') {
                    addClosedOppList.add(obj.CGT_Ship_Owner_Account__c);
                }
                if(oldOpp.IsClosed == FALSE && oldOpp.StageName != 'INACTIVE') {
                    reduceOpenOppList.add(oldOpp.CGT_Ship_Owner_Account__c);
                }
                if(oldOpp.StageName == 'Closed Won') {
                    reduceClosedOppList.add(oldOpp.CGT_Ship_Owner_Account__c);
                }
            }
        }
        
        if(!addOpenOppList.isEmpty()) {
            CGT_OpportunityTrigger_Handler.manageOpenOppCounter(addOpenOppList,'Add');
        }
        if(!addClosedOppList.isEmpty()) {
            CGT_OpportunityTrigger_Handler.manageClosedOppCounter(addClosedOppList,'Add');
        }
        if(!reduceOpenOppList.isEmpty()) {
            CGT_OpportunityTrigger_Handler.manageOpenOppCounter(reduceOpenOppList,'Reduce');
        }
        if(!reduceClosedOppList.isEmpty()) {
            CGT_OpportunityTrigger_Handler.manageClosedOppCounter(reduceClosedOppList,'Reduce');
        }
    }
    
    if (Trigger.isDelete) {
    
        List < Id > reduceOpenOppList = new List < Id > ();
        List < Id > reduceClosedOppList = new List < Id > ();
    
        for(Opportunity obj: trigger.old) {
            if(obj.CGT_Ship_Owner_Account__c != NULL) {
                if(obj.IsClosed == FALSE && obj.StageName != 'INACTIVE') {
                    reduceOpenOppList.add(obj.CGT_Ship_Owner_Account__c);
                }
                if(obj.StageName == 'Closed Won') {
                    reduceClosedOppList.add(obj.CGT_Ship_Owner_Account__c);
                }
            }
        }
        
        if(!reduceOpenOppList.isEmpty()) {
            CGT_OpportunityTrigger_Handler.manageOpenOppCounter(reduceOpenOppList,'Reduce');
        }
        if(!reduceClosedOppList.isEmpty()) {
            CGT_OpportunityTrigger_Handler.manageClosedOppCounter(reduceClosedOppList,'Reduce');
        }
    }
}