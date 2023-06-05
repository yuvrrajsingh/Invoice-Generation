/*******************************************************************************************************************************
* @Class Name    : OpportunityTriggerHandler
* @Created Date       : May 30, 2023
* @description       : This is logic handler class for opportunity Trigger
* @author            : Yuvraj Singh
* @Modification Log:
*******************************************************************************************************************************/

public with sharing class OpportunityTriggerHandler {

    /*********************************************************
    * @Method Name    : InvoiceGenerator
    * @author         : Yuvraj Singh
    * @description    : This method is used to generate an invoice of an closed won opprotunity.
    * @param          : List of Opportunities and Map of Old Opportunities
    * @return         : Void
    ********************************************************
    */
    public static void invoiceGenerator(List<Opportunity> OpList, Map<Id, Opportunity> oldMap) {
        // list to store the Ids of closed won opportunities
        List<Id> closedWonOpportunityIds = new List<Id>();
        for(Opportunity o : OpList){
            if((o.StageName != oldMap.get(o.Id).StageName) && (o.stageName == 'Closed Won')){
                closedWonOpportunityIds.add(o.Id);
            }
        }
        // calling future method to generate pdf using visualforce and send email to customer
        InvoiceGenerator.oppProductInvoice(closedWonOpportunityIds);
    }
}