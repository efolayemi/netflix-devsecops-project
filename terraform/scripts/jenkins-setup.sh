#!/bin/bash
# jenkins-setup.sh

# Log everything
exec > >(tee /var/log/user-data.log) 2>&1
echo "Starting Jenkins setup at $(date)"
echo "Region: ${region}"
echo "Cluster: ${cluster_name}"

# Update system
yum update -y

# Format and mount additional volume
if [[ -b /dev/xvdf ]]; then
    mkfs -t xfs /dev/xvdf
    mkdir -p /var/jenkins_home
    mount /dev/xvdf /var/jenkins_home
    echo '/dev/xvdf /var/jenkins_home xfs defaults,nofail 0 2' >> /etc/fstab
    chown 1000:1000 /var/jenkins_home
fi

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Configure Docker for better performance
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOL
{
    "storage-driver": "overlay2",
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    }
}
EOL
systemctl restart docker

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install kubectl (using region-specific URL)
echo "Installing kubectl for region: ${region}"
curl -o kubectl "https://s3.${region}.amazonaws.com/amazon-eks/1.28.3/2023-11-14/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/local/bin

# Verify kubectl installation
kubectl version --client --output=yaml

# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Start Jenkins with optimized settings
echo "Starting Jenkins container..."
docker run -d \
    --name jenkins \
    --restart unless-stopped \
    -p 8080:8080 \
    -p 50000:50000 \
    -v /var/jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/local/bin/kubectl:/usr/local/bin/kubectl \
    -v /usr/local/bin/trivy:/usr/local/bin/trivy \
    -e JAVA_OPTS="-Xms1g -Xmx3g -XX:+UseG1GC -XX:+UseStringDeduplication" \
    jenkins/jenkins:lts

# Wait for Jenkins to start and get initial admin password
echo "Waiting for Jenkins to initialize..."
sleep 60

# Try to get initial password multiple times
for i in {1..5}; do
    if docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword > /tmp/jenkins-initial-password 2>/dev/null; then
        echo "Jenkins initial password retrieved successfully"
        break
    else
        echo "Attempt $i: Jenkins not ready yet, waiting 30 seconds..."
        sleep 30
    fi
done

# Set up basic AWS CLI configuration for the cluster
aws configure set region ${region}

echo "Jenkins setup completed at $(date)"
echo "Region: ${region}"
echo "Cluster Name: ${cluster_name}"
echo "Initial admin password saved to /tmp/jenkins-initial-password"