```groovy
pipeline {
    agent any

    environment {
        TERRAFORM_WORKSPACE = 'dev'
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

                    terraform workspace show
                '''
            }
        }

        stage('Terraform Apply Approval') {
            steps {
                script {

                    timeout(time: 5, unit: 'MINUTES') {

                        input(
                            message: 'Do you want to apply Terraform changes?',
                            ok: 'Proceed',
                            submitterParameter: 'APPROVED_BY'
                        )
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                    terraform apply -auto-approve
                '''
            }
        }
    }

    post {

        success {
            echo "===================================="
            echo "Terraform deployment SUCCESSFUL"
            echo "Build Number: ${BUILD_NUMBER}"
            echo "Jenkins URL: ${BUILD_URL}"
            echo "===================================="
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

The Jenkins Terraform pipeline has FAILED.

Project:
${JOB_NAME}

Build Number:
${BUILD_NUMBER}

Build URL:
${BUILD_URL}

Jenkins Project URL:
${JOB_URL}

Terraform Workspace:
${TERRAFORM_WORKSPACE}

Terraform Output:
----------------------------
${terraformOutput}
----------------------------

Please check the Jenkins console log for the complete error.

Console Output:
${BUILD_URL}console

Regards,
Jenkins
""",

                    to: "aisha.safwat.2002@gmail.com"
                )
            }
        }

        aborted {
            echo "===================================="
            echo "Pipeline was ABORTED"
            echo "Build Number: ${BUILD_NUMBER}"
            echo "===================================="
        }
    }
}
```
