/*******************************************************************
@Author: Amit(ext.amit.kumar@cargotec.com)
@Class Name: CGT_CreateRecordController
@Created Date: 20nd Feb 2019
@Description: This class is used to return Owner Benifit.
********************************************************************/
public Class CGT_CreateRecordController{
    
/*******************************************************************
@Author: Amit(ext.amit.kumar@cargotec.com)
@Method Name: createRec()
@Description: This Method return Owner Benifit Values.
********************************************************************/    
    @AuraEnabled 
    public static CGT_Owner_s_Benefit__c createRec(string id) {
        
     CGT_Owner_s_Benefit__c OwnerBen = new CGT_Owner_s_Benefit__c();
        
        if(id!=null){
        System.debug('id>>>'+id);
            
        
            Opportunity opp = [Select id,Recordtype.DeveloperName,Name,CGT_Opportunity_Type__c,CGT_Ship_Owner_Account__c,OwnerId from Opportunity where id =: id];
            
           
            
            OwnerBen.Name = opp.Name + opp.CGT_Opportunity_Type__c;
            OwnerBen.CGT_Account_Ship_owner__c = opp.CGT_Ship_Owner_Account__c;
            OwnerBen.CGT_Owner__c= userinfo.getuserid();
            
            
            return OwnerBen;
            
        }else{
            System.debug('id: ' + id);
          
            return OwnerBen;
        }
    }
}