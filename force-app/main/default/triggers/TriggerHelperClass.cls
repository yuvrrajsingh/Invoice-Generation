public class TriggerHelperClass {
    
    public static void preventDuplicate(List<Contact> conlst){
        List<Contact> clist = new List<Contact>();
        set<String> phnset = new set<String>();
        set<String> emailset = new set<String>();
        for(Contact c : conlst){
            phnset.add(c.Phone);
            emailset.add(c.Email);
        }
        for(contact c : [SELECT id, phone, email from contact WHERE phone IN :phnset OR email IN :emailset]){
            phnset.remove(c.Phone);
            emailset.remove(c.email);
        }
        for(Contact c : conlst){
            if(!phnset.contains(c.Phone) || !emailset.contains(c.Email)){
                c.addError('This contact is already present, please use existing contact.');
            }
        }
    }
    
    public static void SendEmail(List<Contact> clist){
        // create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(contact c : clist){
            if(c.Email != null && c.FirstName != null){
                // step 1 : Create a new Email
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                // step 2 : set list of people who should get the email
                List<String> sendTo = new List<string>();
                sendTo.add(c.Email);
                mail.setToAddresses(sendTo);
                
                // step 3 : set who the email is sent from
                mail.setReplyTo('uvrajawat27@gmail.com');
                mail.setSenderDisplayName('Yuvraj singh');
                
                // step 4 : set email contents - you can use variables!
                mail.setSubject('Welcome to our Organisation');
                string body = 'Dear '+ c.FirstName + ', ';
                body += 'Congratulation, you are the new contact';
                mail.setHtmlBody(body);
                
                // step 5 : Add your email to the master list
                mails.add(mail);
            }
        }
        // step 6 : send all emails in the master list
        Messaging.sendEmail(mails); 
    }
    
    public static void ContactDelete(List<Contact> clist){
        for(Contact c : clist){
            if(c.AccountId != null){ 
                c.addError('You can not delete this contact, as it is associated with an Account');
            }
        }
    }
    
    public static void NumberOfContacts(List<contact> clist){
        Set<Id> accids = new Set<Id>();
        for(Contact c : clist){
            accids.add(c.AccountId);
        }
        List<Account> listOfacc =[SELECT Id,Number_Of_Contacts__c,(SELECT Id FROM contacts) FROM Account WHERE Id IN:accids];
        for(Account acc : listOfacc){
            acc.Number_Of_Contacts__c = acc.Contacts.size();
        }
        update listOfacc;
    }
    
    public static void LeadUpdate(List<Lead> l){
        for(Lead led : l){
            led.Rating = 'Hot';
            
        }
    }
    
    Public static void OpportunityStageUpdate(List<Opportunity> op){
        for(Opportunity o : op){
            o.StageName = 'Prospecting';
            o.CloseDate = Date.TODAY()+15;
        }
    }
    
    Public static void AccountOwnership(List<Account> acc){
        for(Account a : acc){
            a.Ownership = 'Public';
        }
    }
    
    Public static void Account_Del_With_Contact(List<Contact> con){
        
        Set<Id> accId = new Set<Id>();
        for(Contact c : con){
            accId.add(c.AccountId);
        }
       delete [Select Id From Account where Id IN:accId];
        
    }
    
    Public static void Event_on_Contact(List<Contact> clist){
        List<Event> elist = new List<Event>();
        for(Contact c : clist){
            Event e = new Event();
            e.WhoId = c.Id;
            e.Subject = 'Event for '+c.FirstName;
            e.StartDateTime = System.today();
            e.EndDateTime = System.today() + 10;
            
            elist.add(e);
        }
        insert elist;
    }
    
    public static void Del_Existing_Account(List<Account>aclist){
        set<string> acNames = new set<string>();
        for(account a : aclist){
            acNames.add(a.Name);
        }
        List<Account> ac = [SELECT id, Name from Account WHERE name IN :acNames];
        if(ac.size() > 0){
            DELETE ac;
        }
    }
    
    Public static void prevent_Duplicate_Accounts(List<Account> aclist){
        set<string> acname = new set<string>();
        for(account a : aclist){
            acname.add(a.Name);
        }
        for(account a : [SELECT id , name from account WHERE name IN :acname]){
            acname.remove(a.Name);
        }
        for(account a : aclist){
            if(!acname.contains(a.Name)){
                a.addError('Account is already present with this name!');
            }
    	}
    }
    
    public static void UpdateContactPhone(List<Account> aclist){
        map<id, string> acmap = new map<id, string>();
        for(account a : aclist){
            if(a.Phone != null){
                acmap.put(a.Id, a.Phone);
            }
        }
        List<contact> clist = [SELECT id, AccountId from contact WHERE AccountId IN :acmap.keyset()];
        for(contact c : clist){
            if(acmap.containsKey(c.AccountId)){
                c.Phone = acmap.get(c.AccountId);
            }
        }
        UPDATE clist;
    }
    
    public static void Del_Duplicate_Account_Contacts(List<Account> aclist){
        List<String> accNamelst = new List<String>();
        List<Contact> Contacts_to_del = new List<Contact>(); 
        for(Account a : aclist){
            accNamelst.add(a.Name);
        }
        for(Account a : [SELECT Id, Name,(Select Id From Contacts) FROM Account WHERE Name IN :accNamelst]){
            for(Contact c : a.contacts){
                Contacts_to_del.add(c);
            }
        }
        if (Contacts_to_del.size() > 0){
            delete Contacts_to_del;
        }
    }
    
    public static void Account_Dis_Ind_Own_Rat(List<Account> aclist){
        for(Account a : aclist){
            a.Description = 'Hello';
            a.Industry = 'Banking';
            a.Ownership = 'Public';
            a.Rating = 'Hot';
            a.Phone = '111';
        }
    }
    
     public static void Update_Account_Opportunities(List<Account> aclist){
        set<id> acids = new set<id>();
        List<Opportunity> oplist = new List<Opportunity>();
        for(Account a : aclist){
            acids.add(a.id);
        }
        for(Account a : [SELECT Id, Name, (SELECT id, StageName, CreatedDate from Opportunities) FROM Account WHERE id IN :acids]){
            for(Opportunity o : a.Opportunities){
                if(o.CreatedDate < System.today()+30 && o.StageName != 'Closed Won'){
                    o.StageName = 'Closed Lost';
                    oplist.add(o);
                }
            }
        }
        UPDATE oplist;
    }
    
    public static void new_contact_insert(List<Account> aclist){
        List<Contact> clist = new List<Contact>();
        for(Account a : aclist){
            Contact con = new Contact(lastname = a.Name, AccountId = a.Id);
            clist.add(con);
        }
        INSERT clist;
    }
    
    public static void Total_Opportunity_Amount(List<Account> aclist,Map<Id,Account> oldMap ){
        Set<Id> accid = new Set<Id>();
        List<Account> acclist = new List<Account>();
        for(Account a : aclist){
            if(a.Name != oldMap.get(a.Id).Name){
                accid.add(a.id);
            System.debug('=accid=='+accid);
            }
            
        }
        for(Account a : [SELECT Id, Name,Total_Opportunity_Amount__c, (SELECT id, Amount FROM Opportunities) FROM Account WHERE Id IN :accid]){
            decimal totalamt= 0;
            System.debug('=a=='+a);
            for(Opportunity opp : a.Opportunities){
                  System.debug('=opp=='+opp);
               totalamt += opp.Amount;
                 System.debug('=totalamt=='+totalamt);
            }
            a.Total_Opportunity_Amount__c = totalamt;
            acclist.add(a);
            System.debug('=acclist=='+acclist);
        }
        update acclist;
    }

    
    public static void Contact_update_oppAmt(List<Contact> clist){
        set<ID> accIds = new set<ID>();
        List<Account> aclst = new List<Account>();
        for(Contact c : clist){
            accIds.add(c.AccountId);
            System.debug('==ccId=='+accIds);
        }
        
        for(Account a : [Select Id, Name, Total_Opportunity_Amount__c, (SELECT id, Amount from opportunities) FROM Account WHERE Id IN : accIds]){
             System.debug('==a=='+a);
            Double TotAmt = 0.0;
            for(Opportunity o : a.opportunities){
                System.debug('==o=='+o);
                TotAmt += o.Amount;
                System.debug('==TotAmt=='+TotAmt);
            }
            a.Total_Opportunity_Amount__c = TotAmt;
            aclst.add(a);
            System.debug('==aclst=='+aclst);
        }
        if(aclst.size() > 0){
            update aclst;
        }
    }
    
    
    
    public static void Account_Type_Change(List<Account> aclist, Map<Id,Account> OldMapAcc ){
        set<ID> accids = new set<ID>();
        for(Account a : aclist){
            if(a.Type != OldMapAcc.get(a.Id).Type){
                accids.add(a.Id);
            }
        }
        // creating master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(Account a : [SELECT Id, Name, (SELECT id,FirstName, Email FROM contacts) FROM Account WHERE Id IN :accids]){
            for(Contact c : a.contacts){
                if(c.Email != null && c.FirstName != null){
                    // create new email
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    // set list of people who should get the email
                    List<string> sendTo = new List<string>();
                    sendTo.add(c.Email);
                    mail.setToAddresses(sendTo);
                    
                    // set who the mail is sent from
                    mail.setReplyTo('uvrajawat27@gmail.com');
                    mail.setSenderDisplayName('Jeet singh Rajput');
                    
                    // set email contents - you can use variables
                    mail.setSubject(' Account Update Info');
                    string body = ' Your account information has been updated successfully. Account Name : ' + a.Name;
                    
                    mail.setHtmlBody(body);
                    
                    // add your email to the master list
                    mails.add(mail);
                }
            }
        }
        //  Send all emails in the master list
        Messaging.sendEmail(mails);
    } 
    
    public static void Create_OLI(List<Opportunity> oplist){
        List<OpportunityLineItem> oliLst = new List<OpportunityLineItem>();
        
        Pricebook2 stdpb = [SELECT  id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Product2 prd1 = new Product2(Name = 'Accomodation');
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry();
        pbe1.Product2Id = prd1.Id;
        pbe1.Pricebook2Id = stdpb.Id;
        pbe1.UnitPrice = 60;
        pbe1.IsActive = True;
        insert pbe1;
        
        for(Opportunity o : oplist){
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = o.Id;
            oli.PricebookEntryId = pbe1.Id;
            oli.Quantity = 4;
            oli.TotalPrice = 400.0;
            
            oliLst.add(oli);
        }
        insert oliLst;
    }
    
    public static void Task_Delete(List<Task> tsk){
        Id pid = userinfo.getProfileId();
        Profile p = [SELECT Name from Profile WHERE id = :pid];
        for(Task t : tsk){
            if(p.Name != 'System Administrator'){
                t.addError('Only System Admin can delete task');
            }
        }   
    }
    
    public static void Interview_Que1(List<Account> ac){
        Integer No_of_contacts_to_create;
        List<Contact> contactlst = new List<Contact>();
        for(Account a : ac){
            No_of_contacts_to_create = (Integer)a.Max_Amount__c/10 ;
            for(integer i=0; i<No_of_contacts_to_create; i++){
            	Contact c = new Contact();
                c.LastName = 'Test'+i;
                c.AccountId = a.Id;
                
                contactlst.add(c);
        	}
        }
        if(contactlst.size() > 0){
            insert contactlst;
        }
    }
    
    // When an account BillingCity is update , update all contacts MailingCity with account BillingCity
    public static void Updating_Cnt_Mailing_City(List<Account> ac, Map<Id, Account> omap){
        Set<id> accIds = new Set<id>();
        List<Contact> cnt_lst_to_update = new List<Contact>();
        for(Account acc : ac){
            accIds.add(acc.Id); 
        }
        for(Account a : [Select Id, Name, BillingCity, (Select Id, MailingCity From contacts) From Account Where id IN :accIds]){
            for(Contact c : a.contacts){
                // checking for acc. billing city update.
                if(a.BillingCity != omap.get(a.Id).BillingCity){
                    c.MailingCity = a.BillingCity;
                    cnt_lst_to_update.add(c);
                }
            }
        }
        update cnt_lst_to_update;
    }
    
    //When Contact update collect all opportunity Amount And Update this amount on Account Level Field (Total Opportunity Amount)
    public static void Update_Opportunity_Amount_on_Acc(List<Contact> clist){
        Set<id> AcIds = new Set<id>();
        List<Account> aclst = new List<Account>();
        for(Contact c : clist){
            AcIds.add(c.AccountId);
        }
        for(Account a : [Select Id, Total_Opportunity_Amount__c, (Select id, Amount From Opportunities) From Account Where id IN :AcIds]){
            Double Tot_Amt = 0.0;
            for(Opportunity o : a.Opportunities){
                Tot_Amt += o.Amount;
            }
            a.Total_Opportunity_Amount__c = Tot_Amt;
            aclst.add(a);
        }
        Update aclst;     
    }
    
    // Add a field Multi select Pick list on Account And Opportunity as well and add values A,B,C,D,F
	//Now if we update an Opportunity with this multi select value Account should also update with same picklist values
    public static void Update_Acc_with_opp(List<Opportunity> oplist, Map<Id, Opportunity> oldopp){
        Set<id> accids = new Set<id>();
        Map<id, string> countryMap = new Map<id,string>();
        List<Account> acc_lst_to_update = new List<Account>();
        for(Opportunity o : oplist){
            if(o.Demo_Multi_Select_Picklist__c != oldopp.get(o.Id).Demo_Multi_Select_Picklist__c){
                if(o.AccountId != Null){
                    countryMap.put(o.AccountId, o.Demo_Multi_Select_Picklist__c);
                    accids.add(o.AccountId);
                }
            }
        }
        for(Account a : [Select id, Demo_Multi_Select_Picklist__c From Account Where id IN :accids]){
            if(countryMap.containsKey(a.Id)){
                String c = countryMap.get(a.Id);
                a.Demo_Multi_Select_Picklist__c = c;
                acc_lst_to_update.add(a);
            }
        }
        if(acc_lst_to_update.size() > 0){
            update acc_lst_to_update;
        }
    }
    
    // Once an Opportunity line item will create insert a quotation also.
    public static void creating_Quatation(List<OpportunityLineItem> OpLineIteam){
        Set<id> Opids = new Set<id>();
        List<Quote> QuoteList = new List<Quote>();
        for(OpportunityLineItem x : OpLineIteam){
            Opids.add(x.OpportunityId);
        }
        for(Opportunity o : [Select id from Opportunity Where id IN :Opids]){
            Quote q = new Quote(OpportunityId = o.Id, Name = 'Test1');
            QuoteList.add(q);
        }
        insert QuoteList;
    }
    
    // Write a trigger on Opportunity line item when a line item deletes delete an opportuntiy as well
    public static void Del_Opp(List<OpportunityLineItem> opli){
        Set<id> opids = new Set<id>();
        for(OpportunityLineItem o : opli){
            opids.add(o.OpportunityId);
        }
        Delete [Select id From Opportunity Where id IN :opids];
    }
    
    // Once an opportunity line item will create update Opportunity's Account with the total number of Product Quantities.
	//Create a field first on Account "Total sales quantities".
    public static void Update_Total_sales_Qunantities(List<OpportunityLineItem> opli){
        Set<id> opids = new Set<id>();
        Map<id, Integer> countryMap = new Map<id, Integer>();
        Set<id> accids = new Set<id>();
        List<Account> ac_lst_to_update = new List<Account>();
        for(OpportunityLineItem x : opli){
            opids.add(x.OpportunityId);
        }
        for(Opportunity o : [Select id, AccountId, (Select id From OpportunityLineItems) From Opportunity Where id IN :opids]){
            if(o.AccountId != null){
                accids.add(o.AccountId);
                countryMap.put(o.AccountId, o.OpportunityLineItems.size());
            }
        }
        for(Account a : [Select id, Total_sales_quantities__c From Account Where id IN:accids]){
            a.Total_sales_quantities__c = countryMap.get(a.Id);
            ac_lst_to_update.add(a);
        }
        if(ac_lst_to_update.size() > 0){
            update ac_lst_to_update;
        }
    }
    
    // While user creating an account, if annual revenue provided by user is less than 1000, 
    // then write a logic to throw an error to user.
    public static void annualRevenue(List<Account> aclist){
        for(Account a : aclist){
            if (a.AnnualRevenue < 1000){
                a.addError('Annual Revenue should be greater than 1000');
            }
        }
    }
    
    // When user updates account record , ifuser chanes account name, 
    // thow an error "Account name once created cannnot be modified"
    public static void AccountNameChange(List<Account> aclist, Map<ID, Account> oldm){
        for(Account a : aclist){
            if(a.Name != oldm.get(a.Id).Name){
                a.addError('Account name once created cannnot be modified');
            }
        }
    }
    
    // An active account should not be deleted.
    public static void preventDeletActiveAccounts(List<Account> aclist){
        for(Account a : aclist){
            if(a.Active__c == 'Yes'){
                a.addError('You can not delete Active Accounts.');
            }
        }
    }
    
    // Send an email to user, when user restores an account form recycle bin.
    public static void SendEmail_Account_restore(List<Account> aclist){
        
    }
    
    // create a trigger when an record is updated on ContactAdditionalDetail object if onboarding status field is changed.
    // And update the current date on contact(parent) object onboarding status field. ContactAdditionalDetail is child obj of contact.
    public static void UpdateContactStatusDate(List<Contact_Additional_Detail__c> adConLst, Map<Id, Contact_Additional_Detail__c> omap){
        set<Id> contactIds = new set<Id>();
        List<contact> contactList = new List<contact>();
        for(Contact_Additional_Detail__c x : adConLst){
            if(x.Onboarding_Status__c != omap.get(x.id).Onboarding_Status__c){ 
                contactIds.add(x.Contact__c);
            }
        }
        for(Contact c : [SELECT Id FROM contact WHERE Id IN :contactIds]){
            c.Onboarding_Status_Date__c = System.Date.today();
            contactList.add(c);
        }
        UPDATE contactList;
    }
    
    // SUPERB QUESTION
    
    // write a trigger on contact insertion, if there is no account associated with the inserted contact , 
    // then crate an account and associate with that contact
    public static void Task1(List<contact> conlist){
        Map<id, string> mycountry = new Map<id, string>();
        set<string> conName = new set<string>();
        for(contact c : conlist){
            if(c.AccountId == null){
                mycountry.put(c.Id,c.LastName);
            }
        }
        List<string> acname = new List<string>();
        List<Account> ac = new List<Account>();
        acname = mycountry.values();
        for(string s : acname){
            Account a = new Account(Name=s);
            ac.add(a);
        }
        INSERT ac;
        
        for(Account a : [SELECT id, Name FROM Account WHERE name IN:mycountry.values() ]){
            for(contact c : conlist){
                if(c.LastName == a.Name)
                {
                    c.AccountId=a.Id;
                }
            }
        }
    }
    
    
    // neilon Technologies interview que.
    
    
    // When new contact is created for the account, if contact Mailing country is blank, 
    // set account billing country in contact mailingCountry via Apex Trigger.
    public static void Question1(List<contact> conlist){
        List<contact> con = new List<contact>();
        set<id> conids = new set<id>();
        for(contact c : conlist){
            if(c.MailingCountry == null){
                con.add(c);
                conids.add(c.AccountId);
            }
        }
        for(Account a : [SELECT id, name, BillingCountry FROM Account WHERE id IN :conids]){
            for(contact c : conlist){
                if(c.AccountId == a.Id){
                    c.MailingCountry = a.BillingCountry;
                }
            }
        }
    }
    // Delete all the contacts related to account, when account gets deleted 
    public static void Question2(List<Account> aclist){
        set<id> accids = new set<id>();
        for(Account a : aclist){
            accids.add(a.Id);
        }
        DELETE [SELECT id, name, AccountId FROM Contact WHERE AccountId IN :accids];
    }
    
    
    
    // Way of writting code is improved
    
    //scenerio - 1
    // When user change the phone number on account object then same phone should be upated on all the related contacts
    public static void Scenerio_01(List<Account> aclist, map<id, Account> acmap ){
        map<id, string> mymap = new map<id, string>();
        for(Account a : aclist){
            if(a.Phone != acmap.get(a.Id).Phone){
                mymap.put(a.Id, a.Phone);
            }
        }
        List<Contact> conList = [SELECT id, AccountId, Phone FROM Contact WHERE AccountId IN :mymap.keyset()];
        if(conList.size() > 0){
            for(Contact c : conList){
                if(mymap.containskey(c.AccountId)){
                    c.Phone = mymap.get(c.AccountId);
            	}
        	}
        	UPDATE conList;
        }
    }
    
 	//Scenerio - 2
    // when a user create, update, delete and undelete the contact associated with account object then in that case
    // account should be updated the field "No of contacts".
    
    public static void Scenerio_02_create(List<Contact> conlist){
        set<id> acids = new set<id>();
        for(contact c : conlist){
            if(c.AccountId != null){
                acids.add(c.AccountId);
            }
        }
        List<Account> aclist = [SELECT id, Number_Of_Contacts__c,(SELECT id FROM contacts) FROM Account WHERE id IN :acids];
        for(Account a : aclist){
            a.Number_Of_Contacts__c = a.contacts.size() + 1;
        }
        UPDATE aclist;
    }
    
    public static void Scenerio_02_update(List<contact> conlist){
        set<id> acids = new set<id>();
        for(contact c : conlist){
            if(c.AccountId != null){
                acids.add(c.AccountId);
            }
        }
        List<Account> alist = [SELECT id, Number_Of_Contacts__c, (SELECT id from contacts) FROM Account WHERE id IN:acids];
        for(Account a : alist){
            a.Number_Of_Contacts__c = a.contacts.size();
        }
        UPDATE alist;
    }
    
    public static void Scenerio_02_delete(List<contact> conlist){
        set<id> acids = new set<id>();
        for(contact c : conlist){
            if(c.AccountId != null){
                acids.add(c.AccountId);
            }
        }
        List<Account> aclist = [SELECT id, Number_Of_Contacts__c, (SELECT id from contacts) FROM Account WHERE id IN :acids];
        for(Account a : aclist){
            a.Number_Of_Contacts__c = a.contacts.size() - 1;
        }
        UPDATE aclist;
    }
    
    public static void Scenerio_02_undelete(List<contact> conlist){
        set<id> acids = new set<id>();
        for(contact c : conlist){
            if(c.AccountId != null){
                acids.add(c.AccountId);
            }
        }
        List<Account> aclist = [SELECT id, Number_Of_Contacts__c, (SELECT id FROM contacts) FROM Account WHERE id IN :acids];
        for(Account a : aclist){
            a.Number_Of_Contacts__c = a.contacts.size();
        }
        UPDATE aclist;
    }
    
    
    // Create a picklist field on contact with 3 values(status - Draft, Inprogress, Completed) Create 3 number fields on
    // Account, one for each picklist option(Draft Count,In-Progress Count, Completed Count) When a Contact is created/updated
    // deleted, update the related number field on Account with the Contact count with each status.
    
    public static void Scenerio_03_create(List<contact> conlist){
        map<id, string> mymap = new map<id, string>();
        for(contact c : conlist){
            if(c.AccountId != Null){
                mymap.put(c.AccountId, c.Status__c);
            }
        }
        scenerio3_handler(mymap);
    }
    
    public static void Scenerio_03_update(List<contact> conlist, map<id,contact> oldConList){
        map<id, string> mymap = new map<id, string>();
        for(contact c : conlist){
            if((c.Status__c != oldConList.get(c.Id).status__c) && (c.AccountId != null)){
                mymap.put(c.AccountId, c.Status__c);
            }
        }
        scenerio3_handler(mymap);
        
    }
    public static void scenerio3_handler(map<id, string> mymap){
        List<Account> aclist = [SELECT id, Draft_Count__c, InProgress_Count__c, Completed_Count__c FROM Account WHERE id IN :mymap.keyset()];
        if(aclist.size() > 0){
            for(Account a : aclist){
                if(mymap.containskey(a.Id)){
                    string x = mymap.get(a.Id);
                    switch on x{
                        when 'Draft' { a.Draft_Count__c += 1; }
                        when 'InProgress' {a.InProgress_Count__c += 1;}
                        when 'Completed' {a.Completed_Count__c += 1;}
                    }
                }
            }
            UPDATE aclist;
        }
    }
    
    
    // Write a trigger to throw error when the user tries to inactive the Account and if the account has at least one open
    // opportunity (open opportunity means stageName neither closed won nor close lost)
     
    public static void AccountInactiveError(List<Account> aclist){
		set<id> acids = new set<id>();
        for(Account a : aclist){
            if(a.Active__c == 'NO'){
                acids.add(a.Id);
            }
        }
        map<id, Account> map1 = new map<id, Account>();
        for(Account a : [SELECT id, (SELECT id, StageName from opportunities) from Account where id IN :acids]){
            for(opportunity o : a.opportunities){
                if(o.StageName != 'Closed Won' && o.StageName != 'Closed Lost'){
                    map1.put(a.Id, a);
                    break;
                }
            }
        }
        for(Account a : aclist){
            if(map1.containsKey(a.id)){
                a.addError('You can not Inactive the account having open opportunities');
            }
        }    
    }
    
    
    // write a trigger on contact. when an account is change on contact, then delete all the child record of contact object(favourate__c
    // is the child obj of contact). In this case delete all the favourate records
    
    public static void DelContactChildRec(List<contact> conlist, map<id, Contact> omap){
        set<Id> contactIds = new set<Id>();
        for(Contact c : conlist){
            if(c.AccountId != omap.get(c.Id).AccountId){
                contactIds.add(c.Id);
            }
        }
        List<favourate__c> favList = new List<favourate__c>();
        if(contactIds.size() > 0){
            for(Contact c : [SELECT id, (SELECT id from favourates__r) from Contact WHERE id IN :contactIds]){
                for(favourate__c f : c.favourates__r ){
                    favList.add(f);
                }
            }
        }
        if(favList.size() > 0){
            DELETE favList;
        }
        
    }
    
    // If your lead is created with an existing email id of contact records then validate and incapaciteate lead creation.
    public static void Lead_Email_Check(List<Lead> ld){
        set<string> emailset = new set<string>();
        for(Lead l : ld){
            if(l.Email != NULL){
                emailset.add(l.Email);
            }
            
        }
        for(Contact c : [Select id, Email from contact where Email IN :emailset]){
            emailset.remove(c.Email);
        }
        for(Lead l : ld){
            if(l.email != Null && !emailset.contains(l.email)){
                l.Email.addError('Email is already present in salesforce contact records');
            }
        }
        
    }
    
    // write a trigger to create the number of contacts according the number present in "Number of employee" field on account
    public static void ContactCreation(List<Account> aclist){
        map<id, integer> mini = new map<id, integer>();
        for(Account a : aclist){
            if(a.Id != Null && a.NumberOfEmployees != Null){
                mini.put(a.Id, a.NumberOfEmployees);
            }
        }
        List<contact> clist = new List<contact>();
        for(Account a : aclist){
            if(mini.ContainsKey(a.Id)){
                for(integer i=1; i<=mini.get(a.Id); i++){
                    contact c = new contact(lastName = 'test'+i, AccountId = a.Id);
                    clist.add(c);
            	}
            }
            
        }
        if(clist.size()>0){
            INSERT clist;
        }
        
    }
    
    // Internship Trigger Question
    
    // Write a trigger to count total products associated. update the field "No_of_products" on opportunity
    public static void scenerio1(List<opportunityLineItem> oliList){
        set<id> opid = new set<id>(); 
        for(opportunityLineItem ol : oliList){
            opid.add(ol.OpportunityId);
        }
        List<Opportunity> oplist = [SELECT id, No_Of_Products__c, (SELECT id from OpportunityLineItems) FROM opportunity where id IN :opid];
        for(Opportunity o : oplist ){
            o.No_Of_Products__c = o.OpportunityLineItems.size();
        }
        UPDATE oplist;
        
    }
    
    // Write a trigger on Opportunity LineItem , when Line Item is deletes, delete an opportunity as well.
    
    public static void scenerio2(List<opportunityLineItem> oliList){
        set<id> opids = new set<id>(); 
        for(OpportunityLineItem ol : oliList){
            opids.add(ol.OpportunityId);
        }
        DELETE [Select id from Opportunity where id IN :opids];
    }
    
    // Once an opportunity line item will create update Opportunity's Account with the total number of Product Quantities.
	// Create a field first on Account "Total sales quantities".
    public static void scenerio3(List<opportunityLineItem> oliList){
        set<id> opids = new set<id>();
        for(opportunityLineItem ol : oliList){
            Opids.add(ol.OpportunityId);
        }
        map<id,integer> mymap = new map<id,integer>();
        for(Opportunity o : [SELECT id, AccountId, (SELECT id from opportunityLineItems) FROM Opportunity WHERE id IN :opids]){
            mymap.put(o.AccountId, o.opportunityLineItems.size());
        }
        List<Account> aclist = [SELECT id, Total_sales_quantities__c FROM Account WHERE id IN :mymap.keyset()];
        for(Account a : aclist){
            if(mymap.containskey(a.Id)){
                a.Total_sales_quantities__c = mymap.get(a.Id);
            }  
        }
        UPDATE aclist;
    }
    
    // Write a trigger on Opportunity line item when a line item deletes delete an opportuntiy as well
    public static void scenerio4(List<opportunityLineItem> oliList){
        set<id> Opids = new set<id>();
        for(opportunityLineItem op : oliList){
            Opids.add(op.OpportunityId);
        }
        DELETE [SELECT id from Opportunity WHERE id IN: Opids];
    }
    
    // Once Opportunity Line Line Item is added to Opportunity with the specified product,Then Product Total Quantities 
    // must be deduct from the Product Object
    public static void scenerio5(List<opportunityLineItem> oliList){
        map<id,decimal> mymap = new map<id,decimal>();
        for(opportunityLineItem ol : oliList){
            mymap.put(ol.Product2Id, ol.Quantity);
        }
        List<Product2> productList = [SELECT id, Total_Quantity__c, Available_Quantity__c from product2 WHERE id IN :mymap.keyset()];
        for(Product2 p : productList){
            if(mymap.containskey(p.Id)){
                decimal x = mymap.get(p.Id);
               	p.Available_Quantity__c = p.Total_Quantity__c - x;
            }
        }
        UPDATE productList;
        
    }
    
    // Write a trigger on Opportunity line item , Add two picklist values in Product Family field
	//Electronic and Books And a picklist Product type on Opportunity with same picklist values
	//Now once you add a line item into Opportunity, check if Opportunity Product Type is same as opli Product Family 
	//let it be insert or add error The Product family does not match.
    public static void scenerio6(List<opportunityLineItem> oliList){
        map<id, string> mymap = new map<id, string>();
        for(opportunityLineItem ol : oliList){
            mymap.put(ol.OpportunityId, ol.Product_Family__c);
        }
        for(opportunity o : [SELECT id, Product_type__c FROM Opportunity WHERE id IN :mymap.keyset()]){
            for(opportunityLineItem op : oliList){
                if(mymap.containskey(o.Id)){
                    if(o.Product_type__c != mymap.get(o.Id)){
                        op.addError('The Product family does not match');
                    }
                }
            }
        }
    }
    
    // When a case is created and contact is associated, then contact's contact number should be populated in the custom field 'contact Info' in the case object.
    public static void scenerio7(List<Case> caseList){
        system.debug('scenerio stated');
        set<id> contId = new set<id>();
        for(Case ca : caseList){
            if(ca.ContactId != Null){
                contId.add(ca.ContactId);
                system.debug('contact id collected');
            }
        }
        map<id,string> mymap = new map<id, string>();
        for(Contact c : [Select id, Phone from Contact WHERE id IN :contId]){
            mymap.put(c.Id, c.Phone);
            system.debug('map created');
        }
        
        for(case ca : caseList){
            if(mymap.containsKey(ca.ContactId)){
                ca.contact_Info__c = mymap.get(ca.ContactId);
                system.debug('assigned');
            }
        }
    }
    
    // KrazyTech Task(Madhura P)
    public static void scenerio8(List<opportunity> oplist){
        set<id> Vid = new set<id>();
        for(Opportunity o : oplist){  
            Vid.add(o.VendorID__c);            
        }
        system.debug('vid'+Vid);
        List<Vendor__c> lstToUpdate = new List<Vendor__c>();
        List<Vendor__c> vlist =  [SELECT id, Amount__C, Total_Number_of_Opportunity__c, (SELECT id, Amount FROM Opportunities__r) FROM Vendor__C WHERE id IN :Vid];
        for(Vendor__c v : vlist){
            double total_amt=0.0;
            for(Opportunity o : v.Opportunities__r){
                if(o.Amount != Null){
                    total_amt = total_amt + o.Amount;
                }
            }
            v.Amount__c = total_amt;
            v.Total_Number_of_Opportunity__c = v.Opportunities__r.size();
            lstToUpdate.add(v);
        }
        if(lstToUpdate.size() > 0){
            UPDATE lstToUpdate;
        }
        
    }
    
    // If an Account record has one close opportunity then prevent another closed opportunity with the same account.
    public static void scenerio9(List<Opportunity> oplist){
        map<Id, boolean> mymap = new map<Id, boolean>();
        for(opportunity o : oplist){
            if(o.AccountId != null){
                mymap.put(o.AccountId, false);
            }
        }
        for(Account a : [SELECT id, (SELECT id,AccountId, StageName FROM opportunities) FROM Account WHERE id IN :mymap.keyset()]){
            for(Opportunity o : a.opportunities){
                if(o.StageName == 'Closed Won' || o.StageName == 'Closed Lost'){
                    mymap.put(o.AccountId, True);
                    break;
                }
            }
        }
        for(Opportunity o : oplist){
            if(mymap.containsKey(o.AccountId)){
                if(mymap.get(o.AccountId) == True){
                    o.addError('Closed Opportunity already exist!!');
                }
            }
        }
        
    }
    
    public static void Interview(List<Account> aclist){
        set<id> acids = new set<id>();
        for(Account a : aclist){
            acids.add(a.Id);
        }
        for(Account ac : [Select id, name, (Select id from contacts) From Account WHERE id IN :acids]){
            integer x = ac.contacts.size();
            if(x > 0){
                ac.addError('You can not delete the account as it is associated with an contact');
            }
        }
    }
    
    
}