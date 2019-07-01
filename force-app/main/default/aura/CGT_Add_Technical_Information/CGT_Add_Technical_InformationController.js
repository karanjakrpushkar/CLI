({
    myAction : function(cmp, event, helper) {
        
        var opprId = cmp.get("v.recordId");
        
        var action = cmp.get("c.getRecordTypeInfo");
        
        action.setParams({ recordId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                
                var returnString = response.getReturnValue();
                
                var returnArray = returnString.split(';');
                
                var recordTypeId = returnArray[0];
                
                var techName = returnArray[1];
                
                var createTechnicalInformationRecord = $A.get("e.force:createRecord");
                
                createTechnicalInformationRecord.setParams({
                    "entityApiName" : "CGT_Technical_Information__c",
                    "recordTypeId" : recordTypeId,
                    "defaultFieldValues" : { "CGT_Opportunity__c" : opprId , "Name" : techName},
                    "navigationLocation" : 'LOOKUP'
                });
                createTechnicalInformationRecord.fire();
            }
            
            if (state === "ERROR") {
                var errors = response.getError();                       
                cmp.set("v.showErrors",true);
                cmp.set("v.errorMessage",errors[0].message);
            }
        });
        $A.enqueueAction(action);
        
    }
    
})