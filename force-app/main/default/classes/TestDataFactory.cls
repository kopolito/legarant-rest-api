/**
 * @description       :
 * @author            : Etienne Knoerr
 * @group             :
 * @last modified on  : 2021-04-23
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
	 * CREATE A CONTACT
	 */
	public static Contact createContact(String lastName, String firstName, String email) {
		Contact contact = new Contact(LastName = lastName, FirstName = firstName, Email = email);
		insert contact;
		return contact;
	}

	/**
	 * CREATE CONTRACTS FOR AN ACCOUNT
	 */
	public static Contract createContractForAccount(Account account) {
		Contract contract = new Contract(
			StartDate = Date.today(),
			ContractTerm = 5,
			AccountId = account.id,
			Status = 'Draft'
		);
		insert contract;
		return contract;
	}

	/**
	 * CREATE PRODUCT
	 */
	public static Product2 createProduct(String prodName) {
		Product2 product = new Product2(Name = prodName, ProductCode = 'PP_' + prodName);
		insert product;
		return product;
	}
}
