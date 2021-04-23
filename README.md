# idem-apex-backend

Prototype de backend Apex
V 1.1.4

## package installation :

`https://login.salesforce.com/packaging/installPackage.apexp?p0=04t09000000ZoXMAA0`

## Rappels pour la création de package

### Création de l'org de test

`sfdx force:org:create --definitionfile config/project-scratch-def.json --durationdays 30 --setalias scratch -v legarant`

### Création du package

`sfdx force:package:create --name restapi --description "Rest API" --packagetype Unlocked --path force-app --nonamespace --targetdevhubusername legarantdev`

### Création de la version de Package

`sfdx force:package:version:create -p restapi -d force-app -k test1234 --wait 10 --codecoverage -v legarant`

### installer le package dans l'org de test

`sfdx force:package:install --wait 10 --publishwait 10 --package restapi@1.1.4-1 -k test1234 -r -u scratch`

### Publication de la version de package

`sfdx force:package:version:promote -p restapi@1.1.4-1 -v legarant`
