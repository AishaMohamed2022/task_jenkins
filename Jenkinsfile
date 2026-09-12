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
            script {

                def terraformOutput = sh(
                    script: 'terraform output 2>&1 || true',
                    returnStdout: true
                ).trim()

                emailext(
                    subject: "FAILED: ${JOB_NAME} #${BUILD_NUMBER}",

                    body: """
Hello,

The Terraform Jenkins pipeline has FAILED.

Project:
${JOB_NAME}

Build Number:
${BUILD_NUMBER}

Workspace:
${TERRAFORM_WORKSPACE}

Jenkins Project:
${JOB_URL}

Build URL:
${BUILD_URL}

Console Output:
${BUILD_URL}console

Terraform Output:
--------------------------------
${terraformOutput}
--------------------------------

Please check Jenkins Console Output for the complete error.

Regards,
Jenkins
""",

                    to: "aisha.safwat.2002@gmail.com"
                )
            }
        }

        aborted {
            echo """
========================================
PIPELINE ABORTED
========================================
Project: ${JOB_NAME}
Build Number: ${BUILD_NUMBER}
Workspace: ${TERRAFORM_WORKSPACE}
========================================
"""
        }
    }

