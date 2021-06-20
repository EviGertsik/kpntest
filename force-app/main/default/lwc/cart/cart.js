import {LightningElement, api} from 'lwc';
import addProductToOrder from '@salesforce/apex/CartController.addProductToOrder'
import getOrderItems from '@salesforce/apex/CartController.getOrderItems'

export default class Cart extends LightningElement {
    @api recordId
    @api orderItems
    @api isLoading = false

    async addProductToOrder(event) {
        this.isLoading = true
        let params = {
            entryId: event.detail.Id,
            orderId: this.recordId,
            unitPrice: event.detail.UnitPrice
        }

        addProductToOrder({params})
        .then(result => {
            return getOrderItems({orderId: this.recordId})
        }).then(orderResult => {
            this.orderItems = orderResult.map(r => {
                return {...r, Name: r.Product2.Name}
            })
        }).catch(error => {
            console.error('error:',error)
        }).finally(() => {
            this.isLoading = false
        })
    }

    async connectedCallback() {
        let result = await getOrderItems({orderId: this.recordId})
        this.orderItems = result.map(r => {
            return {...r, Name: r.Product2.Name}
        })
    }
}