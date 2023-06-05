public class TriggerHelperClass1 {
    
	//Scenario: When an opportunity stagename is updated to Closed won then update it's related Account's custom picklist 
	//field(type_of_account__c) value to Existing Customer.
	//Note: type of account is a custom picklist field on account with values new customer, existing customer.
    public static void Scenerio_1(List<Opportunity> oplist, Map<id,Opportunity> omap){
        set<id> acids = new set<id>();
        for(Opportunity o : oplist){
            if((o.stagename != omap.get(o.Id).stagename) && o.stagename=='Closed Won'){
                acids.add(o.AccountId);
            }
        }
        if(acids.size() > 0){
            List<Account> aclist = [SELECT id, type_of_account__c FROM Account WHERE id IN :acids];
            for(Account a : aclist){
                a.type_of_account__c = 'Existing customer';
            }
            
            if(aclist.size() > 0){
                UPDATE aclist;
            }
        }
    }
    
    //Trigger Scenario: Prevent a user from deleting an Opportunity if an Active quote exists against that Opportunity.
    public static void scenerio_2(Map<id,Opportunity> omap){
        for(Quote q : [SELECT OpportunityId from Quote WHERE OpportunityId IN :omap.keyset() AND status = 'Active']){
            Opportunity op = omap.get(q.OpportunityId);
            op.addError('cannot delete opportunity with Active Quote');
        }
    }
    
    // Trigger Scenario: Whenever the Account is created with Industry as Banking then create a Contact for Account, 
    // Contact LastName as Account Name and Contact Phone as Account Phone.
    public static void scenerio_3(List<Account> aclist){
        List<contact> clist = new List<contact>();
        for(Account a : aclist){
            if(a.Industry == 'Banking'){
                Contact c = new Contact(AccountId=a.Id, LastName=a.Name);
                clist.add(c);
            }
        }
        INSERT clist;
    }
        
        
    
    // when an opportuninty is created on account, put the latest opportunity amout on the account;
    public static void scenerio_3(List<opportunity> oplist){
        map<id,decimal> mymap = new map<id, decimal>();
        for(opportunity o : oplist){
            if(o.AccountId != null){
                mymap.put(o.AccountId, o.Amount);
            }
        }
        List<Account> aclist = [SELECT id, Opportunity_latest_amount__c from Account WHERE id IN :mymap.keySet()];
        for(Account a : aclist){
            if(mymap.containsKey(a.id)){
                a.Opportunity_latest_amount__c = mymap.get(a.Id);
            }
        }
        UPDATE aclist;
    }
    
    // If an Account has related Contacts and the user tries to delete that Account it throws an error 
    // "Account cannot be deleted".
    
    public static void scenerio_4(List<Account> aclist){
        set<id> acids = new set<id>();
        for(account a : aclist){
            acids.add(a.id);
        }
        map<id,Account> mymap = new map<id,Account>([SELECT id, (SELECT id FROM contacts) FROM Account WHERE id IN :acids]);
        for(account ac : aclist){
            if( mymap.get(ac.id).contacts.size() > 0 ){
                ac.addError('Account cannot be deleted');
            }
        }
    }
    
    // practice demo
    public static void practice(List<Account> aclist){
        set<string> acnames = new set<string>();
        List<contact> cont_to_del = new List<contact>();
        for(Account a : aclist){
            acnames.add(a.Name);
        }
        List<Account> acclist = [Select id, name, (Select id from contacts) from Account Where name IN :acnames];
        for(Account a : acclist){
            for(Contact c : a.contacts){
                cont_to_del.add(c);
            }
        }
        delete cont_to_del;
    }

    // fire platform event when an opportunity is close won.
    public static void firePlatformEvent(List<opportunity> oplist, Map<Id, Opportunity> oldOppMap){
        system.System.debug('function invoked');
        List<Opportunity> closedWonOpportunity = new List<Opportunity>();
        for(Opportunity o : oplist){
            if(o.stageName == 'Closed Won' && oldOppMap.get(o.Id).StageName != 'Closed Won'){
                closedWonOpportunity.add(o);
            }
        }
        if(!closedWonOpportunity.isEmpty()){
            system.debug('list is not empty');
            List<CloseWonOppPlatformEvent__e> events = new List<CloseWonOppPlatformEvent__e>();
            for(Opportunity opp : closedWonOpportunity){
                CloseWonOppPlatformEvent__e	event = new CloseWonOppPlatformEvent__e();
                event.Opportunity_Id__c = opp.Id;
                event.Amount__c = opp.Amount;
                event.Opportunity_Name__c = opp.Name;
                event.Status__c = opp.StageName;
                event.OppOwnerId__c = opp.OwnerId;
                system.debug(opp.OwnerId);

                events.add(event);
            }
            if(events.size() > 0){
                EventBus.publish(events);
                system.debug('event fired.....');
            }
            
        }
    }
    
    
}