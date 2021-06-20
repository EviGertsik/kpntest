import {LightningElement, api, wire} from 'lwc';
import getOrderProducts from '@salesforce/apex/CartController.getOrderItems'

const columns = [
    { label: 'Product Name', fieldName: 'Name' },
    { label: 'Unit Price', fieldName: 'UnitPrice'},
    { label: 'Quantity', fieldName: 'Quantity'},
    { label: 'Total Price', fieldName: 'TotalPrice'}
];

export default class CartOrder extends LightningElement {
    columns = columns
    @api isLoading = false
    @api orderProducts
    @api recordId

    async connectedCallback() {

    }


}