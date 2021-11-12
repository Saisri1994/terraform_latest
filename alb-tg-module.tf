module "alb-target-group"{
  source= "./modules/alb-target-groups"

region = "us-east1"
alb-tg-name= "test"
target-group-port="80"
target-group-protocol="HTTP"
vpc-id=module.vpc.vpc_id
}
