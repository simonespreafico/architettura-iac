# configurazione macchina ec2 devops

#!/bin/bash

#aggiornamento pacchetti
echo "Aggiornamento pacchetti istanza..."
sudo yum update –y

#Aggiunta Jenkins repo
echo "Aggiunta del Jenkins Repo..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

#Importazione chiave repository jenkins
echo "Importazione chiave repository Jenkins..."
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

#upgrade sistema
echo "Upgrade istanza..."
sudo yum upgrade

#installazione java17 per amazon linux
echo "Installazione java-17..."
sudo dnf install java-17-amazon-corretto -y

#installazione jenkins
echo "Installazione Jenkins..."
sudo yum install jenkins -y

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
sudo yum install -y docker
sudo service docker start
#aggiungo utente ec2 a gruppo docker (per eseguire docker senza sudo)
sudo usermod -a -G docker ec2-user

#abilita jenkins all'avvio della macchina
echo "Abilitazione di Jenkins all'avvio della macchina..."
sudo systemctl enable jenkins

#avvia jenkins
echo "Start jenkins..."
sudo systemctl start jenkins

#password per sbloccare jenkins alla prima installazione
echo -n "Jenkins initialAdminPassword: "
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

#controlla che utente jenkins esista sulla macchina e lo aggiunge al file sudoers
if id -u "jenkins" >/dev/null 2>&1; then
    echo 'Utente jenkins esistente, lo abilito nel file sudoers'
    echo 'jenkins ALL=(ALL) NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo
else
    echo 'Utente jenkins non esistente'
fi

#disabilita ec2 metadata
echo "EC2 metadata disabled"
echo 'AWS_EC2_METADATA_DISABLED=true' >> /etc/environment
systemctl restart systemd-resolved