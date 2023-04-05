#!/bin/bash
echo "Adding in user mike"
useradd mike -mU -G admin  -s /bin/bash
mkdir -p /home/mike/.ssh
echo -e "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD4jS7SGn+YdgoqWBJuVF1/wwGrrrLmTT8hR4vFmLyWLxqh4YfBi7K0LfPPBk3uuUkwWF5qm9V+uirH0XTe/9Bo6FfhkplQW8TzVpkBhvREe5qlls3cq/ENKOfpE5X8f1zWVnE6XNmJgXhcmJIcB/lJOMRkzf0MCjX8czxW7LIsWzNNacp/NTwzcG1Ky/svpPBEdst9a8P6PlWOicUHbisSSW7eGo7NrEiHzeL7zH14g/04WXmFIA93iAQPpL15M5wOEEuUDjUFv4XLzNW2nlLMdinQ1qlWAaARviqvcPn5kyqTKn+mS6nwgKDSO4JJppx63jqpHKvJ24HPF7RjYohrWBfbIRz43zFkHq1SQRG7rzHDtPWBvxvyRUSjDpaWE2UVwxG7rzoha/t6UiiZFE37fQ8j2ROxIVKoQn/cMXGS/2VQ6olUY/OGwFQLEvBWq62FbJJmjchEVoG+sA9JOesJNYGKUOodd8ojubHBfts6es6iXLgnAVCpNgJ1RekX8jk=" >> /home/mike/.ssh/authorized_keys
echo -e "mike ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
chown -R mike:mike /home/mike/.ssh
chmod -R 700 /home/mike/.ssh/

echo "adding in svc-neo"
useradd svc-neo -mU -s /bin/bash

#install AWS cli
# you will need to manually add in your creds for the user that you want to give access to
mkdir /opt/aws/
cd /opt/aws/
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
apt install unzip
unzip awscliv2.zip
sudo ./aws/install

#install Docker
apt-get update
apt-get --yes install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-get update
apt-cache policy docker-ce
apt-get --yes install docker-ce
sudo usermod -aG docker svc-neo
sudo usermod -aG docker mike
sudo chmod 666 /var/run/docker.sock

#Install Github Runners
mkdir /opt/github_runners
cd /opt/github_runners
mkdir actions-runner1 && mkdir actions-runner2 && mkdir actions-runner3 && mkdir actions-runner4
curl -o actions-runner-linux-x64-2.299.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.299.1/actions-runner-linux-x64-2.299.1.tar.gz
tar xzf ./actions-runner-linux-x64-2.299.1.tar.gz --directory actions-runner1
tar xzf ./actions-runner-linux-x64-2.299.1.tar.gz --directory actions-runner2
tar xzf ./actions-runner-linux-x64-2.299.1.tar.gz --directory actions-runner3
tar xzf ./actions-runner-linux-x64-2.299.1.tar.gz --directory actions-runner4
chown -R svc-neo:svc-neo /opt/github_runners/
###############################################
#When you need to add runners follow the Configure section of https://github.com/organizations/searchneo/settings/actions/runners/new
###############################################

#install Java8 and maven for the apps that run in the github runner
apt-get --yes install openjdk-8-jre-headless
apt-get --yes install maven

#install cloudwatchAgent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb
echo '{
        "agent": {
                "metrics_collection_interval": 30,
                "run_as_user": "root"
        },
        "logs": {
                "logs_collected": {
                        "files": {
                                "collect_list": [
                                        {
                                                "file_path": "/var/log/syslog",
                                                "log_group_name": "admin-${app_name}",
                                                "log_stream_name": "admin-tools"
                                        }
                                ]
                        }
                }
        },
        "metrics": {
                "aggregation_dimensions": [
                        [
                                "InstanceId"
                        ]
                ],
                "append_dimensions": {
                        "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
                        "ImageId": "$${aws:ImageId}",
                        "InstanceId": "$${aws:InstanceId}",
                        "InstanceType": "$${aws:InstanceType}"
                },
                "metrics_collected": {
                        "cpu": {
                                "measurement": [
                                        "cpu_usage_idle",
                                        "cpu_usage_iowait",
                                        "cpu_usage_user",
                                        "cpu_usage_system"
                                ],
                                "metrics_collection_interval": 30,
                                "resources": [
                                        "*"
                                ],
                                "totalcpu": true
                        },
                        "disk": {
                                "measurement": [
                                        "used_percent",
                                        "inodes_free"
                                ],
                                "metrics_collection_interval": 30,
                                "resources": [
                                        "*"
                                ]
                        },
                        "diskio": {
                                "measurement": [
                                        "io_time"
                                ],
                                "metrics_collection_interval": 30,
                                "resources": [
                                        "*"
                                ]
                        },
                        "mem": {
                                "measurement": [
                                        "mem_used_percent"
                                ],
                                "metrics_collection_interval": 30
                        },
                        "statsd": {
                                "metrics_aggregation_interval": 60,
                                "metrics_collection_interval": 30,
                                "service_address": ":8125"
                        },
                        "swap": {
                                "measurement": [
                                        "swap_used_percent"
                                ],
                                "metrics_collection_interval": 30
                        }
                }
        }
}' > /opt/aws/amazon-cloudwatch-agent/bin/config.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json