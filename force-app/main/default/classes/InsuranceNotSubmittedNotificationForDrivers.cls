global class NotSubmittedInsuranceNotification implements Database.Batchable<Sobject> {
    global NotSubmittedInsuranceNotification() {
        String accountName = Label.TripstobeLogged;
        listAccount = new List<String>();
        if(accountName != null) {
            listAccount = accountName.split(',');
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC){

        List<Messaging.MassEmailMessage> mails = new List<Messaging.MassEmailMessage>();
        List<id> conId= new List<Id>();
        string header = 'Name, Email, Error \n';
        string finalstr = header ;
        list<string> roleList = new list<string>();
        roleList.add('Driver');
        roleList.add('Driver/Manager');
        roleList.add(StaticValues.roleAdminDriver);
        List<Contact> conList =[SELECT Name, Role__c, External_Email__c, FirstName 
                                    FROM Contact
                                    WHERE Account.Name IN: listAccount 
                                        AND Role__c IN : roleList 
                                        AND Deactivated_Date__c = NULL
                                        AND Insurance_Attachment_Id__c = NULL];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:'driverservices@mburse.com'];
        List<EmailTemplate> temp = new List<EmailTemplate>([SELECT id, Subject, body, HTMLValue FROM EmailTemplate 
                                                                WHERE DeveloperName = 'Not_Submitted_Insurance_Notification']);
       
        Messaging.SingleEmailMessage mail;
        List<Messaging.SingleEmailMessage> mail_list = new List<Messaging.SingleEmailMessage>();
        Integer totalcontacts = conList.size();
        for(Contact c: conList) {
            List<String> sendingTo = new List<String>();
            string htmlbody = '';
            mail = new Messaging.SingleEmailMessage();
            if (owea.size() > 0) 
            {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            sendingTo.add(c.External_Email__c);
            mail.setToAddresses(sendingTo);
            mail.setSubject(temp[0].Subject);
            htmlbody = temp[0].HTMLValue;
            htmlbody = htmlbody.replace('{!Contact.FirstName}',c.FirstName);
            htmlbody = htmlbody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
            mail.setPlainTextBody(htmlbody);
            List<String> bccaddress = new list<String>();
            bccaddress.add('driverservices@mburse.com');
            mail.setBccAddresses(bccaddress);
            mail.setHtmlBody(htmlbody);
            mail_list.add(mail);
        }
        SendEmail__c  sendEmailObj = SendEmail__c.getValues('SendMileageReminderforDelta');
        if((sendEmailObj!=null) && sendEmailObj.Send_email_from_code__c==true && mail_list.size()>0 && !Test.isRunningTest())
        {
            Messaging.sendEmail(mail_list);  
        }
    }
    global void finish(Database.BatchableContext BC){

    }
    
}
