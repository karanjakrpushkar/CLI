/*****************************************************************************************************
 *
 * Author       : Tieto India Pvt Ltd
 * Created Date : 21St May 2018
 * Purpose      : This is helper class for NC_CaseTrigger 
 * Modified By : 
 ******************************************************************************************************/
public class NC_CaseHelper {

    private Static FINAL String STR_CUST_REC_TYPE = 'NC Customer Claim';
    private Static FINAL String STR_VEND_REC_TYPE = 'NC Vendor Claim';
    private Static FINAL String STR_INT_REC_TYPE = 'NC Internal Claim';
    private Static FINAL String STR_YES = 'Yes';
    private Static FINAL String STR_EXT_DATA_SOURCE_ID = System.Label.NC_External_Id;    
    private Static FINAL String STR_E = 'E';
    private Static FINAL String STR_H = 'H';
    private Static FINAL String STR_V = 'V';

    /******************************************************
     * getFileAttachment Method to get the file attachments from external object and 
     * create fiels/attachment for related case record.
     * Method also copies case attachment to claim object using ContentDocumentLink object
     *******************************************************/
    @future
    public static void getFileAttachment(set < Id > keys) {
        // List of Strings used to retrieve attachment Id from external object
        Map < String, Case > fileIds = new Map < String, Case > ();
        List < String > fileUrl = new List < String > ();
        List < String > indUrl = new List < String > ();
        List < ContentVersion > cvList = new List < ContentVersion > ();
        Map < Id, NC_Claim__c > caseClimMap = new Map < Id, NC_Claim__c > ();
        List < ContentDocumentLink > neweConDocLinks = new List < ContentDocumentLink > ();


        //Query cases to get the file path
        try {
            for (
                case caseRec:
                    [Select id, NC_Google_Attachment_URL__c, NC_Google_Attachment_URL_Int__c from Case WHERE id IN: keys AND NC_Submitted_From_Google_Form__c =: STR_YES]) {
                if (caseRec.NC_Google_Attachment_URL__c != null)
                    fileUrl = caseRec.NC_Google_Attachment_URL__c.split(',');

                if (caseRec.NC_Google_Attachment_URL_Int__c != null)
                    for (String intFileUrl: caseRec.NC_Google_Attachment_URL_Int__c.split(',')) {
                        fileUrl.add(intFileUrl);
                    }

                if (fileUrl.size() > 0) {
                    for (String attachId: fileUrl) {
                        indUrl = attachId.split('=');
                        fileIds.put(indUrl[1], caseRec);
                    }
                }
            }

            //Query external object to create map to attach it to resp. cases
            list < items_NC_Tool_Source__x > externalRecords;

            //create dummy external obj. record for test cases
            if (Test.isRunningTest()) {
                externalRecords = new List < items_NC_Tool_Source__x > ();
                externalRecords.add(new items_NC_Tool_Source__x(ExternalId = '0XC0E0000008OUz:file:1G9AC60SfWfroBcOckvSklBoLQgYTpynE', DisplayUrl = 'https://drive.google.com/a/cargotec.com/file/d/1G9AC60SfWfroBcOckvSklBoLQgYTpynE/view?usp=drivesdk'));
            } else {
                externalRecords = [SELECT Author__c, Comment__c, ContentLength__c, CreationDate__c, DisplayUrl, DownloadUrl__c,
                    ExternalId, Id, IsFolder__c, MimeType__c, Name__c, ParentId__c,
                    UpdateDate__c, UpdatedBy__c FROM items_NC_Tool_Source__x
                ];
            }

            Map < String, items_NC_Tool_Source__x > mapNCToolFiles = new Map < String, items_NC_Tool_Source__x > ();
            for (items_NC_Tool_Source__x extobjrec: externalRecords) {
                String fileId = String.valueOf(extobjrec.ExternalId).split(':')[2];
                mapNCToolFiles.put(fileId, extobjrec);
                //system.debug('map '+ mapNCToolFiles);
            }

            // Create content version to attach file

            for (String fileIdRec: fileIds.keySet()) {
                if (mapNCToolFiles.containsKey(fileIdRec)) {
                    //system.debug('inside loop');
                    ContentVersion cv = new ContentVersion(
                        contentLocation = STR_E,
                        origin = STR_H,
                        ownerId = UserInfo.getUserId(),
                        title = mapNCToolFiles.get(fileIdRec).Name__c,
                        pathOnClient = mapNCToolFiles.get(fileIdRec).DisplayUrl,
                        externalDataSourceId = STR_EXT_DATA_SOURCE_ID,
                        externalDocumentInfo1 = mapNCToolFiles.get(fileIdRec).DisplayUrl,
                        externalDocumentInfo2 = fileIdRec,
                        firstPublishLocationId = fileIds.get(fileIdRec).Id);
                    cvList.add(cv);
                }
            }

            if (cvList.size() > 0)
                Database.insert(cvList, false);

            //query contentdocumentLink with this case Id to crate attachment in claim
            List < ContentDocumentLink > objConDocLink = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId IN: keys AND LinkedEntity.Type = 'Case'];

            //query list of cliams with these cases
            List < NC_Claim__c > newClaimsList = [SELECT Id, NC_Case__c, NC_Case__r.RecordTypeId, NC_Case__r.RecordType.Name, NC_Case__r.NC_Claim_type_from_form__c FROM NC_Claim__c WHERE NC_Case__c IN: keys];

            //populate a collection for case and claim
            for (NC_Claim__c objClaim: newClaimsList) {
                //if(objClaim.NC_Created_From_Case__c )
                caseClimMap.put(objClaim.NC_Case__c, objClaim);
            }

            //crate contentdocumentlink
            if (objConDocLink.size() > 0 && caseClimMap.size() > 0)
                for (ContentDocumentLink obj: objConDocLink) {
                    ContentDocumentLink newLink = new ContentDocumentLink();
                    newLink.ContentDocumentId = obj.ContentDocumentId;
                    newLink.LinkedEntityId = caseClimMap.get(obj.LinkedEntityId).Id;
                    newLink.ShareType = STR_V;
                    neweConDocLinks.add(newLink);

                }
            insert neweConDocLinks;
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }

    /******************************************************
     * Method used to assign record type to cases based on type field submitted thorugh google form.
     *******************************************************/

    public static void assignRecordType(List < Case > newCases) {

        //get the record type ids based on names
        Id customerRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(STR_CUST_REC_TYPE).getRecordTypeId();
        Id internalRecrodtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(STR_INT_REC_TYPE).getRecordTypeId();
        Id vendorRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(STR_VEND_REC_TYPE).getRecordTypeId();

        try {
            Map < String, Id > recordTypeMap = new Map < String, Id > {
                'Customer' => customerRecordtypeId,
                'Internal' => internalRecrodtypeId,
                'Vendor' => vendorRecordTypeId,
                'NC Internal Claim' => internalRecrodtypeId,
                'NC Customer Claim' => customerRecordtypeId,
                'NC Vendor Claim' => vendorRecordTypeId
            };
            //populate record type 
            for (Case obj: newCases) {

                //if case is submitted form google form
                if (obj.NC_Submitted_From_Google_Form__c == 'Yes' && obj.NC_Claim_type_from_form__c != null) {
                    if (recordTypeMap.containsKey(obj.NC_Claim_type_from_form__c)) {
                        obj.RecordTypeId = recordTypeMap.get(obj.NC_Claim_type_from_form__c);
                    }
                }

                //if case is craeted from claim
                if (obj.NC_Created_From_Claim__c && obj.NC_Claim_Record_Type_Name__c != null) {
                    if (recordTypeMap.containsKey(obj.NC_Claim_Record_Type_Name__c))
                        obj.RecordTypeId = recordTypeMap.get(obj.NC_Claim_Record_Type_Name__c);
                }
            }
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

    }

}