#!/bin/bash
# sonarqube-setup.sh

exec > >(tee /var/log/user-data.log) 2>&1
echo "Starting SonarQube setup at $(date)"
echo "Region: ${region}"

# Update system
yum update -y

# System optimization for SonarQube
echo 'vm.max_map_count=524288' >> /etc/sysctl.conf
echo 'fs.file-max=131072' >> /etc/sysctl.conf
echo 'ec2-user soft nofile 131072' >> /etc/security/limits.conf
echo 'ec2-user hard nofile 131072' >> /etc/security/limits.conf
sysctl -p

# Format and mount additional volume
if [[ -b /dev/xvdf ]]; then
    mkfs -t xfs /dev/xvdf
    mkdir -p /opt/sonarqube-data
    mount /dev/xvdf /opt/sonarqube-data
    echo '/dev/xvdf /opt/sonarqube-data xfs defaults,nofail 0 2' >> /etc/fstab
    chmod 777 /opt/sonarqube-data
fi

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install SonarQube with optimized settings
echo "Starting SonarQube container..."
docker run -d \
    --name sonarqube \
    --restart unless-stopped \
    -p 9000:9000 \
    -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
    -e SONAR_JDBC_URL="jdbc:h2:tcp://localhost/sonar" \
    -v /opt/sonarqube-data:/opt/sonarqube/data \
    sonarqube:community

echo "SonarQube setup completed at $(date)"
echo "Region: ${region}"
echo "SonarQube will be available at port 9000"
echo "Default credentials: admin/admin"