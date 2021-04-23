/**
 * @description       :
 * @author            : Etienne Knoerr
 * @group             :
 * @last modified on  : 2021-04-23
 * @last modified by  : Etienne Knoerr
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2021-04-23   Etienne Knoerr   Initial Version
 **/
@isTest
private class RestManagerTest {
	public class CustomException extends Exception {
	}

	@isTest
	static void testHandleRestException() {
		Contact contact = TestDataFactory.createContact('aaa', 'bbb', 'aaa@bbb.com');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		// request.requestUri =
		// 	'https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Contacts/' + contact.id;
		// request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;

		// Call the method to test
		Test.startTest();
		RestManager.handleRestException((Exception) new CustomException('bad_data'), 'Model');
		Test.stopTest();
		// Verify results
		System.assertEquals(500, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('bad_data'), 'Bad Content');
	}

	@isTest
	static void testIsValidSalesforceId() {
		// Call the method to test
		Test.startTest();
		Boolean result = RestManager.isValidSalesforceId(null, Contact.class);
		Test.stopTest();
		// Verify results
		System.assertEquals(false, result, 'Mus be false');
	}
}
