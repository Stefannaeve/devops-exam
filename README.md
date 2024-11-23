```
______  _______ _    _      _____   _____  _______     _______ _     _ _______ _______
 |     \ |______  \  /  ___ |     | |_____] |______ ___ |______  \___/  |_____| |  |  |
 |_____/ |______   \/       |_____| |       ______|     |______ _/   \_ |     | |  |  |
```

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
