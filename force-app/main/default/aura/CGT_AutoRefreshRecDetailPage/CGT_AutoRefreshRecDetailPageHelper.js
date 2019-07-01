({
    onReceiveNotification :function(component) {
    var empApi = component.find("empApi");
        
        // Error handler function that prints the error to the console.
        var errorHandler = function (message) {
            console.log("Received error ", message);
        }.bind(this);
        
        // Register error listener and pass in the error handler function.
        empApi.onError(errorHandler);
        
        var channel='/event/CGT_RecordPage_AutoRefresh__e';
        var sub;
        
        // new events
        var replayId=-1;

        var callback = function (platformEvent) {
            console.log('Platform event received: '+ JSON.stringify(platformEvent));
            //alert(JSON.stringify(platformEvent));
            console.log(platformEvent);
        var recID = component.get("v.recordId");
	    var platformRecordID = platformEvent.data.payload.CGT_Record_Id__c;
            if(recID==platformRecordID){
		    $A.get('e.force:refreshView').fire();   
               
           }}.bind(this);
        
        empApi.subscribe(channel, replayId, callback).then(function(value) {
            console.log("Subscribed to channel " + channel);
            sub = value;
            component.set("v.sub", sub);
        });
    }
})