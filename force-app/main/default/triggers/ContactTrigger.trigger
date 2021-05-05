/**
 * @description       :
 * @author            : Etienne Knoerr
 * @group             :
 * @last modified on  : 2021-04-22
 * @last modified by  : Etienne Knoerr
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2021-04-22   Etienne Knoerr   Initial Version
 **/
trigger ContactTrigger on Contact(before insert) {
	for (Contact contact : Trigger.new) {
		if (contact.email != null) {
			contact.put('ExtId__c', contact.email);
		} else {
			contact.addError('Required fields are missing: [Email]');
		}
	}
}
