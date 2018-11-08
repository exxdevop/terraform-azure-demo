/*
Author: Marcel.Emmert@EXXETA.com
*/
pipeline {
    agent none
    options { 
        skipDefaultCheckout()
        disableConcurrentBuilds()
    }
    stages{
        stage('Checkout SCM'){
            agent {label 'master'}
            steps{
                checkout scm
            }
        }
        stage('Terraform copy provider.tf and init'){
            agent {label 'master'}
/*
            https://issues.jenkins-ci.org/browse/JENKINS-50718
            tools {
                'org.jenkinsci.plugins.terraform.TerraformInstallation' 'terraform_latest'
            }
*/
            environment {
                terraform_path = tool name: 'terraform_latest', type: 'org.jenkinsci.plugins.terraform.TerraformInstallation'
            }
            steps{
                withCredentials([file(credentialsId: '066b4039-f623-4b16-a8df-8ac94237d127', variable: 'FILE')]) {
                    sh '''
                    chmod u+w $FILE
                    cp $FILE 05_jenkins-demo/
                    cd 05_jenkins-demo/
                    ${terraform_path}/terraform -v
                    ${terraform_path}/terraform init -input=false
                    '''
                }
            }
        }
        stage('Terraform plan'){
            agent {label 'master'}
            environment {
                terraform_path = tool name: 'terraform_latest', type: 'org.jenkinsci.plugins.terraform.TerraformInstallation'
            }
            steps{
                sh '''
                cd 05_jenkins-demo/
                ${terraform_path}/terraform plan -input=false -out=tfplan
                '''
            }
        }
        stage('Terraform apply'){
            agent {label 'master'}
            environment {
                terraform_path = tool name: 'terraform_latest', type: 'org.jenkinsci.plugins.terraform.TerraformInstallation'
            }
            options {
                timeout(time: 1, unit: 'HOURS')
            }
            steps{
                sh '''
                cd 05_jenkins-demo/
                ${terraform_path}/terraform apply -input=false -auto-approve "tfplan"
                rm tfplan
                '''
            }
        }
        stage('Checkin SCM'){
            agent {label 'master'}
/*
            Git publisher is not yet supported with pipeline: https://issues.jenkins-ci.org/browse/JENKINS-28335
            Workaround: https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/push-git-repo/pushGitRepo.groovy
*/            
            steps{
                lock('Checkin SCM') {
                    withCredentials([usernamePassword(credentialsId: 'c3c23094-4f66-4eff-b6c5-78500f4d8d27', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        sh '''
                        git config --global user.email "jenkins@exxeta.com"
                        git config --global user.name "Jenkins CI"
                        git add .
                        #
                        # "nothing to commit" means exit code 1, so say "|| true" (means exit code 0)
                        # https://support.cloudbees.com/hc/en-us/articles/218517228-How-to-Ignore-Failures-in-a-Shell-Step-
                        #
                        git commit -m "$JOB_NAME with build $BUILD_NUMBER" || true
                        git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/exxdevop/terraform-azure-demo.git HEAD:master
                        '''
                    }
                }
            }
        }
        stage('Clean workspace'){
            agent {label 'master'}
            steps{
                cleanWs()
            }
        }
    }
}