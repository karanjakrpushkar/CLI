/*******************************************************************
@Author: Amit(ext.amit.kumar@cargotec.com)
@Class Name: CGT_OwnerShipController
@Created Date: 2nd Feb 2019
@Description: This class is used to update OwnerId if account owner is Integration User.
********************************************************************/
public without sharing class CGT_OwnerShipController{
    
    /*******************************************************************
@Author: Amit(ext.amit.kumar@cargotec.com)
@Method Name: CGT_OwnerShipController
@Description: This Method update OwnerId if account owner is Integration User 
and return true else false.
********************************************************************/    
    @AuraEnabled 
    public static string OwneridUpdate(string idSTR){
        
        if(idSTR!=null){
            Account acc = [Select id,OwnerId,Owner.Username,Owner.Profile.Name from Account where id =: idSTR];
            
            acc.OwnerId = userInfo.getUserId();
            String profilename = acc.Owner.Profile.Name;
            if(profilename.contains('CGT_API_User')){
                try {
                    update acc;
                }catch (DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                    return 'An Exception Occured. Please contact Administrator';
                }
                return 'true';
                
            }else{
                return 'false';
            }
        }else{
            System.debug('idSTR: ' + idSTR);
            return 'An Exception Occured. Please contact Administrator';
        }
    }
}