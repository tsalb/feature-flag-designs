import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Static list of all variations, we just want something easy for demoing
import getDataSimple from '@salesforce/apex/SomeClass.getDataSimple';
import getDataComplex from '@salesforce/apex/SomeOtherClass.getDataComplex';

export default class ApexCaller extends LightningElement {
    @api recordId;
    @api apexClassName;

    async handleClick() {
        let message = '';

        if (this.apexClassName) {
            switch (this.apexClassName) {
                case 'SomeClass':
                    message = await getDataSimple();
                    break;
                case 'SomeOtherClass':
                    message = await getDataComplex({ recordId: this.recordId });
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
