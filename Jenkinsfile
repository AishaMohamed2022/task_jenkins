pipeline {
    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'stag', 'prod'],
            description: 'Select the target environment for Terraform deployment'
        )
    }

    environment {
        AWS_ACCESS_KEY_ID     = 'test'
        AWS_SECRET_ACCESS_KEY = 'test'
        AWS_DEFAULT_REGION    = 'us-east-1'
    }

    stages {
        // Step 1: Pull the latest code from the Git repository
        stage('Checkout Code') {
            steps {
                echo "Checking out code from repository..."
                checkout scm
            }
        }

        // Step 2: Initialize Terraform and download required providers and modules
        stage('Terraform Init') {
            steps {
                echo "Running terraform init..."
                sh 'terraform init'
            }
        }

        // Step 3: Switch to the selected workspace (dev, stag, or prod) or create it if it doesn't exist
        stage('Switch Workspace') {
            steps {
                echo "Switching to workspace: ${params.ENVIRONMENT}"
                script {
                    sh "terraform workspace select ${params.ENVIRONMENT} || terraform workspace new ${params.ENVIRONMENT}"
                }
            }
        }

        // Step 4: Generate and save the Terraform execution plan for the specific environment
        stage('Terraform Plan') {
            steps {
                echo "Running terraform plan for ${params.ENVIRONMENT}..."
                sh "terraform plan -var-file=${params.ENVIRONMENT}.tfvars -out=tfplan"
            }
        }

        // Step 5: Pause execution and wait for manual human approval before applying changes
        stage('Manual Approval') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: "Do you want to apply the changes for [ ${params.ENVIRONMENT} ]?",
                    ok: "Approve"
                }
            }
        }

        // Step 6: Apply the planned infrastructure changes to LocalStack/AWS
        stage('Terraform Apply') {
            steps {
                echo "Applying infrastructure changes..."
                sh "terraform apply tfplan"
            }
        }
    }

    post {
        // Triggered automatically if all stages complete successfully
        success {
            echo "Pipeline completed successfully!"
            emailext (
                subject: "SUCCESS: Pipeline '${env.JOB_NAME} [Build #${env.BUILD_NUMBER}]'",
                body: """Hello,
             The pipeline has successfully executed for the environment: ${params.ENVIRONMENT}
             You can check the build details here: ${env.BUILD_URL}""",
                to: "aisha.safwat.2002@gmail.com"
            )
        }
        // Triggered automatically if any stage fails, providing a direct link to the logs
        failure {
            echo "Pipeline failed! Check the logs."
            emailext (
                subject: "FAILURE: Pipeline '${env.JOB_NAME} [Build #${env.BUILD_NUMBER}]'",
                body: """The pipeline failed for the environment: ${params.ENVIRONMENT}
             To view the logs and troubleshoot the issue, please visit the following link:
             ${env.BUILD_URL}console""",
                to: "aisha.safwat.2002@gmail.com"
            )
        }
    }
}
