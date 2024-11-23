```
______  _______ _    _      _____   _____  _______     _______ _     _ _______ _______
 |     \ |______  \  /  ___ |     | |_____] |______ ___ |______  \___/  |_____| |  |  |
 |_____/ |______   \/       |_____| |       ______|     |______ _/   \_ |     | |  |  |
```

# Oppgave 1
#### Oppgave 1A: Implementer en Lambda-funksjon med SAM og API Gateway
1. HTTP Endepunkt for Lambdafunkskonen som sensor kan teste med Postman
   - https://tiuynyv8fb.execute-api.eu-west-1.amazonaws.com/Prod/generate-image

#### Oppgave 1B: Opprett en GitHub Actions Workflow for SAM-deploy
1. Lenke til kjørt GitHub Actions workflow
    - https://github.com/Stefannaeve/devops-exam/actions/runs/11990391053

# Oppgave 2
#### Oppgave 2A: Infrastruktur som kode
1. Ingen leverings instrukser, men viser til folder i pgr301-
   couch-explorers
    - https://eu-west-1.console.aws.amazon.com/s3/buckets/pgr301-couch-explorers?region=eu-west-1&bucketType=general&prefix=23/task_2/&showversions=false

#### Oppgave 2B: Opprett en GitHub Actions Workflow for Terraform
1. Lenke til kjørt GitHub Actions workflow
    - https://github.com/Stefannaeve/devops-exam/actions/runs/11990391057
2. Lenke til en fungerende GitHub Actions workflow (ikke main): (Denne må gjøres)
3. SQS-Kø URL:
    - https://eu-west-1.console.aws.amazon.com/sqs/v3/home?region=eu-west-1#/queues/https%3A%2F%2Fsqs.eu-west-1.amazonaws.com%2F244530008913%2Fkandidat23_sqs_queue

# Oppgave 3
#### Oppgave 3A: Skriv en Dockerfile
#### Oppgave 3B: Lag en GitHub Actions workflow som publiserer container image til Docker Hub
1. Beskrivelse av taggestrategi: (Denne må gjøres)
2. Container image + SQS URL
    - stefannaeve/javagenerateimage
    - https://sqs.eu-west-1.amazonaws.com/244530008913/kandidat23_sqs_queue

# Oppgave 4


Task one:
    I used sam init to initailize the sam instance called 
    kandidat23-generate_image. 
    
    I made the app.py in generateImage inside the sam initialization work as a 
    hello world application at first. Using the template.yaml file to specify 
    functions and generate the role in which i wanted to use
    
    Now i made a python scipt based on the generate_image in root.
    
    Keys will be needed to run this application itself. Made in aws, and applied 
    inside github secrets
    
    sam build
    sam deploy
    
Task two:
    wget https://releases.hashicorp.com/terraform/1.9.0/terraform_1.9.0_linux_amd64.zip
    unzip terraform_1.9.0_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
    
    terraform plan -var="prefix=kandidat23" -out=tfplan.out
    
    You can change the plan to add various variables to define where you want to
    store the picture. These variables are *bucket_name*, and *bucket_folder*.
    You can change the email as well if you want to, by changing the variable
    *notification_email*
    
    Updated terraform plan based on what i asume the teacher (sensor) want
    terraform plan -var"prefix=kandidat23" -var="notification_email=glenn.bech@gmail.com" -out=tfplan.out
    
    terraform apply tfplan.out
    
    terraform apply does do the process of plan, but for some reason i just like
    "controll" the plan gives me
    
    A guy doing a backflip holding a giant billboard which says I AM GLENN
    
    B:
    Det blir ikke nevnt noen sted at jeg skal returnere en .out fil eller 
    lignenede fra plan, så når main ikke blir kjørt, så blir plan kjørt uten en 
    form for fil returneres
    
Task three:

```bash
export SQS_QUEUE_URL=
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```
