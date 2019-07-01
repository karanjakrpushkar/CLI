@isTest
private class CGT_AuthRegistrationHandlerTest {
  
  static testMethod void testCreateAndUpdateUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u2 = new User(Alias = 'newUser', Email='hiabiam@cargotectest.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='hiabiam@cargotectest.com');
        insert u2;
        CGT_AuthRegistrationHandler handler = new CGT_AuthRegistrationHandler();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                         'testFirst testLast','hiabiam@cargotectest.com', null, 'testuserlong', 'en_US',
                                                         'google',
                                                         null, null);
        Test.startTest();
        User userInst = handler.createUser(null, sampleData);
        System.assertEquals(u2.Email,userInst.Email);
        handler.updateUser(u2.Id,null,sampleData);
        Test.stopTest();
        
    }
}