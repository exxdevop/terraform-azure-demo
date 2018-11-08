# Jenkins Integration

## Voraussetzungen im Jenkins schaffen

### Plugins hinzufügen
  * Git
  * Terraform

### Konfiguration der Hilfsprogramme
Jenkins verwalten -> Konfiguration der Hilfsprogramme -> Terraform hinzufügen  
Name: terraform_latest  
Automatisch installieren  
Install from bintray.com  

### Zugangsdaten
Jenkins -> Zugangsdaten -> System -> Globale Zugangsdaten

-> Zugangsdaten hinzufügen -> Art: Secret file  
Gültigkeitsbereich: Global  
File: provider.tf hochladen  
Beschreibung: z.B. AWS Account xyz provider.tf  

-> Zugangsdaten hinzufügen -> Art: Benutzername und Passwort  
Gültigkeitsbereich: Global  
Benutzername und Passwort eingeben  
Beschreibung: z.B. Github EXXDEVOP  

## Pipeline anlegen
New Item -> Name -> Pipeline  
Definition: Pipeline script from SCM  
SCM: Git  
Repository URL: http://...  
Credentials: z.B. Github EXXDEVOP  
Script Path: z.B. 05_jenkins-demo/Jenkinsfile  

### Falls direktes Pipeline Script statt GitSCM verwendet wird
```
        stage('Checkout SCM'){
            agent {label 'master'}
            steps{
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/exxdevop/terraform-azure-demo.git']]])
            }
        }
```