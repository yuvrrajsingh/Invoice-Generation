import { LightningElement,api,wire,track } from 'lwc';
import getForm from '@salesforce/apex/FieldSetController.getForm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class DynamicPageGenerator extends NavigationMixin(LightningElement) {
    @api objectName;
    @api recordId;
    @api fieldSet;
    @track fields;
    @api pagename;
    @api previous;

    connectedCallback()
    {
        getForm({ recordId: this.recordId,objectName:this.objectName, fieldSetName:this.fieldSet})
        .then(result => {
            console.log('Data:'+ JSON.stringify(result));
            if (result) {
                this.fields = result.Fields;
                this.error = undefined;
            }
        }) .catch(error => {
            console.log(error);
            this.error = error;
        }); 
    }

    saveClick(e)
    {
        const inputFields = e.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(inputFields);
    }
    validateFields() {
        return [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
            return (validSoFar && field.reportValidity());
        }, true);
    }
    handleSuccess(e)
    {
        this.showMessage('Record Saved Successfully','success');
    }
    handleError(e)
    {
        this.template.querySelector('[data-id="message"]').setError(e.detail.detail);
        e.preventDefault();
    }

    showMessage(message,variant)
    {
        const event = new ShowToastEvent({
            title: 'Record Save',
            variant: variant,
            mode: 'dismissable',
            message: message
        });
        this.dispatchEvent(event);
    }

    // handle save and click
    handleSaveAndNext(e)
    {
        try {
            const inputFields = e.detail.fields;
            this.template.querySelector('lightning-record-edit-form').submit(inputFields);

            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: this.pagename
                }
            });
        } catch (error) {
            console.log('=====Error in handleSaveAndNext fucn======', error);
        }
        
    }

    // handle previous click
    handlePrevious(e)
    {
        try {
            const inputFields = e.detail.fields;
            this.template.querySelector('lightning-record-edit-form').submit(inputFields);

            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: this.previous
                }
            });
        } catch (error) {
            console.log('=====Error in handleSaveAndNext fucn======', error);
        }
        
    }
}