masterMain = {
    region = "us-west-2"
    profile = "hansenites"
    domain = "hansenites.com"
    company = "Hansenites"
    adminlane = "adm"
    aws_account_id = "" #233205205553
    docker_image_id = "6e654e0e06b3" //This is the docker image from your local box that you want to push
    certificate_arn = "" // us-west-2 aeonai.com
    slack_ops_hook = ""
    slack_ci_fe_hook = ""
    slack_ci_be_hook = ""
    slack_notify_function = "lambda-cloudwatch-slack-05232022.zip" //you can pull this from the github/mhansenite/aws-slacknotify
    
}


//##############################################################################
//appliction configs ###########################################################
//##############################################################################
//ECS Instances
//////////////////////////
/// hansenites.com

website_vars = {
    app_name = "website",
    app_use = "classic"
    additional_zone_access_pl=[]
    cpu = "2048",
    memory = "4096",
    tg_proto_version = "HTTP1",
    tg_proto = "HTTP",
    tg_match = "200",
    cw_filter_pattern ="[w1,w2=\"ERROR\",w3,w4,w5]",
    domain = "hansenites.com",
    internal_lb = "false",
    lb_connect = "public",
    image_uri = "089613740549.dkr.ecr.us-west-2.amazonaws.com/aeonai-ws:b668477c2a41dd7f8178cfdcf55344e86f974dd2", // this is the uri of the container that you want to deploy 
    hc_path = "/",
    storage = 21,
    tg_port = 80,
    lb_port = 80, //you need to add this port manually first
    external_port= 8080,
    internal_port = 8080,
    instance_count = 1
}

//EC2/////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
vpn_vars = {
    app_name = "vpnweb",
    app_use = "admin",
    ami_id = "ami-0d10bccf2f1a6d60b",
    startup_script = "startup.sh",
    additional_zone_access_pl={},
    ec2_size= "t2.small",
    create_lb ="true",
    tg_proto_version = "HTTP1",
    tg_proto = "HTTPS",
    tg_match = "200",
    cw_filter_pattern ="Error",
    domain = "aeonai.com",
    internal_lb = "false",
    lb_connect  =  "public",
    hc_path = "/",
    storage = 200,
    tg_port = 443,
    lb_port = 443, //you need to add this port manually first
    external_port= 443,
    internal_port = 443,
    instance_count = 1
}
tools_vars = {
    app_name = "tools",
    app_use = "admin",
    ami_id = "ami-0892d3c7ee96c0bf7",
    startup_script = "startup.sh",
    additional_zone_access_pl={},
    ec2_size= "t2.small",
    create_lb ="false",
    tg_proto_version = "HTTP1",
    tg_proto = "HTTPS",
    tg_match = "200",
    cw_filter_pattern ="Error",
    domain = "searchneo.com",
    internal_lb = "true",
    lb_connect  =  "private",
    hc_path = "/",
    storage = 200,
    tg_port = 22,
    lb_port = 22, //you need to add this port manually first
    external_port= 22,
    internal_port = 22,
    instance_count = 1
}






//##############################################################################
//Lane configs #################################################################   Dont Change these unless you know what you are doing
//##############################################################################
adm_vars = {
    lane_full = "Admin",
    lane = "adm",
    app_use = "classic",
    additional_zone_access_pl=[],
    env_file_path = "" //arn:aws:s3:::deployments-prod"  --- s3 bucket path where Env files are stored
    slack_alert_hook= ""
    slack_logs_hook = ""
    slack_update_hook = ""
    vpc_cidr_block = "10.11.0.0/16",
    subnets_app = [{
        name = "AP-Zone-1",
        cidr_block = "10.11.2.0/24"
        avl_zone ="a"
     },{
        name = "AP-Zone-2",
        cidr_block = "10.11.4.0/24"
        avl_zone ="b"
    }]
    subnets_db = [{
        name = "DB-Zone-1",
        cidr_block = "10.11.1.0/24"
        avl_zone ="a"
    },{
        name = "DB-Zone-2",
        cidr_block = "10.11.3.0/24"
        avl_zone ="b"
    }]
}
prd_vars = {
    lane_full = "Prod",
    lane = "prd",
    app_use = "classic",
    additional_zone_access_pl=[],
    env_file_path = ""//arn of s3 bucket
    slack_alert_hook= ""
    slack_logs_hook = ""
    slack_update_hook = ""
    vpc_cidr_block = "10.4.0.0/16",
    subnets_app = [{
        name = "AP-Zone-1",
        cidr_block = "10.4.2.0/24"
        avl_zone ="a"
    },{
        name = "AP-Zone-2",
        cidr_block = "10.4.4.0/24"
        avl_zone ="b"
   }],
    subnets_db = [{
        name = "DB-Zone-1",
        cidr_block = "10.4.1.0/24"
        avl_zone ="a"
    },{
        name = "DB-Zone-2",
        cidr_block = "10.4.3.0/24"
        avl_zone ="b"
    }]
}
stg_vars = {
    lane_full = "Stage",
    lane = "stg",
    app_use = "classic",
    additional_zone_access_pl=[],
    env_file_path = ""//arn:aws:s3:::deployments
    slack_alert_hook= ""
    slack_logs_hook = ""
    slack_update_hook = ""
    vpc_cidr_block = "10.5.0.0/16",
    subnets_app = [{
        name = "AP-Zone-1",
        cidr_block = "10.5.2.0/24"
        avl_zone ="a"
    },{
        name = "AP-Zone-2",
        cidr_block = "10.5.4.0/24"
        avl_zone ="b"
   }],
    subnets_db = [{
        name = "DB-Zone-1",
        cidr_block = "10.5.1.0/24"
        avl_zone ="a"
    },{
        name = "DB-Zone-2",
        cidr_block = "10.5.3.0/24"
        avl_zone ="b"
    }]
}

tst_vars = {
    lane_full = "Test",
    lane = "tst",
    app_use = "classic",
    additional_zone_access_pl=[],
    env_file_path = ""//arn of s3 bucket
    slack_alert_hook= ""
    slack_logs_hook = ""
    slack_update_hook = ""
    vpc_cidr_block = "10.6.0.0/16",
    subnets_app = [{
        name = "AP-Zone-1",
        cidr_block = "10.6.2.0/24"
        avl_zone ="a"
     },{
        name = "AP-Zone-2",
        cidr_block = "10.6.4.0/24"
        avl_zone ="b"
    }],
    subnets_db = [{
        name = "DB-Zone-1",
        cidr_block = "10.6.1.0/24"
        avl_zone ="a"
    },{
        name = "DB-Zone-2",
        cidr_block = "10.6.3.0/24"
        avl_zone ="b"
    }]
}
