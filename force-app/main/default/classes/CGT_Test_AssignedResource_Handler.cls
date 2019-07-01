/********************************************************************************************************
* @Author         ext.chandrakanth.reddy@cargotec.com
* @Description    Test class for  CGT_AssignedResource_Handler.
* @CreatedDate    04-11-2018

*********************************************************************************************************/
@isTest(seeAllData = false)
public class CGT_Test_AssignedResource_Handler {
/********************************************************************************************************
* @author        ext.chandrakanth.reddy@cargotec.com
* @description   This method will verify the CheckServiceTerritory  for test coverage.  
* @Paramters     none
* @return        void
*********************************************************************************************************/
  static testMethod void Test_checkServiceTerritory_WO(){
        

       // ServiceTerritory serviceTer=CGT_TestDataCreation.createServiceTerritory_TestData(true);
        
        WorkOrder wo = CGT_TestDataCreation.createWorkOrder_TestData(true);
        //ServiceTerritory serviceTer1=CGT_TestDataCreation.createServiceTerritory_TestData(true);
        ServiceTerritory serviceTer2=CGT_TestDataCreation.createServiceTerritory_TestData1(true,wo.ServiceTerritoryId);

       
        ServiceAppointment sa= CGT_TestDataCreation.createServiceAppointment_TestData(serviceTer2,wo);
        ServiceResource sr= CGT_TestDataCreation.createServiceResource_TestData();
        
        ServiceTerritoryMember stm= CGT_TestDataCreation.createServiceTerritoryMember_Testdata(sr,serviceTer2);
        Test.startTest();
        AssignedResource ar= CGT_TestDataCreation.createAssignedresource_TestData(sa, sr);
        insert ar;
       Test.stopTest();

        List<AssignedResource> ar_List= [select id, ServiceResourceId,ServiceAppointmentId from AssignedResource];
        system.assertNotEquals(0,ar_List.size());
         Id Said=ar_List.get(0).ServiceAppointmentId;
        List<ServiceAppointment> sa_Test= [select id,ServiceTerritoryId from ServiceAppointment where id = :Said];
        // Checking if the Service Terriotry ID is updated on Service Appointment
        //system.assertEquals(serviceTer1.id,sa_Test[0].ServiceTerritoryId);

       
      
       
  }


}