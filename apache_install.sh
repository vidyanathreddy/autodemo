#!/bin/bash

## Update packages
sudo apt update -y
## Install apache2
sudo apt install apache2 -y
systemctl start apache2
systemctl enable apache2
       

