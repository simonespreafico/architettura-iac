pipeline {
    agent any

    environment{
        TERRAFORM_DIR="terraform"
    }

    tools{
        go '1.19'
    }

    stages {
        stage('Terraform init') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    ansiColor('xterm') {
                        sh "terraform init"
                    }
                }
            }
        }
        stage('Validazione configurazione') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    ansiColor('xterm') {
                        sh "terraform fmt"
                        sh "terraform validate"
                    }
                }
            }
        }
        stage('Scansione codice Iac') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    git 'https://github.com/tenable/terrascan.git'
                    dir("terrascan")
                    {
                        sh "sudo touch terrascan.xml"
                        sh 'make build'
                        sh './bin/terrascan scan -d ../. -o junit-xml -t aws > terrascan.xml'
                        junit 'terrascan.xml'
                    }
                }
            }
        }
        stage('Piano creazione infrastruttura') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'simone-aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        ansiColor('xterm') {
                            sh "terraform plan"
                        }
                    }
                }
            }
        }
        stage('Approvazione creazione infrastruttura') {
            steps {
                input "Approvazione creazione infrastruttura?"
            }
        }
        stage('Creazione infrastruttura') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'simone-aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir("${TERRAFORM_DIR}") {
                        ansiColor('xterm') {
                            sh "terraform apply -auto-approve"
                        }
                    }
                }
            }
        }
        stage('Terraform output') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'simone-aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir("${TERRAFORM_DIR}") {
                        ansiColor('xterm') {
                            sh "terraform output"
                        }
                    }
                }
            }
        }
        stage('Piano distruzione infrastruttura') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'simone-aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        ansiColor('xterm') {
                            sh "terraform plan -destroy"
                        }
                    }
                }
            }
        }
        stage('Approvazione distruzione infrastruttura') {
            steps {
                input "Approvazione distruzione infrastruttura?"
            }
        }
        stage('Distruzione infrastruttura') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'simone-aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir("${TERRAFORM_DIR}") {
                        ansiColor('xterm') {
                            sh "terraform destroy -auto-approve"
                        }
                    }
                }
            }
        }
    }
}
