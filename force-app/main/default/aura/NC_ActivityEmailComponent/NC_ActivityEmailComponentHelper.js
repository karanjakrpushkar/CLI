({
	fetchData: function (cmp) {
        var action = cmp.get("c.getEmails");
        action.setParams({ recordId : cmp.get("v.recordId") });
        
    	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                var usrTime = $A.get("$Locale.timezone");
                cmp.set('v.mycolumns', [
                    { label: 'Subject', fieldName: 'linkName', type: 'url', typeAttributes: {label: { fieldName: 'Subject' }, target: '_blank'}},
                    { label: 'To', fieldName: 'ToAddress', type: 'text'},
                    { label: 'Message Date', fieldName: 'MessageDate', type: 'date', typeAttributes: { day: 'numeric', month: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: false,timeZone: usrTime}},
                    { label: 'From', fieldName: 'FromName', type: 'text'},
                    { label: 'Has Attachment', fieldName: 'HasAttachment', type: 'boolean'}
                ]);
                resultData.forEach(function(recordVal) {
                    recordVal.linkName = '/'+recordVal.Id;
                });
                cmp.set("v.mydata", resultData);
            }
    	});
        
    	$A.enqueueAction(action);
	}    
})