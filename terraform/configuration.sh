#!/bin/bash
#aggiornamento pacchetti
echo "Aggiornamento pacchetti istanza..."
yum update –y

#Aggiunta Jenkins repo
echo "Aggiunta del Jenkins Repo..."
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

#Importazione chiave repository jenkins
echo "Importazione chiave repository Jenkins..."
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

#upgrade sistema
echo "Upgrade istanza..."
yum upgrade

#installazione git
echo "Installazione git"
yum install git -y

#installazione java17 per amazon linux
echo "Installazione java-17..."
dnf install java-17-amazon-corretto -y

#installazione jenkins
echo "Installazione Jenkins..."
yum install jenkins -y

#installazione aws-iam-authenticator
echo "Installazione aws-iam-authenticator"
curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.6.11/aws-iam-authenticator_0.6.11_linux_amd64
chmod +x ./aws-iam-authenticator
#copia eseguibile aws-iam-authenticator in cartella bin ed aggiunge percorso a PATH
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

#installazione di kubectl 1.28 (per interagire con il cluster EKS)
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.28.3/2023-11-14/bin/linux/amd64/kubectl
chmod +x ./kubectl
#copia eseguibile kubectl in cartella bin ed aggiunge percorso a PATH
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

#installazione di docker
yum install -y docker
service docker start
#aggiungo utente ec2 a gruppo docker (per eseguire docker senza sudo)
usermod -a -G docker ec2-user

#abilita jenkins all'avvio della macchina
echo "Abilitazione di Jenkins all'avvio della macchina..."
systemctl enable jenkins

#avvia jenkins
echo "Start jenkins..."
systemctl start jenkins

#password per sbloccare jenkins alla prima installazione
echo -n "Jenkins initialAdminPassword: "
cat /var/lib/jenkins/secrets/initialAdminPassword

#controlla che utente jenkins esista sulla macchina e lo aggiunge al file sudoers
if id -u "jenkins" >/dev/null 2>&1; then
    echo 'Utente jenkins esistente, lo abilito nel file sudoers'
    echo 'jenkins ALL=(ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo
else
    echo 'Utente jenkins non esistente'
fi