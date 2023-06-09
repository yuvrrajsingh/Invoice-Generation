/*******************************************************************************************************************************
* @Class Name    : FieldSetController
* @Created Date       : June 08, 2023
* @description       : This class provides functionality to work with field sets of an object
* @author            : Yuvraj Singh
* @Modification Log:
*******************************************************************************************************************************/


public with sharing class FieldSetController {

    // Default Constructor
    public FieldSetController() {

    }

    /*********************************************************
    * @Method Name    : getForm
    * @author         : Yuvraj Singh
    * @description    : This method is used to return the form
    * @param          : recordId - Id of the record
    *                   objectName - Name of the object
    *                   fieldSetName - Name of the field set
    * @return         : FieldSetForm object containing the form fields
    *********************************************************/
    
    @AuraEnabled
    public static FieldSetForm getForm(Id recordId, String objectName, String fieldSetName) {
        // Create a new FieldSetForm object
        FieldSetForm form = new FieldSetForm();        

        // Get the form fields and assign them to the FieldSetForm object
        form.Fields = getFields(recordId, objectName, fieldSetName);
        
        // Return the FieldSetForm object
        return form;
    }
    
    // Private helper method to retrieve the field set fields
    private static List<FormField> getFields(Id recordId, String objectName, String fieldSetName) {
        Schema.SObjectType objectType = null;
        
        // Determine the object type based on the recordId
        if (recordId != null) {
            objectType = recordId.getSobjectType();
        }
        // If recordId is not provided, try to get the object type using objectName
        else if (String.isNotBlank(objectName)) {
            objectType = Schema.getGlobalDescribe().get(objectName);
        }
        
        // Get the describe information for the object
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        
        // Get the field set map for the object
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        
        // Get the field set based on the fieldSetName
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        
        // Get the list of field set members (individual fields in the field set)
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
        
        // Create a list to hold the FormField objects
        List<FormField> fields = new List<FormField>();
        
        // Iterate through the field set members and create FormField objects
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            // Create a new FormField object based on the field set member
            FormField f = new FormField(fsm);
            
            // Add the FormField object to the list of fields
            fields.add(f);
        }
        
        // Return the list of fields
        return fields;
    }
    
    // Inner class representing the FieldSetForm object
    public class FieldSetForm {
        // AuraEnabled property for the list of form fields
        @AuraEnabled
        public List<FormField> Fields { get; set; }
        
        // Default constructor
        public FieldSetForm() {
            // Initialize the Fields list
            Fields = new List<FormField>();
        }
    }
}