/**
 * @description       : 
 * @author            : Etienne Knoerr
 * @group             : 
 * @last modified on  : 2021-04-21
 * @last modified by  : Etienne Knoerr
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   2021-04-21   Etienne Knoerr   Initial Version
**/
@IsTest
public class TestDataFactory {
	/**
	 * CREATE AN ACCOUNT
	 */
	public static Account createAccount(String name) {
		Account account = new Account(Name = name);
		insert account;
		return account;
	}

   /**
	 * CREATE A CONTACT FOR AN ACCOUNT
	 */
	public static Contact createContactForAccount(Account account, String lastName, String firstName) {
		Contact contact = new Contact(LastName = lastName, FirstName = firstName, AccountId = account.id);
		insert contact;
		return contact;
	}

	/**
	 * CREATE A CONTACT
	 */
	public static Contact createContact(String lastName, String firstName) {
		Contact contact = new Contact(LastName = lastName, FirstName = firstName);
		insert contact;
		return contact;
	}
    /**
	 * CREATE A CONTACT FOR AN ACCOUNT
	 */
	public static List<Contract> createContractsForAccount(Account account, Integer count) {
        List<Contract> contracts = new List<Contract>();
        for (Integer i = 0; i < count; i++) {
            contracts.add(new Contract(StartDate = Date.today(), ContractTerm = 5 + i, AccountId = account.id, Status = 'Draft'));
        }
		insert contracts;
		return contracts;
	}

    /**
	 * CREATE PRODUCTS
	 */
	public static List<Product2> createProducts(Integer count) {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < count; i++) {
            products.add(new Product2(Name = 'Prod_' + i, ProductCode = 'P' + i));
        }
		insert products;
		return products;
	}

	/**
	 * CREATE ORDER FOR AN ACCOUNT
	 */
	public static Order createOrderForAccount(Account account, Integer nbProduct) {
		// CREATE ACTIVE CONTRACT AND ORDER FOR ACCOUNT
		Contract contract = new Contract(AccountId = account.id, Status = 'Draft', ContractTerm = 5);
		insert contract;
		contract.Status = 'Activated';
		update contract;
		Order order = new Order(
			AccountId = account.id,
			ContractId = contract.id,
			Status = 'Draft',
			EffectiveDate = Date.today(),
			Pricebook2Id = Test.getStandardPricebookId()
		);
		insert order;

		if (nbProduct > 0) {
			// CREATE PRODUCTS
			List<Product2> products = new List<Product2>();
			for (Integer i = 0; i < nbProduct; i++) {
				products.add(new Product2(Name = 'prod-' + i, Family = 'ProdFamily'));
			}
			insert products;
			// CREATE PRICE BOOK ENTRIES
			List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
			for (Product2 prod : products) {
				priceBookEntries.add(
					new PricebookEntry(
						Pricebook2Id = Test.getStandardPricebookId(),
						Product2Id = prod.Id,
						UnitPrice = 5,
						IsActive = true
					)
				);
			}
			insert priceBookEntries;
			// CREATE ORDER ITEMS FOR EACH ORDER
			List<OrderItem> orderItems = new List<OrderItem>();
			for (PricebookEntry pbe : priceBookEntries) {
				orderItems.add(
					new OrderItem(OrderId = order.Id, PricebookEntryId = pbe.Id, Quantity = 5, UnitPrice = 5)
				);
			}
			insert orderItems;
		}
		return order;
	}

	/**
	 * CREATE ORDERS FOR AN ACCOUNT LIST
	 */
	public static List<Order> createOrdersForAccounts(List<Account> accounts, Integer nbOrder, Integer nbProduct) {
		// CREATE CONTRACTS AND ORDERS FOR EACH ACCOUNT
		List<Contract> contracts = new List<Contract>();
		List<Order> orders = new List<Order>();
		for (Account account : accounts) {
			Contract contract = new Contract(AccountId = account.id, Status = 'Draft', ContractTerm = 5);
			contracts.add(contract);

			for (Integer k = 0; k < nbOrder; k++) {
				Order order = new Order(
					AccountId = account.id,
					ContractId = contract.id,
					Status = 'Draft',
					EffectiveDate = Date.today(),
					Pricebook2Id = Test.getStandardPricebookId()
				);
				orders.add(order);
			}
		}
		insert contracts;
		insert orders;

		// CREATE PRODUCTS
		List<Product2> products = new List<Product2>();
		for (Integer i = 0; i < nbProduct; i++) {
			products.add(new Product2(Name = 'prod-' + i, Family = 'ProdFamily'));
		}
		insert products;
		// CREATE PRICE BOOK ENTRIES
		List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
		for (Product2 prod : products) {
			priceBookEntries.add(
				new PricebookEntry(
					Pricebook2Id = Test.getStandardPricebookId(),
					Product2Id = prod.Id,
					UnitPrice = 5,
					IsActive = true
				)
			);
		}
		insert priceBookEntries;
		// CREATE ORDER ITEMS FOR EACH ORDER
		List<OrderItem> orderItems = new List<OrderItem>();
		OrderItem item;
		for (Order order : orders) {
			for (PricebookEntry pbe : priceBookEntries) {
				orderItems.add(
					new OrderItem(OrderId = order.Id, PricebookEntryId = pbe.Id, Quantity = 5, UnitPrice = 5)
				);
			}
		}
		insert orderItems;
		//
		return orders;
	}
	/**
	 * CREATE REMINDER TASK FOR ACCOUNT
	 */
	public static Task createReminderTaskForAccount(Account account) {
		Task task = new Task(
			WhatId = account.Id,
			OwnerId = account.OwnerId,
			Subject = 'Call',
			Status = 'Not Started',
			Priority = 'Normal',
			IsReminderSet = true,
			ReminderDateTime = Date.today().addDays(5)
		);
		insert task;
		return task;
	}
}
