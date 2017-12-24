# fargate-from-lambda
Example code that launches a docker container on AWS Fargate from AWS Lambda

## AWS Fargate
[Fargate](https://aws.amazon.com/fargate/) was announced at Re:Invent 2017.
Though the concept is not new, the idea is that AWS manages the infrastructure
on-demand and runs containers which you pay for per second. In my opinion,
Fargate only has a few usecases. This is mainly due to the relatively high cost
of Fargate. Fargate can be useful in cases where you need to run containers
on-demand and infrequently.

## AWS Lambda
Lambda has modest restrictions, but they do exist. At times where you need to
infrequently run something longer than the Lambda timeout (5 minutes), you can
either refactor your workflow and break it up, or run the thing in Fargate
without code changes.

This repo shows an example of running two containers in a Fargate task which is
invoked from a Lambda function. The containers run for 10 seconds and do a
simple echo per second. [Dockerfile here](https://github.com/jolexa/dockerfiles/blob/master/echo-10/Dockerfile).

### Things I learned
* Fargate must run containers in a VPC, subnet, security group
  * To maintain isolation, this repo creates an entire VPC for the purpose of
  running "echo-10".
* Fargate requires an ECS Cluster. This cluster can have no EC2 associated with
it.
  * This seems like a weird implementation quirk in my opinion. I would rather
   have seen a new user interface instead of overloading ECS.
* Fargate is expensive.
* If you don't create a log group properly, you will never see the docker logs.
  * There is little debugging available and I was scratching my head a few
  times.
* ECS Task definition in CloudFormation is less scary than the documentation
suggests.
