import {LightningElement, api} from 'lwc';
import getProducts from '@salesforce/apex/CartController.getProducts'

const columns = [
    { label: 'Product Name', fieldName: 'Name' },
    { type: "button", typeAttributes: {
            label: "Add to Cart",
            title: "Add to Cart",
            name: "addToCart",
            value: "addToCart"
        }
    }

];

export default class CartProducts extends LightningElement {
    entries = []
    error = ''
    columns = columns
    @api selectedProduct

    async connectedCallback() {
        const [data, error] = await this.handleAsync(getProducts)
        if (data) {
            this.entries = data
        }
        if (error) {
            this.entries = undefined
        }
    }

    async handleAsync(promise) {
        try {
            const data = await promise({})
            return [data, null]
        } catch (error) {
            console.error(error)
            return [null, error]
        }
    }

    addProduct(event) {
        this.selectedProduct = event.detail.row
        const selected = new CustomEvent('add', {detail: this.selectedProduct})
        this.dispatchEvent(selected)
    }

}