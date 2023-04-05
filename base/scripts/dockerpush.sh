pull or create docker image 

aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 089613740549.dkr.ecr.us-west-2.amazonaws.com

docker tag nginx 089613740549.dkr.ecr.us-west-2.amazonaws.com/osrm:2

docker push 089613740549.dkr.ecr.us-west-2.amazonaws.com/osrm:2