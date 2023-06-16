import { LightningElement } from 'lwc';
import Tesseract from '@salesforce/resourceUrl/ocrLIb';
import { loadScript } from 'lightning/platformResourceLoader';

export default class OcrTesting extends LightningElement {
    file;
    isLoading=false;
    FinalText=false;
    connectedCallback() {
        this.loadExternalLib();
    }

    async loadExternalLib() {
        await Promise.all([
            loadScript(this, Tesseract)
        ])
            .then(() => {
                const tr = window.Tesseract;
                console.log('Tesseract: ', tr);
            })
            .catch(error => {
                console.log(error);
            });
    }

    handleChange(event) {
        this.file = event.target.files[0];
        console.log('File Details: ', this.file);
    }

    async imageProcess() {
        this.isLoading = true;
        try {
            this.loadExternalLib();
            var tesseract = window.Tesseract;
            console.log('Tesseract: ', tesseract);
            const worker = new tesseract.TesseractWorker();
            console.log('Worker: ', worker);
            worker.recognize(this.file, 'eng')
                .then((result) => {
                    this.FinalText = result.text;
                    this.isLoading = false;
                    console.log('Result: ', result);
                    console.log('Result: ', result.text);
                })
                .catch(error => {
                    console.log('Error occurred in recognize: ', error);
                    this.isLoading = false;
                });
        } catch (error) {
            this.isLoading = false;
            console.log('Error in processing: ', error);
        }
    }
}
