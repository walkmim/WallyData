

---------------------------------------------------------------------------------
Assume role test

aws sts assume-role --role-arn arn:aws:iam::accont_id:role/Role_name --role-session-name session_name

---------------------------------------------------------------------------------
config file exemplo

[default]
region = us-east-1
output = json

[profile contasecundaria]
region = us-east-1
role_arn = arn:aws:iam::accont_id:role/Role_Assume_Describe_EC2
source_profile = default

---------------------------------------------------------------------------------
list profiles - AWS CLI

aws configure list-profiles

---------------------------------------------------------------------------------
decribe instance especific account/profile

aws ec2 describe-instances --profile contasecundaria

---------------------------------------------------------------------------------