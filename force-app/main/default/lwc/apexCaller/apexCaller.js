import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Static list of all variations, we just want something easy for demoing
import getDataSimple from '@salesforce/apex/Simple.getDataSimple';
import getDataComplex from '@salesforce/apex/Complex.getDataComplex';
import getDataInjected from '@salesforce/apex/Injected.getData';

export default class ApexCaller extends LightningElement {
    @api recordId;
    @api apexClassName;

    async handleClick() {
        let message = '';

        if (this.apexClassName) {
            switch (this.apexClassName) {
                case 'Simple':
                    message = await getDataSimple();
                    break;
                case 'Complex':
                    message = await getDataComplex({ recordId: this.recordId });
                    break;
                case 'Injected':
                    message = await getDataInjected({ recordId: this.recordId });
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
