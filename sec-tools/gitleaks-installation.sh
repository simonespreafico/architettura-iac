#!/bin/bash

git clone https://github.com/gitleaks/gitleaks.git
cd gitleaks
make build
sudo chown -R root gitleaks
sudo chgrp -R root gitleaks
sudo cp gitleaks /usr/bin/
cd ..
sudo rm -Rf gitleaks
echo "gitleaks installato correttamente"
