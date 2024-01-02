pipeline {
    agent any

    parameters {
        booleanParam(name: "distruzione", description: "Distruggere l'infrastruttura?", defaultValue: false )
    }

    environment {
        TERRAFORM_DIR="terraform"
        PROMETHEUS_DIR="prometheus"
        KUBE_METRICS_DIR='kube-state-metrics'
        DASHBOARD_DIR='dashboard'

        AWS_REGION='us-east-1'
        CLUSTER_NAME='cluster-simone'
    }

    stages {
        stage('Update tool security') {
            steps {
                script {
                    echo "Update gitleaks..."
                    sh '''#!/bin/bash
                    git clone https://github.com/gitleaks/gitleaks.git
                    cd gitleaks
                    make format
                    make clean
                    make build
                    sudo chown -R root gitleaks
                    sudo chgrp -R root gitleaks
                    sudo cp gitleaks /usr/bin/
                    cd ..
                    sudo rm -Rf gitleaks
                    '''
                    echo "gitleaks updated!"
                    echo "Update terrascan..."
                    sh '''#!/bin/bash
                    curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz
                    tar -xf terrascan.tar.gz terrascan && rm terrascan.tar.gz
                    sudo install terrascan /usr/local/bin && rm terrascan
                    '''
                    sh 'terrascan init'
                    if(fileExists('gitleaks-report.xml'))
                    {
                        sh 'rm gitleaks-report.xml'
                    }
                    if(fileExists('terraform/terrascan-report.xml'))
                    {
                        sh 'rm terraform/terrascan-report.xml'
                    }
                    echo "terrascan updated!"
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
        stage('Scansione codice Iac') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    ansiColor('xterm') {
                        sh 'terrascan scan -t aws -i terraform --skip-rules="AC_AWS_0369"'
                    }
                    sh 'terrascan scan -t aws -i terraform -o junit-xml --skip-rules="AC_AWS_0369" > terrascan-report.xml'
                    junit skipPublishingChecks: true, allowEmptyResults: true, testResults: 'terrascan-report.xml'
                    archiveArtifacts artifacts: 'terrascan-report.xml', followSymlinks: false
                }
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
        stage('Monitoring') {
            when {
                expression {
                    return params.distruzione == false
                }
            }
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'simone-aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh 'aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}'
                    sh 'kubectl --kubeconfig /var/lib/jenkins/.kube/config cluster-info'
                    
                    dir("${KUBE_METRICS_DIR}") {
                        sh 'kubectl apply -f .'
                    }
                    
                    dir("${PROMETHEUS_DIR}") {
                        sh 'kubectl create namespace monitoring || true'
                        sh 'kubectl apply -f .'
                    }

                    dir("${DASHBOARD_DIR}") {
                        sh 'kubectl apply -f .'
                        sh 'kubectl create serviceaccount dashboard -n kubernetes-dashboard || true'
                        sh 'kubectl create clusterrolebinding dashboard-admin -n kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:dashboard || true'
                        
                        script {
                            def tokendashboard = sh(returnStdout: true, script: "kubectl -n kubernetes-dashboard create token dashboard")
                            echo "K8s dashboard access token: ${tokendashboard}"
                        }
                    }
                    sh 'kubectl create deployment grafana --image=docker.io/grafana/grafana:latest -n monitoring || true'
                    sh 'kubectl expose deployment grafana --type LoadBalancer --port 3000 -n monitoring || true'
                    
                    script {
                        def grafana_url = sh(returnStdout: true, script: "kubectl get service grafana -n monitoring --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}'")
                        echo "Grafana accessibile da ${grafana_url}:3000"
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
