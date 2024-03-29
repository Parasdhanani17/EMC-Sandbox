@isTest
public class RosterControllerTest {
    public static testmethod void RosterControllerTestMethod(){
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        insert customEmailSetting;
        
         List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
         
        RecordUtilityClass.sendEmailforCompliance();
        RecordUtilityClass.enableMappingGasPriceTrigger();
        RecordUtilityClass.vehicleUrlMapping();
        RecordUtilityClass.exceptionEmail();
        
        Vehicle_URL_Mapping__c veh2 = new Vehicle_URL_Mapping__c();
        veh2.URL__c = 'https://cdn3.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh2.vehicle__c = 'Dodge Charger';
        veh2.Year__c = '2020';
        insert veh2;
        
        Account obj_Account = RecordUtilityClass.buildAccount();
        obj_Account.Vehicle_Types__c ='2020 Dodge Charger';
        insert obj_Account;

        Contact obj_admincontact = RecordUtilityClass.buildAdminContact(obj_Account);
        insert obj_admincontact;
        
        List<Contact> obj_Manager_list = RecordUtilityClass.buildManagerContact(obj_Account,obj_admincontact);
        insert obj_Manager_list;
        
        List<Contact> obj_Driver_list = RecordUtilityClass.buildDriverContact(obj_Account,obj_Manager_list[0]);
        Contact obj_Contact2 = obj_Driver_list[0];
        List<Contact> obj_Driver_list1 = new List<Contact>();

        for(Integer i=1;i<obj_Driver_list.size();i++)
        {
            obj_Driver_list1.add(obj_Driver_list[i]);
        }
        insert obj_Driver_list1;
        
        Contact obj_Manager_list1 = new Contact();
        obj_Manager_list1 = RecordUtilityClass.getManagerContact();

        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User - Driver']; 
        User user = new User(Alias = 'standt', 
                            Email='standarduser1@testorg.com', 
                            EmailEncodingKey='UTF-8', 
                            LastName='Testing', 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', 
                            UserName='standarduser2@testorg.com',
                            Contactid = obj_Manager_list[0].id,
                            IsActive = True
                        );
        insert user;

        EmployeeDetails empDetail = WrapperUtils.getEmployeeDetails(obj_Driver_list1[0],120.34,230.43);
        EmployeeDetails empDetail1 = WrapperUtils.getEmployeeDetails(obj_Contact2,120.34,230.43);
         String str = 'Employee_ID__c,Firstname,LastName,External_Email__c,' + 
                            'Vehicle_Type__c,Role__c,MailingCity,MailingState,' + 
                            'MailingPostalCode,AccountId,Activation_Date__c,Manager__c,MobilePhone, Driving_States__c\n'+
                            '1,Tesdfsdfsts,Testidfdsfsdng1,test1932434230@testing.com,' + 
                            '2020 Dodge Charger,Driver,CA,USA,' + 
                            '12834,'+obj_Account.Name+',03/03/2018,'+'Test Contact Manager0'+',34323,CA;\n' +
                            '2,Secdfsdfond,Testindfdfsg1,atfdgdfg324ssddsfsd32423424h.goc@gmail.com,' + 
                            '2020 Dodge Charger,Driver,CA,USA,' + 
                            '12586,'+obj_Account.Name+',03/03/2018,'+'Test Contact Manager0'+'34323,CA;'+'Tom Honkus';
            Blob csvFileBody = Blob.valueOf(str);
            String csvAsString = csvFileBody.toString();

        empDetail.FirstName = 'test';
        empDetail.activationDate = '12/12/2018';
        List<EmployeeDetails> obj_list_EmployeeDetails = new List<EmployeeDetails>();
        obj_list_EmployeeDetails.add(empDetail);
        Test.startTest();
        Test.setCurrentPage(Page.roster);
        String conId = ApexPages.currentPage().getParameters().put('id',obj_admincontact.Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',obj_Account.Id);
        RosterController ros = new RosterController();
        RosterController.getAccountid();
        RosterController.getContactid();
        RosterController.getRedirected();
        RosterController.editInlineNewEmployee(JSON.serialize(obj_list_EmployeeDetails),String.valueOf(obj_Account.Id),String.valueOf(obj_admincontact.Id));
        RosterController.getAllManagers();
        RosterController.getlistAllEmployees(obj_Account.Id,obj_admincontact.Id);
        RosterController.getRoles();
        RosterController.getDriverType();
        RosterController.getJobTitle();
        RosterController.getDepartment();
        RosterController.getDrivingStates();
        RosterController.resetPassword(obj_admincontact.Id);
        RosterController.getUser(obj_admincontact.Id);
        RosterController.sendExceptionMails('Insert Failed','1');
        RosterController.getCustomExceptionMessage('1');
        RosterController.readFromFile(csvAsString,accId);
        RosterController.editEmployeeDetails    (obj_Manager_list[0].Id);
        RosterController.getContactByEmailAddress(obj_Manager_list[0].External_Email__c);
        RosterController.manageEmployee(JSON.serialize(obj_list_EmployeeDetails),String.valueOf(obj_Account.id),String.valueOf(obj_admincontact.Id));
        RosterController.getCountryStateCity('36310');
        RosterController.getCity('Abbeville','36310');
        RosterController.getPickListValuesIntoList();
        List<String> conIdList = new List<String>();
        for(contact cont:obj_Manager_list){
            conIdList.add(cont.Id);
        }
        RosterController.massFreeze(JSON.serialize(conIdList),true);
        RosterController.editInlineNewEmployee(NULL,'','');
        empDetail.lastname='sdhshdgsag21212';
        empDetail1.userid =NULL;
        empDetail.email ='rghgfhgf21212@gmail.com';
        System.debug('empDetail' + empDetail);
        List<EmployeeDetails> obj_list_EmployeeDetails1 = new List<EmployeeDetails>();
        obj_list_EmployeeDetails1.add(empDetail1);
        RosterController.manageEmployee(JSON.serialize(obj_list_EmployeeDetails1),String.valueOf(obj_Account.id),String.valueOf(obj_admincontact.Id));
        List<id> insertedContactIDList = new List<id>();
        for(Contact currentcontact:obj_Driver_list1)
        {
            insertedContactIDList.add(currentcontact.id);
        }        
        RosterController.postHTTPCreateNewUserTriplog(insertedContactIDList);
        RosterController.getExcetionTypes('System.DmlException','[UPDATE FAILED]',12);
        RosterController.getExcetionTypes('TypeException','Invalid decimal: .',12);
        RosterController.getExcetionTypes('QueryException','[List has no rows]',12);
        RosterController.getExcetionTypes('NullPointerException','Attempt to de-reference',12);
        RosterController.putHTTP(String.valueOf(obj_Account.id),'test1932434230@testing.com');
        RosterController.massResetPassword(JSON.serialize(insertedContactIDList));
        RosterController.massEnableUser(JSON.serialize(insertedContactIDList));
        RosterController.updateLockDate(String.valueOf(obj_Account.id),'12/21/20','03-2021');
        RosterController.putHTTPConcurConnect(obj_Account.Id,JSON.serialize(insertedContactIDList));
        Test.stopTest();
    }
    public static testmethod void RosterControllerTestMethod1(){
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        insert customEmailSetting;
        
         List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
         
        RecordUtilityClass.exceptionEmail();
        RecordUtilityClass.createRecordsAdminDashboardController();
        RecordUtilityClass.sendEmailforCompliance();
        RecordUtilityClass.enableMappingGasPriceTrigger();
        Test.startTest();
        RosterController ros = new RosterController();
        RosterController.getAccountid();
        RosterController.getContactid();
        RosterController.getRedirected();    
        
        Test.stopTest();
    }
}