# Jupyter-Anaconda-AWS-EC2
AWS EC2 launch script.  While building your own EC2 as you wish, use this to install a Jupyter server as a service on an EC2 with a self-signed cert and public IPv4. Includes a mash from various web sources.
Connect using https://{ec2 ipv4}:8888

The script does:
- update o/s
- pull anaconda for its jupyter.  not installing X so no front-end
- install python modules for mapyleaflet
- creates a service 'Jupyter' that runs the server. It starts automatically on re/boots. If you stop juptyer server, then you can restart from a console like AWS CLI or SSH; the service can but is not set to restart. You'll see the service file sitting in the home directory (cuz) jupyter.sh
- runs the Juptyer server from the \lab directory
- again, these are self-signed certificates of not too much authority.

1. Launch an EC2
  - Upload the script file as User Data Text File
  - Suggest: t2.medium , 15GB EBS
  - Add 2 inboud rules, limit source to MyIp:
    1. MySQL/Aurora
    2. Custom port 8888
  - Launch the EC2
  - Wait 10 minutes before attempting to login
  - use the EC2 public ipv4 (like https://243.33.2.1:8888 ) not the url ( like my-ec2-amazon.whatever.com  to log in, use https, port 8888, ignore (but be cognizant of) browser unsafe warnings.
