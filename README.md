# localstack_poc

POC repository for someone who wants a first good look and hands-on experience at Localstack.

What this repository does:
- Creates an AWS Lambda that will get triggered by an S3 bucket file upload. The Lambda stores names of uploaded files in a list in ElastiCache (Redis). All the infrastructure is deployed using Localstack (https://github.com/localstack/localstack) to emulate actual AWS infrastructure at no cost.
- Runs Localstack using Docker via Docker-Compose
- Creates all required infrastructure on Localstack using Terraform

## Installation

### Requires
* [Docker and Docker-compose](https://docs.docker.com/get-docker/)
* [aws-cli v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [redis/redis-cli](https://redis.io/docs/getting-started/)
* Python3.8+

Use the package manager [pip](https://pip.pypa.io/en/stable/) to install the localstack_poc dev dependencies using a virtual environment.

```bash
$ python -m venv --prompt=localstack_poc venv
$ source venv/bin/activate
$ pip install --upgrade pip
$ pip install -r name_transcriber_lambda/requirements_dev.txt
```
Set AWS keys to dummy values to avoid connecting to actual AWS by mistake:
```bash
$ export AWS_DEFAULT_REGION=us-east-1
$ export AWS_SECRET_ACCESS_KEY=test
$ export AWS_ACCESS_KEY_ID=test
```
You need a Localstack API KEY in order to instantiate Localstack and use the pro version to support Elasticache - REDIS. Get a 14-days free trial key at https://localstack.cloud/pricing/

Once you have one, use it:

```bash
$ export LOCALSTACK_API_KEY=<YOUR_PRO_LOCALSTACK_KEY>
# Make sure your API looks as expected
$ echo $LOCALSTACK_API_KEY
```
Now let's instantiate Localstack via Docker-compose in background

```bash
$ docker-compose up -d --build
```

Provision AWS Resources on LocalStack via Terraform
```bash
$ cd tf
$ terraform init
$ terraform apply -auto-approve
```

## Usage/Testing

Create this shell alias to easily interact with AWS resources within the Localstack instance we just set up via Docker-compose. Keep in mind this alias is just scoped to your current shell session.

`alias awslocal="aws --endpoint-url=http://localhost:4566"`

Test that the Redis Cluster is on and listening:

Use `terraform output` to grab the redis_endpoint and connect to it using the redis-cli.
```bash
$ terraform output
lambda_arn = "arn:aws:lambda:us-east-1:000000000000:function:redis-cloudapp_transcriber_default"
lambda_role_name = "redis-cloudapp_transcriber_default"
redis_endpoint = "localhost:4510"
```

As the hostname is `localhost`, we just need to provide the port to ping the Redis cluster:

```bash
$ redis-cli -p 4510 ping
PONG
```
It says PONG, so we are ready to go!

Let's copy a file to s3 to test the lambda:
```bash
awslocal s3 cp testing_file.txt s3://files-redis-cloudapp/
```
And let's retrieve the values in the Redis cluster for the lists `object_names` and `object_keys`:

```bash
$ redis-cli -p 4510 lrange object_names 0 -1
1) "testing_file.txt"
$ redis-cli -p 4510 lrange object_keys 0 -1
1) "testing_file.txt"
```

We can see the name of the testing file that we just used (testing_file.txt) and both lists, so we confirm our POC application is working as expected.

Thanks for reading!

## Docs used:

* https://github.com/localstack/localstack
* https://github.com/localstack/awscli-local
* https://docs.localstack.cloud/get-started/#docker-compose
* https://docs.localstack.cloud/integrations/terraform/
* https://github.com/hashicorp/terraform-elasticache-example


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
Unlicensed
