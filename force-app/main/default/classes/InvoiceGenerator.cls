/*******************************************************************************************************************************
* @Class Name    : Invoice Generator
* @Created Date       : May 31, 2023
* @description       : This class contians the future method.
* @author            : Yuvraj Singh
* @Modification Log:
*******************************************************************************************************************************/

public class InvoiceGenerator {
    
    /*********************************************************
    * @Method Name    : InvoiceGenerator
    * @author         : Yuvraj Singh
    * @description    : This method is used to generate an invoice of an closed won opprotunity.
    * @param          : List of Opportunities
    * @return         : Void
    *********************************************************/
    
    @future(callout=true)
    public static void oppProductInvoice(List<Id> oppIds){
        try{
            List<ContentVersion> cVersionList = new List<ContentVersion>();
            Map<String,Id> contentVersionOppIdMap = new Map<String,Id>();
            Map<Id, ContentVersion> OppIdWithContentVersion = new Map<Id, ContentVersion>();
            Map<Id,Id> ContentDocumentIdWithOppidMap = new Map<Id,Id>();
            for (Id opp : oppIds) {
                PageReference page = new PageReference('/apex/invoiceGenerator');
                page.getParameters().put('id', opp);
                
                ContentVersion cVersion = new ContentVersion();
                cVersion.ContentLocation = 'S';
                cVersion.Title = 'Deal Invoice #' + opp;
                cVersion.PathOnClient = cVersion.Title + '.pdf';
                cVersion.VersionData = page.getContentAsPDF();
                cVersionList.add(cVersion);
                contentVersionOppIdMap.put(cVersion.Title, opp);
                OppIdWithContentVersion.put(opp, cVersion);
                System.debug('=======OppIdWithContentVersion========' + OppIdWithContentVersion);
            }
            
            if (!cVersionList.isEmpty()) {
                INSERT cVersionList;
                System.debug('Map-->'+contentVersionOppIdMap);
            }
            List<ContentDocumentLink> cDocLinkList = new List<ContentDocumentLink>();
            for(ContentVersion cv : [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id IN :cVersionList]){
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = cv.ContentDocumentId;
                cDocLink.LinkedEntityId = contentVersionOppIdMap.get(cv.Title);
                System.debug(contentVersionOppIdMap.get(cDocLink.LinkedEntityId));
                cDocLink.Visibility = 'AllUsers';
                cDocLink.ShareType = 'V';
                cDocLinkList.add(cDocLink);
                ContentDocumentIdWithOppidMap.put(cv.ContentDocumentId, cDocLink.LinkedEntityId);
                System.debug('=======ContentDocumentIdWithOppidMap========' + ContentDocumentIdWithOppidMap);
            }
            
            if(!cDocLinkList.isEmpty()){
                try{
                    INSERT cDocLinkList;
                }
                catch(System.Exception e){
                    system.debug('Error-->'+e.getMessage());
                }
                
            }
            sendEmailWithAttachment(OppIdWithContentVersion, ContentDocumentIdWithOppidMap );
        }
        catch(Exception e){
            System.debug('==='+e);
            system.debug('====line number----===='+e.getLineNumber());
        }
    }
    
    /*********************************************************
    * @Method Name    : sendEmailWithAttachment
    * @author         : Yuvraj Singh
    * @description    : This method is used to send emails to customer
    * @param          : List of opportunity Id
    * @return         : Void
    *********************************************************/
    
    public static void sendEmailWithAttachment(Map<Id, ContentVersion> OppidWithContentVersion, Map<Id,Id> ContentDocumentIdWithOppId) {
        
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        // Loop through the opportunities to send emails with attachments
        for (OpportunityContactRole con : [SELECT OpportunityId, ContactId, contact.Name, contact.email FROM OpportunityContactRole WHERE OpportunityId IN :OppidWithContentVersion.keySet()]) {
            if (OppidWithContentVersion.containsKey(con.OpportunityId)) {
                ContentVersion cv = OppidWithContentVersion.get(con.OpportunityId);
                if (cv.VersionData != null) {
                    // Create the email message
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    
                    // Set the email recipients
                    email.setToAddresses(new List<String>{ con.contact.email });
                    
                    // Set the email subject and body
                    email.setSubject('Congratulations! Deal Closed Successfully');
                    email.setHtmlBody('Dear Customer,<br/><br/>Congratulations on the successful closure of our deal! We are grateful for your trust and look forward to a prosperous partnership. <br/>Thank you for choosing us.<br/>please find attached the invoice for Opportunity. <br/> Best Regards <br/> Horizontal');
                    
                    ContentVersion version = OppidWithContentVersion.get(con.OpportunityId);
                    Blob fileData = version.VersionData;
                    system.debug('=version==='+version);
                    system.debug('=fileData==='+fileData);
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setFileName(version.Title);
                    attachment.setBody(fileData);
                    email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });                    
                    emailMessages.add(email);
                }
            }
        }
        
        // Send the bulk emails
        Messaging.sendEmail(emailMessages);
    }
    
    
}