({
	resetIntegrationMessageFieldValue: function(cmp) {
	// Set integration message to null
	var action = cmp.get("c.resetIntegrationMessage");
	action.setParams({"recordId": cmp.get("v.recordId")});
	action.setParams({"sObjectName": cmp.get("v.sObjectName")});
	action.setCallback(this, function(response) {
	var state = response.getState();
	if (state === "SUCCESS") {
    	console.log('--resetIntegrationMessage() return --'+response.getReturnValue());
    	cmp.set("v.message", response.getReturnValue());
    	console.log('--response --'+cmp.get("v.message")); 
	}else {
		console.log('Problem updating integration message field, response state: ' + state);
	}
	// Display toast message to indicate if message is complete
	var toastEvent = $A.get("e.force:showToast");
	if (state === 'SUCCESS'){
		toastEvent.setParams({
		"title": "Success!",
		"message": "Synchronized is successfully initiated."
	});
	}else{
		toastEvent.setParams({
		"title": "Error!",
		"message": "Synchronization is failed."
		});
	}
	toastEvent.fire();
	});
	$A.enqueueAction(action);
	}
})