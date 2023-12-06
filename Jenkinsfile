pipeline {
    agent any

    environment{
        TERRAFORM_DIR="terraform"
    }

    stages {
        stage('Rilevazione segreti repository') {
            steps {
                ansiColor('xterm') {
                    sh "gitleaks detect -f junit -r gitleaks-report.xml"
                }
                junit skipPublishingChecks: true, testResults: 'gitleaks-report.xml'
                archiveArtifacts artifacts: 'gitleaks-report.xml', followSymlinks: false
            }
        }
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
                    ansiColor('xterm') {
                        sh "terrascan scan -t aws || true"
                    }
                    sh "terrascan scan -o junit-xml -t aws > terrascan-report.xml || true"
                    junit skipPublishingChecks: true, testResults: 'terrascan-report.xml'
                    archiveArtifacts artifacts: 'terrascan-report.xml', followSymlinks: false
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
