import {LightningElement, api, wire} from 'lwc';
import getRecords from '@salesforce/apex/ImplementSharingFieldSet.getRecordList';
import getFieldLableAndFieldAPI from '@salesforce/apex/AlainClaudeDynamicLwcApex.getFieldLabelAndFieldAPI';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
export default class AlainClaudeDynamicLwc extends LightningElement {


    checkFieldSet= false;
    columns =[];
    data = [];
    dataIsPresent = false;
    @api recordId;
    @api ParentObject;
    @api ChildObjectName;
    @api fieldSetName;
    recordCount =0;
    draftValues;
    refreshTable;
    reactiveProperty;
   

//ParentObject,String recordId,String objectName,String fieldSetName
    @wire(getRecords, { ParentObject: '$ParentObject',recordId:'$recordId',ChildObjectName:'$ChildObjectName',fieldSetName: '$fieldSetName'})
    RecordData(refreshTable){
        this.refreshTable = refreshTable;
        this.data = null;
        const {
            data,
            error
        } = refreshTable; 
        if(data){
            this.data = data;
            this.recordCount = data.length; 
            console.log(' data dynamo====> ', JSON.stringify(data));
            this.dataIsPresent = true;
        }
        else if(error){
            console.log('error====> ', JSON.stringify(error));
        
        }
    }

    connectedCallback() {
        getFieldLableAndFieldAPI({
            recordId: this.recordId,
            ChildObjectName: this.ChildObjectName,
            fieldSetName: this.fieldSetName
        })
        .then((data) => {
            let fieldSet = JSON.parse(data);
            console.log('fieldSet====> ', JSON.stringify(fieldSet));
    
            // Map the field set to the columns array
            this.columns = fieldSet.map(field => ({
                label: Object.keys(field)[0],
                fieldName: Object.values(field)[0],
                editable: true 
            }));
    
            this.checkFieldSet = true;
    
            // Ensure that data is present before trying to map it
            if (this.dataIsPresent) {
                this.data = this.data.map(record => {
                    let mappedRecord = {};
                    this.columns.forEach(column => {
                        mappedRecord[column.fieldName] = record[column.fieldName];
                    });
                    return mappedRecord;
                });
            }
        })
        .catch((error) => {
            console.error('Error fetching field set:', error);
        });
    }


    handleSave(event) {
        this.draftValues = event.detail.draftValues;

        const inputsItems = this.draftValues.map((draft) => {
            const fields = { ...draft };
            return { fields };
        });

        try {
            const promises = inputsItems.map((recordInput) => updateRecord(recordInput));

            Promise.all(promises)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Records Updated Successfully!!',
                            variant: 'success'
                        })
                    );
                    this.draftValues = [];
                    console.log('Update success!');
                    console.log('Update success! this.refreshTable ==> ',JSON.stringify(this.refreshTable ));
                 
                })
                .catch((error) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'An Error Occurred!!' + error,
                            variant: 'error'
                        })
                    );
                })
                .finally(() => {
                    this.draftValues = [];
                });
        } catch (error) {
            console.log('--- error--', error);
        }
    }
}