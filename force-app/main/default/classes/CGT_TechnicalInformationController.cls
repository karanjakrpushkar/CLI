/*
    @Author: Tieto
    @Class Name: CGT_TechnicalInformationController
    @Created Date: 4th June 2019
    @Description: This class is used to return the opportunity information for the technical information record to be created based on the Opportunity Type value.
*/

public class CGT_TechnicalInformationController {

    /*
        @Author: Tieto
        @Method Name: getRecordTypeInfo
        @Description: This method returns the opportunity information for the technical information record based on the Opportunity type value.
    */
    
    @AuraEnabled
    public static String getRecordTypeInfo(String recordId) {
        Opportunity opprObj = [select id,name,CGT_Opportunity_Type__c from Opportunity where id=:recordId limit 1];
        
        String recordTypeName = 'Master';
        
        if(opprObj.CGT_Opportunity_Type__c == 'Compressors') {
            recordTypeName = 'Compressors';
        } else if(opprObj.CGT_Opportunity_Type__c == 'Deck Machinery') {
            recordTypeName = 'Deck Machinery';
        } else if(opprObj.CGT_Opportunity_Type__c == 'Steering Gear') {
            recordTypeName = 'Steering Gear';
        } else if(opprObj.CGT_Opportunity_Type__c == 'Offshore BHS' || opprObj.CGT_Opportunity_Type__c == 'Offshore Provision Cranes' || opprObj.CGT_Opportunity_Type__c == 'Offshore SW Handling Syst' || opprObj.CGT_Opportunity_Type__c == 'Offshore SW Winches') {
            recordTypeName = 'DHS';
        } else {
            throw new AuraHandledException('You cannot add Technical Details for this opportunity type');
            //opprObj.addError('You cannot add Technical Details for this opportunity type');
        }
        
        Id devRecordTypeId = Schema.SObjectType.CGT_Technical_Information__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        
        String devRecordTypeName = Schema.SObjectType.CGT_Technical_Information__c.getRecordTypeInfosByName().get(recordTypeName).getDeveloperName();
        
        String returnString = devRecordTypeId+';'+devRecordTypeName;
        
        return returnString;
    }

}