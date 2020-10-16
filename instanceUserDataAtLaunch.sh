#!/bin/bash
# time to complete from EC2 launch: approx 10 min
# SSH access is available during the User Data script execution
# 1) log of all this will be in: 
#    sudo tail -n30 /var/log/cloud-init-output.log
# 2) user-data script supplied on launch can be found in:
#    sudo more /var/lib/cloud/instances/[instance-id]/user-data.txt
systemctl stop postfix
yum remove postfix -y

yum update -y

cd /home/ec2-user/
wget https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh
bash /home/ec2-user/Anaconda3-2020.02-Linux-x86_64.sh -b -p /home/ec2-user/anaconda3
echo "PATH=\$PATH:/home/ec2-user/anaconda3/bin" > /etc/profile.d/anaconda.sh
echo "export ANACONDA=/home/ec2-user/anaconda3" >> /etc/profile.d/anaconda.sh
source /etc/profile

jupyter lab --generate-config
mv /root/.jupyter /home/ec2-user
mv /root/.conda /home/ec2-user
mv /root/.jupyter /home/ec2-user

pip install -q ipyparallel --upgrade
pip install mysql-connector-python
# py: import mysql.connector
conda install "nodejs>=10.0" -y
conda install conda-forge ipy -y
conda install -y -c conda-forge ipympl
conda update -y --all

pip install boto3
echo "export PYTHONPATH=/home/ec2-user/anaconda3/lib/python3.7/site-packages" >> /home/ec2-user/.bashrc

(mkdir /home/ec2-user/ssl;
cd /home/ec2-user/ssl;
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout mykey.key -out mycert.pem -subj "/C=US/ST=CA/L=SLO/O=Cuesta/OU=CIS225" )

mkdir /home/ec2-user/lab

echo "# Custom settings for jupyter_notebook_config.py, defaults are commented out above
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.open_browser = False
c.NotebookApp.port = 8888
c.NotebookApp.notebook_dir = '/home/ec2-user/lab'
c.NotebookApp.certfile = '/home/ec2-user/ssl/mycert.pem'
c.NotebookApp.keyfile = '/home/ec2-user/ssl/mykey.key'
c.NotebookApp.quit_button = True
c.NotebookApp.password_required = True
c.NotebookApp.allow_password_change = True
c.NotebookApp.password ='sha1:d74aaefdaeb4:422fd8e930397ecd6ebc269fee0421b2b1e2da3e' " >> /home/ec2-user/.jupyter/jupyter_notebook_config.py

echo '#!''/bin/bash
/home/ec2-user/anaconda3/bin/jupyter lab' > jstart.sh
echo "[Unit]
Description=Jupyter Lab Service
[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/
ExecStart=/bin/bash /home/ec2-user/jstart.sh
Restart=no
[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/jupyterlab.service
chmod a+x /etc/systemd/system/jupyterlab.service
systemctl enable jupyterlab.service

echo "Things to do from the linux console, either from a Jupyter terminal or your ssh terminal.

Your jupyter files will be in /home/ec2-user/lab

To change your password: 
jupyter notebook password
sudo systemctl restart jupyterlab.service

To show all notebooks, extensions: 
jupyter notebook list
jupyter labextension list

Jupyter service states (already set to start at boot):
Status: sudo systemctl status jupyterlab.service
to Start: sudo systemctl start jupyterlab.service
to Restart: sudo systemctl restart jupyterlab.service
to Stop: sudo systemctl stop jupyterlab.service
to Launch at boot: sudo systemctl enable jupyterlab.service
to Not Launch at boot: sudo systemctl disable jupyterlab.service

To view Install log: 
    tail -n 30 /var/log/cloud-init-output.log
EC2 user-data script supplied on launch can be found in:
    more /var/lib/cloud/instances/[instance-id]/user-data.txt
The usual linux logs are in: /var/log/

Conda update everything:
conda update -y --all

Jupyter re-builds are slow
" > /home/ec2-user/lab/readme.txt

chown -R ec2-user:ec2-user /home/ec2-user
chmod -R u+rw /home/ec2-user
chmod -R u+rw,g-rwx,o-rwx /home/ec2-user/ssl
chown -R ec2-user:ec2-user /home/ec2-user/anaconda3/

jupyter labextension install @jupyter-widgets/jupyterlab-manager
jupyter labextension install @jupyter-widgets/jupyterlab-manager jupyter-leaflet
conda update -y --all
#jupyter lab build
#
rm /home/ec2-user/Anaconda3-2020.02-Linux-x86_64.sh
systemctl start jupyterlab.service
