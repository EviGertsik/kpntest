

@IsTest
private class CartControllerTest {

    static Id standardPricebookId;

    @TestSetup
    static void setup() {
        Integer count = 5;
        List<Product2> product2List = new List<Product2>();
        List<PricebookEntry> entriesList = new List<PricebookEntry>();

        for (Integer i = 0; i < count; i++) {
            product2List.add(new Product2(Name = 'Test Product ' + i, ProductCode = 'TestProduct' + i));
        }

        insert product2List;

        standardPricebookId = Test.getStandardPricebookId();

        for (Integer i = 0; i < count; i++) {
            entriesList.add(new PricebookEntry(
                    Product2Id = product2List[i].Id,
                    Pricebook2Id = standardPricebookId,
                    IsActive = true,
                    UnitPrice = 100));
        }

        insert entriesList;

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Date dateToday = Date.today();

        Contract contract = new Contract(StartDate = dateToday, AccountId = acc.Id);
        insert contract;

        Order order = new Order(AccountId = acc.Id, ContractId = contract.Id, Status = 'Draft', EffectiveDate = dateToday, Pricebook2Id = standardPricebookId);
        insert order;

        List<OrderItem> orderItems = new List<OrderItem>();
        for (Integer i = 0; i < count - 1; i++) {
            orderItems.add(new OrderItem(
                    OrderId = order.Id,
                    Product2Id = product2List[i].Id,
                    Quantity = 1,
                    PricebookEntryId = entriesList[i].Id,
                    UnitPrice = 100
            ));
        }

        insert orderItems;
    }

    @IsTest
    static void getProducts() {
        for (PricebookEntry entry : CartController.getProducts()) {
            System.assert(entry.Name == 'Standard Price Book', entry.Name);
            System.assert(entry.IsActive == true, entry.IsActive);
        }
    }

    @IsTest
    static void getOrderItems() {
        for (OrderItem orderItem : CartController.getOrderItems([SELECT Id FROM Order LIMIT 1].Id)) {
            System.assert(orderItem.Quantity == 1, orderItem.Quantity);
            System.assert(orderItem.UnitPrice == 100, orderItem.UnitPrice);
            System.assert(orderItem.Product2.Name.contains('Test Product'), orderItem.Product2.Name);
        }
    }

    @IsTest
    static void addProductsToOrder() {
        Id orderId = [SELECT Id FROM Order LIMIT 1].Id;
        PricebookEntry priceBookEntry = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Map<String,Object> params = new Map<String, Object>{
                'orderId' => orderId,
                'entryId' => priceBookEntry.Id,
                'unitPrice' => priceBookEntry.UnitPrice
        };

        Test.startTest();
        {
            CartController.addProductToOrder(params);
        }
        Test.stopTest();

        OrderItem item = [SELECT TotalPrice, Quantity FROM OrderItem WHERE OrderId =: orderId AND PricebookEntryId =: priceBookEntry.Id];
        System.assert(item.Quantity == 2, item.Quantity);
        System.assert(item.TotalPrice == priceBookEntry.UnitPrice * 2, item.TotalPrice);
    }

    @IsTest
    static void addProductsToOrderNoUnitPrice() {
        Id orderId = [SELECT Id FROM Order LIMIT 1].Id;
        PricebookEntry priceBookEntry = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Map<String,Object> params = new Map<String, Object>{
                'orderId' => orderId,
                'entryId' => priceBookEntry.Id
        };

        Test.startTest();
        {
            try {
                CartController.addProductToOrder(params);
            } catch (Exception e) {
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void addProductsToOrderNoEntryId() {
        Id orderId = [SELECT Id FROM Order LIMIT 1].Id;
        PricebookEntry priceBookEntry = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Map<String,Object> params = new Map<String, Object>{
                'orderId' => orderId,
                'unitPrice' => priceBookEntry.UnitPrice
        };

        Test.startTest();
        {
            try {
                CartController.addProductToOrder(params);
            } catch (Exception e) {
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void addProductsToOrderNoOrderId() {
        PricebookEntry priceBookEntry = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Map<String,Object> params = new Map<String, Object>{
                'entryId' => priceBookEntry.Id,
                'unitPrice' => priceBookEntry.UnitPrice
        };

        Test.startTest();
        {
            try {
                CartController.addProductToOrder(params);
            } catch (Exception e) {
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void addProductsToOrderNewOrderItem() {
        Id orderId = [SELECT Id FROM Order LIMIT 1].Id;
        PricebookEntry priceBookEntry = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1 OFFSET 4];
        Map<String,Object> params = new Map<String, Object>{
                'orderId' => orderId,
                'entryId' => priceBookEntry.Id,
                'unitPrice' => priceBookEntry.UnitPrice
        };

        Test.startTest();
        {
            CartController.addProductToOrder(params);
        }
        Test.stopTest();

        OrderItem item = [SELECT TotalPrice, Quantity FROM OrderItem WHERE OrderId =: orderId AND PricebookEntryId =: priceBookEntry.Id];
        System.assert(item.Quantity == 1, item.Quantity);
        System.assert(item.TotalPrice == priceBookEntry.UnitPrice, item.TotalPrice);
    }
}