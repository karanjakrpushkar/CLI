@isTest(seeAllData = false)
public class CGT_OwnerShipControllerTest {


    public static testMethod void Account1(){
     List<User> userList = [Select id from user where profile.name='CGT_API_User' and isactive=true];

Account accObj1 = new Account();
        accObj1.name = 'Test Account1';
        accObj1.CGT_Account_Group__c = 'C021';
        accObj1.Type = 'Other';
        insert accObj1;
System.runas(userList[0]){    
      Account accObj = new Account();
        accObj.name = 'Test Account';
        accObj.CGT_Account_Group__c = 'C021';
        accObj.Type = 'Other';
        insert accObj;
        
        
        CGT_OwnerShipController.OwneridUpdate(accObj.id);
        
        }
        CGT_OwnerShipController.OwneridUpdate(accObj1.id);
        CGT_OwnerShipController.OwneridUpdate(null);
    }
}