# Legarant Rest Api

Rest Api coded with Apex for Salesforce Contacts, Accounts, Contracts and Product2s
V 1.0.0-1

## package installation :

`https://login.salesforce.com/packaging/installPackage.apexp?p0=04t09000000ZoXMAA0`

## Rappels pour la création de package

### Création de l'org de test

`sfdx force:org:create --definitionfile config/project-scratch-def.json --durationdays 30 --setalias scratch -v legarant`

### Création du package

`sfdx force:package:create --name legarantrestapi --description "Legarant Rest API" --packagetype Unlocked --path force-app --nonamespace --targetdevhubusername legarant`

### Création de la version de Package

`sfdx force:package:version:create -p legarantrestapi -d force-app -k test1234 --wait 10 --codecoverage -v legarant`

### installer le package dans l'org de test

`sfdx force:package:install --wait 10 --publishwait 10 --package legarantrestapi@0.1.0-1 -k test1234 -r -u scratch`

### Publication de la version de package

`sfdx force:package:version:promote -p legarantrestapi@0.1.0-1 -v legarant`
