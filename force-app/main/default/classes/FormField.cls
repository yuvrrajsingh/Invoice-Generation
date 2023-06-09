/*******************************************************************************************************************************
* @Class Name    : FormField
* @Created Date       : June 08, 2023
* @description       : This class contains properties and constructors to store and retrieve information 
                        about a form field.
* @author            : Yuvraj Singh
* @Modification Log:
*******************************************************************************************************************************/



public class FormField {
    
    // Constructor that takes a Schema.FieldSetMember object as a parameter
    public FormField(Schema.FieldSetMember f) {
        // Set the IsRequired property based on the DBRequired value of the FieldSetMember
        this.IsRequired = f.DBRequired;
        // Set the APIName property to the fieldPath of the FieldSetMember
        this.APIName = f.fieldPath;
        // Set the Label property to the label of the FieldSetMember
        this.Label = f.label;
        // Set the Required property to the required value of the FieldSetMember
        this.Required = f.required;
        // Set the Type property to the string representation of the type of the FieldSetMember
        this.Type = String.valueOf(f.getType());
    }
    
    // Constructor that takes a Boolean required parameter
    public FormField(Boolean required) {
        // Set the IsRequired property based on the provided required value
        this.IsRequired = required;
    }
    
    // AurEnabled properties
    @AuraEnabled
    public Boolean IsRequired { get;set; }    
    @AuraEnabled
    public String APIName { get;set; }    
    @AuraEnabled
    public String Label { get;set; }    
    @AuraEnabled
    public Boolean Required { get;set; } 
    @AuraEnabled
    public String Type { get; set; }
}