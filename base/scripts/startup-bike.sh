#!/bin/bash
echo "Adding in user mike"
useradd mike -mU -G admin  -s /bin/bash
mkdir -p /home/mike/.ssh
echo -e "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD4jS7SGn+YdgoqWBJuVF1/wwGrrrLmTT8hR4vFmLyWLxqh4YfBi7K0LfPPBk3uuUkwWF5qm9V+uirH0XTe/9Bo6FfhkplQW8TzVpkBhvREe5qlls3cq/ENKOfpE5X8f1zWVnE6XNmJgXhcmJIcB/lJOMRkzf0MCjX8czxW7LIsWzNNacp/NTwzcG1Ky/svpPBEdst9a8P6PlWOicUHbisSSW7eGo7NrEiHzeL7zH14g/04WXmFIA93iAQPpL15M5wOEEuUDjUFv4XLzNW2nlLMdinQ1qlWAaARviqvcPn5kyqTKn+mS6nwgKDSO4JJppx63jqpHKvJ24HPF7RjYohrWBfbIRz43zFkHq1SQRG7rzHDtPWBvxvyRUSjDpaWE2UVwxG7rzoha/t6UiiZFE37fQ8j2ROxIVKoQn/cMXGS/2VQ6olUY/OGwFQLEvBWq62FbJJmjchEVoG+sA9JOesJNYGKUOodd8ojubHBfts6es6iXLgnAVCpNgJ1RekX8jk=" >> /home/mike/.ssh/authorized_keys
echo -e "mike ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
chown -R mike:mike /home/mike/.ssh
chmod -R 700 /home/mike/.ssh/
apt-get update
apt-get --yes install nfs-common
apt-get --yes install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-get update
apt-cache policy docker-ce
apt-get --yes install docker-ce
mkdir /mnt/osrm_data
echo "Mount NFS"
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 10.4.2.99:/ /mnt/osrm_data/
screen -d -m docker run -t -i -p 80:5000 -v /mnt/osrm_data/us_west/bike:/data osrm/osrm-backend osrm-routed --algorithm mld /data/us-west-latest.osrm