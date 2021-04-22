/**
 * @description       : Contacts REST Interface
 * @author            : Etienne Knoerr
 * @group             :
 * @last modified on  : 2021-04-22
 * @last modified by  : Etienne Knoerr
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2021-04-01   Etienne Knoerr   Initial Version
 **/

/*
Questions : 
  - si on ne supprime pas, en mettant Active__c à false : autorise-t-on la récupération / modification de contacts inactifs ?
  - PATCH : passer l'ID en paramètre JSON ou dans l'URL ?
*/
@RestResource(urlMapping='/Contacts/*')
global with sharing class ContactRest extends RestManager {
	/**
	 * @description GET
	 **/
	@HttpGet
	global static void getContact() {
		RestContext.response.headers.put('Content-Type', 'application/json');
		try {
			String contactId = RestContext.request.requestURI.substring(
				RestContext.request.requestURI.lastIndexOf('/') + 1
			);
			if (!isValidSalesforceId(contactId, Contact.class)) {
				throw new System.StringException();
			}
			// collect Contact field list
			Map<String, Schema.SObjectField> fieldMap = Contact.sObjectType.getDescribe().fields.getMap();
			List<String> fieldNames = new List<String>(fieldMap.keySet());
			Contact thisContact = Database.query(
				'SELECT ' +
				String.join(fieldNames, ',') +
				' FROM Contact  WHERE Id = \'' +
				contactId +
				'\''
			);
			//Contact thisContact = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Id = :contactId] ;
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisContact));
		} catch (Exception e) {
			handleRestException(e, 'Contact');
		}
	}

	/**
	 * @description handleSingle > One Contact
	 * @param String contactId
	 **/
	private static void handleSingle(Id contactId) {
		// collect Contact field list
		Map<String, Schema.SObjectField> fieldMap = Contact.sObjectType.getDescribe().fields.getMap();
		List<String> fieldNames = new List<String>(fieldMap.keySet());
		Contact thisContact = Database.query(
			'SELECT ' +
			String.join(fieldNames, ',') +
			' FROM Contact  WHERE Id = \'' +
			contactId +
			'\''
		);
		//Contact thisContact = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Id = :contactId] ;
		RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisContact));
	}

	/**
	 * @description handleCollection > Contact List
	 **/
	private static void handleCollection() {
		// collect Contact field list
		Map<String, Schema.SObjectField> fieldMap = Contact.sObjectType.getDescribe().fields.getMap();
		List<String> fieldNames = new List<String>(fieldMap.keySet());
		List<Contact> thisContacts = Database.query(
			'SELECT ' +
			String.join(fieldNames, ',') +
			' FROM Contact LIMIT 20'
		);
		RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisContacts));
	}

	/**
	 * @description DELETE
	 **/
	@HttpDelete
	global static void deleteContact() {
		RestContext.response.headers.put('Content-Type', 'application/json');
		try {
			// grab the contactId from the end of the URL
			Id contactId = RestContext.request.requestURI.substring(
				RestContext.request.requestURI.lastIndexOf('/') + 1
			);
			Contact thisContact = [SELECT Id, Active__c FROM Contact WHERE Id = :contactId];
			thisContact.Active__c = false;
			DataBase.SaveResult result = Database.update(thisContact);
			RestContext.response.statusCode = 204;
		} catch (Exception e) {
			handleRestException(e, 'Contact');
		}
	}

	/**
	 * @description POST
	 **/
	@HttpPost
	global static void createContact() {
		RestContext.response.headers.put('Content-Type', 'application/json');
		try {
			Contact thisContact = applyParameters(new Contact());
			// test for duplicate
			Boolean duplicate;
			try {
				Contact testContactDuplicate = [SELECT Id FROM Contact WHERE Email = :thisContact.Email];
				thisContact.put('Id', testContactDuplicate.Id);
				duplicate = true;
			} catch (System.QueryException e) {
				duplicate = false;
			}
			GenericResult result;
			if (!duplicate) {
				// allOrNone param set to false in order to get error type
				result = new GenericResult(Database.insert(thisContact, false));
			} else {
				result = new GenericResult(Database.update(thisContact, false));
			}
			// manage error
			if (result.getErrors().size() != 0) {
				if (result.getErrors()[0] instanceof Database.DuplicateError) {
					throw new DuplicateException();
				} else {
					throw new ParamException(result.getErrors()[0].message);
				}
			}
			// Send response
			RestContext.response.statusCode = 200;
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisContact));
		} catch (Exception e) {
			handleRestException(e, 'Contact');
		}
	}

	/**
	 * @description PUT
	 **/
	@HttpPut
	global static void upsertContact() {
		RestContext.response.headers.put('Content-Type', 'application/json');
		try {
			Contact thisContact = applyParameters(new Contact());
			// test for duplicate
			Boolean duplicate;
			try {
				Contact testContactDuplicate = [SELECT Id FROM Contact WHERE Email = :thisContact.Email];
				thisContact.put('Id', testContactDuplicate.Id);
				duplicate = true;
			} catch (System.QueryException e) {
				duplicate = false;
			}

			GenericResult result;
			if (!duplicate) {
				// allOrNone param set to false in order to get error type
				result = new GenericResult(Database.upsert(thisContact, false));
			} else {
				result = new GenericResult(Database.update(thisContact, false));
			}
			// manage error
			if (result.getErrors().size() != 0) {
				if (result.getErrors()[0] instanceof Database.DuplicateError) {
					throw new DuplicateException();
				} else {
					throw new ParamException(result.getErrors()[0].message);
				}
			}
			// Send response
			RestContext.response.statusCode = 200;
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisContact));
		} catch (Exception e) {
			handleRestException(e, 'Contact');
		}
	}

	/**
	 * @description PATCH
	 **/
	@HttpPatch
	global static void updateContactFields() {
		RestContext.response.headers.put('Content-Type', 'application/json');
		try {
			Id contactId = RestContext.request.requestURI.substring(
				RestContext.request.requestURI.lastIndexOf('/') + 1
			);
			Contact thisContact = [SELECT Id, ExtId__c FROM Contact WHERE Id = :contactId];
			thisContact = applyParameters(thisContact);
			GenericResult result = new GenericResult(Database.update(thisContact, false));
			// manage error
			if (result.getErrors().size() != 0) {
				if (result.getErrors()[0] instanceof Database.DuplicateError) {
					throw new DuplicateException();
				} else {
					throw new ParamException(result.getErrors()[0].message);
				}
			}
			// Send response
			RestContext.response.statusCode = 200;
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisContact));
		} catch (Exception e) {
			handleRestException(e, 'Contact');
		}
	}

	/**
	 * @description apply pRequest parameters to Contact
	 * @param Contact thisContact
	 * @return Contact
	 **/
	public static Contact applyParameters(Contact thisContact) {
		// Deserialize the JSON string into name-value pairs
		Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
			RestContext.request.requestbody.tostring()
		);
		// Iterate through each parameter field and value
		for (String fieldName : params.keySet()) {
			// Set the field and value on the Contact sObject
			thisContact.put(fieldName, params.get(fieldName));
		}
		return thisContact;
	}

	public static Contact getContactById(Id contactId) {
		// collect Contact field list
		Map<String, Schema.SObjectField> fieldMap = Contact.sObjectType.getDescribe().fields.getMap();
		List<String> fieldNames = new List<String>(fieldMap.keySet());
		return Database.query(
			'SELECT ' +
			String.join(fieldNames, ',') +
			' FROM Contact  WHERE Id = \'' +
			contactId +
			'\''
		);
	}
}
