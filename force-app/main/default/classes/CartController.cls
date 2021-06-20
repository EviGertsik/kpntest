

public with sharing class CartController {

    @AuraEnabled(Cacheable=true)
    public static List<PricebookEntry> getProducts() {
        return [SELECT Id, Name, UnitPrice
                FROM PricebookEntry
                WHERE Pricebook2.Name = 'Standard Price Book'
                    AND IsActive = TRUE];
    }

    @AuraEnabled
    public static List<OrderItem> getOrderItems(Id orderId) {
        return [SELECT Id, Product2.Name, UnitPrice, TotalPrice, Quantity FROM OrderItem WHERE OrderId =: orderId];
    }

    @AuraEnabled
    public static void addProductToOrder(Map<String,Object> params) {
        if (!params.containsKey('orderId') || params.get('orderId') == null) {
            throw new AuraHandledException('No order Id specified!');
        }
        if (!params.containsKey('entryId') || params.get('entryId') == null) {
            throw new AuraHandledException('No entry Id specified!');
        }
        if (!params.containsKey('unitPrice') || params.get('unitPrice') == null) {
            throw new AuraHandledException('No unit price specified!');
        }
        String orderId = (String) params.get('orderId');
        String entryId = (String) params.get('entryId');
        Decimal unitPrice = (Decimal) params.get('unitPrice');
        List<OrderItem> items = [SELECT Id, Quantity, UnitPrice FROM OrderItem WHERE PricebookEntryId =: entryId AND OrderId =: orderId];
        if (items.isEmpty()) {
            insert new OrderItem(PricebookEntryId = entryId, OrderId = orderId, Quantity = 1, UnitPrice = unitPrice);
        } else {
            OrderItem item = items[0];
            item.Quantity++;
            update item;
        }
    }

}