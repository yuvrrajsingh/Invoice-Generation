import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { loadScript } from 'lightning/platformResourceLoader';
import cropCss from '@salesforce/resourceUrl/croppieCss';
import cropJS from '@salesforce/resourceUrl/croppieJs';

export default class Croppie extends LightningElement {
    croppieLoaded = false;
    fileSizeInMb;
    displayfileName;
    showImage;
    fileDetailReader;

    renderedCallback() {
        Promise.all([
            loadStyle(this, cropCss),
            loadScript(this, cropJS)
        ]).then(() => {
            console.log('JS and CSS files loaded.');
            this.croppieLoaded = true;
        }).catch(error => {
            console.log('Error occurred');
        });
        
    }

    handleFileChange(event) {
        //console.log('HTML >>>> ',this.template.querySelector('[data-id="custom"]').innerHTML);
        //this.template.querySelector('[data-id="custom"]').innerHTML='';
        //this.fileDetailReader = new window.Croppie.destroy();
        this.showImage = true;
        console.log('File uploded',event.target.files[0]);
        const file = event.target.files[0];
        const reader = new FileReader();


        reader.onload = (e) => {
            console.log('on load');
            this.fileDetailReader = new window.Croppie(this.template.querySelector('[data-id="custom"]'), {
                viewport: {
                    width: 199,
                    height: 199,
                    type: 'circle'
                },
                boundary: {
                    width: 200,
                    height: 200
                },
                showZoomer: true,
                enableResize: true,
                enableOrientation: true
            });
            
            this.fileDetailReader.bind({
                url: reader.result,
                orientation: 1
            });
            this.fileName = file.name;
            console.log('HTML 2 >>>> ',this.template.querySelector('[data-id="custom"]').innerHTML);
        }
        reader.readAsDataURL(file)
        this.fileSizeInMb = file.size;
        this.displayfileName = file.name;
        
    }
    
    handleRight(){
        this.fileDetailReader.rotate(-90);
    }

    handleLeft(){
        this.fileDetailReader.rotate(90);
        //this.showImage = false;
    }

    handleShowImage(){
        this.showImage = this.showImage == true ? false : true;
    }

    
    

}