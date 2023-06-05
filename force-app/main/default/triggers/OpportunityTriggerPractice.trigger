trigger OpportunityTriggerPractice on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	if(Trigger.isbefore){
        if(Trigger.isinsert){
            //TriggerHelperClass.OpportunityStageUpdate(Trigger.new);
            //TriggerHelperClass.scenerio9(Trigger.new);
        }
        if(Trigger.isDelete){
            TriggerHelperClass1.scenerio_2(Trigger.OldMap);
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isinsert){
            //TriggerHelperClass.Create_OLI(Trigger.new);
            //TriggerHelperClass.scenerio8(Trigger.new);
            
        }
        if(Trigger.isUpdate){
            //TriggerHelperClass1.Scenerio_1(Trigger.new, Trigger.oldMap);
            //TriggerHelperClass1.firePlatformEvent(Trigger.new , Trigger.OldMap);
            OpportunityTriggerHandler.InvoiceGenerator(Trigger.new, Trigger.oldMap);
        }
    }
}