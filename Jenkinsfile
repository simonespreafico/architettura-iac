pipeline {
    agent any

    parameters {
        booleanParam(name: "distruzione", description: "Distruggere l'infrastruttura?", defaultValue: false )
    }

    environment {
        TERRAFORM_DIR="terraform"
        SEC_TOOLS_DIR="sec-tools"
    }

    stages {
        stage('Update tool security') {
            steps {
                dir("${SEC_TOOLS_DIR}")
                {
                    sh "./gitleaks-installation.sh"
                    sh "./terrascan-installation.sh"
                }
            }
        }
        stage('Rilevazione segreti repository') {
            steps {
                ansiColor('xterm') {
                    sh "gitleaks detect -f junit -r gitleaks-report.xml"
                }
                junit skipPublishingChecks: true, allowEmptyResults: true, testResults: 'gitleaks-report.xml'
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
                sh "brew upgrade terrascan"
                dir("${TERRAFORM_DIR}") {
                    ansiColor('xterm') {
                        sh "terrascan scan -t aws || true"
                    }
                    sh "terrascan scan -o junit-xml -t aws > terrascan-report.xml || true"
                    junit skipPublishingChecks: true, allowEmptyResults: true, testResults: 'terrascan-report.xml'
                    archiveArtifacts artifacts: 'terrascan-report.xml', followSymlinks: false
                }
            }
        }
        stage('Piano creazione infrastruttura') {
            when {
                expression {
                    return params.distruzione == false
                }
            }
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
            when {
                expression {
                    return params.distruzione == false
                }
            }
            steps {
                input "Approvazione creazione infrastruttura?"
            }
        }
        stage('Creazione infrastruttura') {
            when {
                expression {
                    return params.distruzione == false
                }
            }
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
            when {
                expression {
                    return params.distruzione == false
                }
            }
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
            when {
                expression {
                    return params.distruzione == true
                }
            }
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
            when {
                expression {
                    return params.distruzione == true
                }
            }
            steps {
                input "Approvazione distruzione infrastruttura?"
            }
        }
        stage('Distruzione infrastruttura') {
            when {
                expression {
                    return params.distruzione == true
                }
            }
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
