import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Static list of all variations, we just want something easy for demoing
import getDataFromSomeClass from '@salesforce/apex/SomeClass.getData';
import getDataFromSomeOtherClass from '@salesforce/apex/SomeOtherClass.getData';

export default class ApexCaller extends LightningElement {
    @api apexClassName;

    async handleClick() {
        let message = '';

        if (this.apexClassName) {
            switch (this.apexClassName) {
                case 'SomeClass':
                    message = await getDataFromSomeClass();
                    break;
                case 'SomeOtherClass':
                    message = await getDataFromSomeOtherClass();
                    break;
                default:
                    // Nothing
                    break;
            }
        }

        this.dispatchEvent(
            new ShowToastEvent({
                message: message,
                variant: 'success'
            })
        );
    }
}
