/**
 * @description       :
 * @author            : Etienne Knoerr
 * @group             :
 * @last modified on  : 2021-04-22
 * @last modified by  : Etienne Knoerr
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2021-04-15   Etienne Knoerr   Initial Version
 **/
@isTest
private class ContactRestTest {
	@isTest
	static void testGetContact() {
		Contact contact = TestDataFactory.createContact('aaa', 'bbb', 'aaa@bbb.com');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri =
			'https://https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Contacts/' + contact.id;
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.getContactById();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains(contact.FirstName), 'Bad Name');
		System.assert(testBlob.contains(contact.Id), 'Bad Id');
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testGetContactWithoutId() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = 'https://https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Contacts/';
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.getContactById();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('Id is not a valid Id'), 'Bad response');
		System.assert(testBlob.contains('MISSING_PARAM'), 'Bad response');
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testGetContactWithBadId() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = 'https://https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Contacts/0031x000016W3oqAAD';
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.getContactById();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('Contact not found'), 'Bad response');
		System.assert(testBlob.contains('NOT_FOUND'), 'Bad response');
		System.assertEquals(404, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testDeleteContact() {
		Contact contact = TestDataFactory.createContact('aaa', 'bbb', 'aaa@bbb.com');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri =
			'https://https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Contacts/' + contact.id;
		request.httpMethod = 'DELETE';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.deleteContact();
		Test.stopTest();
		// Verify results
		List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = :contact.Id AND Active__c = TRUE];
		System.assertEquals(0, contacts.size(), 'Contact should be deleted');
		System.assertEquals(204, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testDeleteContactWithBadId() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = 'https://https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Contacts/0031x000016W3oqAAD';
		request.httpMethod = 'DELETE';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.deleteContact();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('Contact not found'), 'Bad response');
		System.assert(testBlob.contains('NOT_FOUND'), 'Bad response');
		System.assertEquals(404, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testDeleteContactWithoutId() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = 'https://https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Contacts/';
		request.httpMethod = 'DELETE';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.deleteContact();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('Id is not a valid Id'), 'Bad response');
		System.assert(testBlob.contains('MISSING_PARAM'), 'Bad response');
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testCreateContact() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = 'https://https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"LastName": "aaa", "Firstname": "bbb", "Email": "aaa@bbb.com"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.createContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('aaa@bbb.com'), 'Bad response');
	}

	@isTest
	static void testCreateContactWithBadParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = 'https://https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"Lastame": "aaa", "Firstname": "bbb", "Email": "aaa@bbb.com"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.createContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAM'), 'Bad response');
	}

	@isTest
	static void testCreateContactWithBadEmail() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = 'https://https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"LastName": "aaa", "Firstname": "bbb", "Email": "bbb.com"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.createContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad status code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAM'), 'Bad response code');
		System.assert(testBlob.contains('Email: invalid email address'), 'Bad message');
	}

	@isTest
	static void testCreateContactWithMissingParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = 'https://https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"LastName": "aaa", "FirstName": "bbb"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.createContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad status code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAMS'), 'Bad response code');
		System.assert(testBlob.contains('Required fields are missing'), 'Bad response message');
	}

	@isTest
	static void testCreateContactDuplicate() {
		Contact contact = TestDataFactory.createContact('aaa', 'bbb', 'aaa@bbb.com');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = 'https://https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"LastName": "bbb", "Firstname": "ccc", "Email": "aaa@bbb.com"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.createContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains(contact.Id), 'Should contain Id');
	}

	/*
    @isTest static void testUpsertContact() {
        // 1. Insert new record
        ID contact1Id = ContactRest.upsertContact(
                'Ferocious chipmunk', 'New', 'Phone', 'Low', null);
        // Verify new record was created
        System.assert(Contact1Id != null);
        Contact contact1 = [SELECT Id,Subject FROM Contact WHERE Id=:contact1Id];
        System.assert(contact1 != null);
        System.assertEquals(contact1.Subject, 'Ferocious chipmunk');
        // 2. Update status of existing record to Working
        ID contact2Id = ContactRest.upsertContact(
                'Ferocious chipmunk', 'Working', 'Phone', 'Low', contact1Id);
        // Verify record was updated
        System.assertEquals(contact1Id, contact2Id);
        Contact contact2 = [SELECT Id,Status FROM Contact WHERE Id=:contact2Id];
        System.assert(contact2 != null);
        System.assertEquals(contact2.Status, 'Working');
    }    
    @isTest static void testUpdateContactFields() {
        Id recordId = createTestRecord();
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://yourInstance.salesforce.com/services/apexrest/Contacts/'
            + recordId;
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"status": "Working"}');
        RestContext.request = request;
        // Update status of existing record to Working
        ID thisContactId = ContactRest.updateContactFields();
        // Verify record was updated
        System.assert(thisContactId != null);
        Contact thisContact = [SELECT Id,Status FROM Contact WHERE Id=:thisContactId];
        System.assert(thisContact != null);
        System.assertEquals(thisContact.Status, 'Working');
    }  
    // Helper method
    static Id createTestRecord() {
        // Create test record
        Contact contactTest = new Contact(
            Subject='Test record',
            Status='New',
            Origin='Phone',
            Priority='Medium');
        insert contactTest;
        return contactTest.Id;
    }          
}
*/
}
