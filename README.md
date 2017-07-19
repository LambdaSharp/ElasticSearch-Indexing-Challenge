# λ# Indexing in the Cloud - July 2017 Team Hackathon Challenge (Theme: ComicCon)
Traditional relational databases are still very prevalent today. Often however, we need to search or slice and dice the data many different ways and RDBMS's are not great at that. As many do, will be using [ElasticSearch](https://aws.amazon.com/elasticsearch-service/) to provide this functionality. Today we will explore how AWS Lambda can help us index our relational data into ElasticSearch with minimal effort and cost. We will be using [Amazon Aurora](https://aws.amazon.com/rds/aurora/) (MySQL), [Amazon Lambda](https://aws.amazon.com/lambda/), and [ElasticSearch](https://aws.amazon.com/elasticsearch-service/). 

We will setup database triggers to fire a lambda function when an INSERT, UPDATE or DELETE occurs in Aurora. The lambda function will then be responsible for updating the ElasticSearch index.

### Pre-requisites
The following tools and accounts are required to complete these instructions.

* [Install .NET Core 1.x](https://www.microsoft.com/net/core)
* [Install AWS CLI](https://aws.amazon.com/cli/)
* [Sign-up for an AWS account](https://aws.amazon.com/)
* [Sign-up for an Amazon developer account](https://developer.amazon.com/)
* Python 2.7
* pymysql: `pip install pymysql`
* MySQL client (for example: [Mysql Workbench](https://www.mysql.com/products/workbench/)).

## LEVEL 0 - Setup
The following steps will walk you through the set-up of an Aurora Cluster (MySQL), an ElasticSearch cluster and the provided lambda function that will do the indexing.

### Create `lambdasharp` AWS Profile
The project uses by default the `lambdasharp` profile. Follow these steps to setup a new profile if need be.

1. Create a `lambdasharp` profile: `aws configure --profile lambdasharp`
2. Configure the profile with the AWS credentials and region you want to use

### Create `LambdaSharp-IndexerFunction` role for the lambda function
The `LambdaSharp-IndexerFunction` lambda function requires an IAM role. You can create the `LambdaSharp-IndexerFunction` role via the [AWS Console](https://console.aws.amazon.com/iam/home) or use the executing [AWS CLI](https://aws.amazon.com/cli/) commands.
```shell
aws iam create-role --profile lambdasharp --role-name LambdaSharp-IndexerFunction --assume-role-policy-document file://assets/lambda-role-policy.json
aws iam attach-role-policy --profile lambdasharp --role-name LambdaSharp-IndexerFunction --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess
```

### Create `LambdaSharp-RdsRole` role for the Aurora cluster
The Aurora cluster will need permissions to invoke the lambda function. You can create the `LambdaSharp-RdsRole` role via the [AWS Console](https://console.aws.amazon.com/iam/home) or use the executing [AWS CLI](https://aws.amazon.com/cli/) commands.
```shell
aws iam create-role --profile lambdasharp --role-name LambdaSharp-RdsRole --assume-role-policy-document file://assets/rds-role-policy.json
aws iam attach-role-policy --profile lambdasharp --role-name LambdaSharp-RdsRole --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess
```

### Aurora (MySQL)

1. Log into your AWS account and go into the Aurora/RDS service
2. Select `Launch Aurora (MySQL)`
3. Select the smallest cluster possible, and disable `Multi-AZ Deployment` unless you have some cash to burn.
4. Click `Next Step`
5. Set `Publically Accessible` to `yes`
6. Set `lambdasharp` as the database name
7. Click `Launch DB Instance`

Once your cluster has finished loading, log into it using a MySQL client, I recommend [Mysql Workbench](https://www.mysql.com/products/workbench/).

8. Create the following table
```sql
CREATE TABLE heroes (
  id int not null auto_increment primary key,
  name varchar(255),
  urlslug varchar(4096),
  identity varchar(255),
  alignment varchar(255),
  eye_color varchar(255),
  hair_color varchar(255),
  sex varchar(255),
  gsm varchar(255),
  alive varchar(255),
  appearances int,
  first_appearance varchar(10),
  year int,
  lon double,
  lat double
);

```

In order for Aurora to be able to invoke a Lambda function we need to assign it the `LambdaSharp-RdsRole` role.

9. In the RDS console, select `Clusters`
10. Select your cluster, and select `Manage IAM Roles`
11. Add the `LambdaSharp-RdsRole` role
12. Restart your cluster for the changes to take effect

### ElasticSearch

1. Log into your AWS account and go into the ElasticSearch service
2. Click `Create a new domain`
3. Give it a unique name such as `lambdasharp-index-team1`
4. Use the lastest available version
5. Click `Next`
6. Select the smallest allowable cluster
7. Click `Next`
8. For `Set the domain access policy to` select `Allow open access to the domain`. (Clearly never do this in production)

### Lambda Function

1. Navigate into the lambda function folder: `cd TriggerFunction/src/TriggerFunction/`
2. Run: `dotnet restore`
3. Edit `aws-lambda-tools-defaults.json` and make sure everything is set up correctly
4. Run: `dotnet lambda deploy-function`

### Finally, let's insert some data into MySQL!

You are provided with a data set that contains super heroes from the Marvel universe in a file called `marvel_data.csv`. Modified from [original](It contains the following header). `lat` and `long` columns were added that represent the location of the super hero on earth.

Let's insert `20` rows of data into MySQL:
```shell
python insert_heroes.py marvel_data.csv MYSQL_HOST MYSQL_USER MYSQL_PASSWORD lambdasharp 20 
```

Verify that your database now has some data:
```sql
SELECT * FROM heroes
```

## Level 1 (Hawkeye)
Set up a [MySQL trigger](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Aurora.Lambda.html) to invoke our lambda function when a new record is inserted. Give it all the available data about the hero so that we can index it later.

## Level 2 (Martian Manhunter)
1. Create an index in ElasticSearch called `heroes` with the following schema:
```json
PUT heroes
{
    "settings" : {
        "number_of_shards" : 1
    },
    "mappings" : {
        "hero" : {
            "properties" : {
                "name" : { "type" : "text" },
                "urlslug" : { "type" : "text" },
                "identity" : { "type" : "text" },
                "alignment" : { "type" : "text" },
                "eye_color" : { "type" : "text" },
                "hair_color" : { "type" : "text" },
                "sex" : { "type" : "text" },
                "gsm" : { "type" : "text" },
                "alive" : { "type" : "text" },
                "appearances" : { "type" : "integer" },
                "first_appearance" : { "type" : "text" },
                "year" : { "type" : "integer" },
                "location": { "type": "geo_point" }
            }
        }
    }
}

```
**NOTE**: The ElasticSearch service comes with [Kibana](https://www.elastic.co/products/kibana) which provides a convenient interface for data exploration as well as making API calls (for creating the index for example)

2. Extend the lambda function to index the heroes into our new index.

## Level 3 (Worldbreaker Hulk)
Keep the index synchronized when updates or deletions happen in MySQL.

## Boss Level (Dr. Manhattan)
Using [Kibana](https://www.elastic.co/products/kibana) plot the location of all the super heroes in the world. Where are they located? (Hint: it's ComicCon)

## Acknowledgements
* Oscar Cornejo for helping envision and prototype this hackathon.
* Erik Birkfeld for organizing.
* [MindTouch](https://mindtouch.com/) for hosting.
* [ArkusNexus](http://arkusnexus.com/) for sponsoring & participating!

## Copyright & License
* Copyright (c) 2017 Yuri Gorokhov, Oscar Cornejo
* MIT License
