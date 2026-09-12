pipeline {

    agent any

    parameters {
        choice(
            name: 'TERRAFORM_WORKSPACE',
            choices: [
                'dev',
                'stg',
                'prod'
            ],
            description: 'Select the Terraform workspace'
        )
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                    terraform init
                '''
            }
        }

        stage('Select Workspace') {
            steps {
                sh '''
                    terraform workspace select ${TERRAFORM_WORKSPACE} || \
                    terraform workspace new ${TERRAFORM_WORKSPACE}

                    echo "Selected workspace:"
                    terraform workspace show
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                    terraform plan -out=tfplan
                '''
            }
        }

        stage('Manual Approval') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {

                    input(
                        message: "Apply Terraform changes to ${TERRAFORM_WORKSPACE}?",
                        ok: 'Proceed'
                    )
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                    terraform apply -auto-approve tfplan
                '''
            }
        }
    }

    post {

        success {
            echo """
========================================
TERRAFORM DEPLOYMENT SUCCESSFUL
========================================
Project: ${JOB_NAME}
Build Number: ${BUILD_NUMBER}
Workspace: ${TERRAFORM_WORKSPACE}
Build URL: ${BUILD_URL}
========================================
"""
        }

        failure {
            echo """
========================================
TERRAFORM DEPLOYMENT FAILED
========================================
Project: ${JOB_NAME}
Build Number: ${BUILD_NUMBER}
Workspace: ${TERRAFORM_WORKSPACE}
Build URL: ${BUILD_URL}
========================================
"""
        }

        aborted {
            echo """
========================================
PIPELINE ABORTED
========================================
Project: ${JOB_NAME}
Build Number: ${BUILD_NUMBER}
Workspace: ${TERRAFORM_WORKSPACE}
Build URL: ${BUILD_URL}
========================================
"""
        }
    }
}

