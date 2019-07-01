({
    myAction : function(cmp, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "view"
                });
                urlEvent.fire();
        var action = cmp.get("c.queryAllFieldsForClone");
        action.setParams({ recordId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // alert(response.getReturnValue());
                var recId = cmp.get("v.recordId");
                var defaulVal = response.getReturnValue();
                var stringVal = JSON.stringify(defaulVal);
               
                var createAcountContactEvent = $A.get("e.force:createRecord");
                createAcountContactEvent.setParams({
                    "entityApiName": "CGT_Shipyard_Project__c",
                    //"defaultFieldValues" : {"CGT_Owner_Project__c":"a0x6E000001S9klQAC","CGT_Number_of_Vessels__c":1,"CGT_Vessel_Type__c":"Escort tug","CGT_Shipyard_Builder__c":"0016E00000ZtnUgQAJ","CGT_Ship_Owner__c":"0016E00000Zv0wXQAR","CGT_Sales_Area__c":"NS China","CGT_Project_Status__c":"Hot","CGT_Number_of_Options__c":0,"CGT_Shipyard_Project_System_ID__c":"SY-00189","CGT_Market_Segment__c":"Offshore Oil & Gas and Renewables","CGT_Closing_Date__c":"2018-08-15","LastReferencedDate":"2018-10-02T20:09:05.000+0000","LastViewedDate":"2018-10-02T20:09:05.000+0000","SystemModstamp":"2018-10-02T19:45:35.000+0000","LastModifiedById":"0050Y000003tazZQAQ","LastModifiedDate":"2018-10-02T19:45:35.000+0000","CreatedById":"0050Y000003tazZQAQ","CreatedDate":"2018-10-02T19:45:35.000+0000","CurrencyIsoCode":"USD","Name":"83T BP 32m Escort Tug2","IsDeleted":false,"OwnerId":"0056E000003UvnmQAC"}
                    //"defaultFieldValues": JSON.stringify(response.getReturnValue())
                    "defaultFieldValues": JSON.parse(defaulVal)
                });
                createAcountContactEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
    }
    
})