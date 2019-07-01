@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
   
    global HTTPResponse respond(HTTPRequest req) {
      
        System.assertEquals('POST', req.getMethod());
  
      
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"messageID":"Testing"}');
        res.setStatusCode(200);
        return res;
    }
    
   
    
    }