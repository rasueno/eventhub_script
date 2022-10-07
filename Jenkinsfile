pipeline {
    agent {
        label 'Ansible'
    }

    stages {
        stage('Git Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${env.branch_name}"]],
                    doGenerateSubmoduleConfigurations: false, 
                    extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: "apps/${env.code_repo}"]],
                    submoduleCfg: [], 
                    userRemoteConfigs: [[credentialsId: 'ghe-prod', url: "https://github.${env.company}.com/${env.organization}/${env.code_repo}.git"]]
                ])
            }
        }
        stage('Prepare Azure CLI') {
            steps {
                sh '''
                    az login --service-principal -u ${az_client_id} -p ${az_secret} --tenant ${az_tenant}
                    az account set --subscription ${az_subscription}
                '''
            }
        }
        stage('Build tf file') {
            steps {
                sh '''
                    set +x
                    export ARM_CLIENT_ID="${az_client_id}"
                    export ARM_CLIENT_SECRET="${az_secret}"
                    export ARM_SUBSCRIPTION_ID="${az_subscription}"
                    export ARM_TENANT_ID="${az_tenant}"
                    set -X

                    cp apps/${code_repo}/eventhub.ini .
                    ./buildtf.sh
                '''
            }
        }
        stage('Terraform Init') {
            steps {
                sh '''
                    set +x
                    export ARM_CLIENT_ID="${az_client_id}"
                    export ARM_CLIENT_SECRET="${az_secret}"
                    export ARM_SUBSCRIPTION_ID="${az_subscription}"
                    export ARM_TENANT_ID="${az_tenant}"
                    set -X
                    terraform init --backend-config=backend.tfvars
                '''
            }
        }
        stage('Terraform Plan') {
            steps{
                sh '''
                    set +x
                    export ARM_CLIENT_ID="${az_client_id}"
                    export ARM_CLIENT_SECRET="${az_secret}"
                    export ARM_SUBSCRIPTION_ID="${az_subscription}"
                    export ARM_TENANT_ID="${az_tenant}"
                    set -X
                    terraform plan
                '''
            }
        }
        stage('Review') {
            steps {
                script {
                    env.RELEASE_SCOPE = input message: 'Do you want to apply plan?', ok: 'Apply',
                                              parameters: [choice(name: 'action', choices: ['Do Not Apply', 'Apply'], 
                                                       description: 'Do you want to apply plan?')]
                }
            }
        }
        stage('Terraforl Apply') {
            steps {
                sh '''
                    echo "not implemented"
                '''
            }
        }
        stage('Cleanup') {
            steps {
                sh '''
                    echo "not implemented"
                '''
            }
        }
    }
}