#!/bin/sh
# Run on VM to bootstrap the Foreman server

echo "Updating or Replacing current Puppet"
sudo yum -y erase puppet-agent puppet-server puppet-release* && \
sudo rm /etc/yum.repos.d/pupp* && \
sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm && \
sudo rm -f /etc/yum.repos.d/puppetlabs.repo && \
sudo yum clean all
# Update system 
sudo yum install -y deltarpm wget
sudo yum update -y

if ps aux | grep "/usr/share/foreman" | grep -v grep 2> /dev/null
	then
		echo "Foreman appears to all already be installed. Exiting..."
	else
		sudo yum -y install puppetserver
		sudo yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
		sudo yum -y install https://yum.theforeman.org/releases/latest/el7/x86_64/foreman-release.rpm
		sudo yum -y install foreman-installer nano nmap-ncat
		sudo foreman-installer
	
	# Set-up firewall
	# https://www.digitalocean.com/community/tutorials/additional-recommended-steps-for-new-centos-7-servers
	sudo firewall-cmd --permanent --add-service=http
	sudo firewall-cmd --permanent --add-service=https
	sudo firewall-cmd --permanent --add-port=69/tcp
	sudo firewall-cmd --permanent --add-port=67-69/udp
	sudo firewall-cmd --permanent --add-port=53/tcp
	sudo firewall-cmd --permanent --add-port=53/udp
	sudo firewall-cmd --permanent --add-port=8443/tcp
	sudo firewall-cmd --permanent --add-port=8140/tcp
	
	sudo firewall-cmd --reload
	sudo systemctl enable firewalld
	
	# First run the Puppet agent on the Foreman host which will send the first Puppet report to Foreman,
	# automatically creating the host in Foreman's database
	sudo /opt/puppetlabs/bin/puppet agent -vdt --waitforcert=60
	
	# Optional, install some optional puppet modules on Foreman server to get started...
	#sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-ntp

fi