```
______  _______ _    _      _____   _____  _______     _______ _     _ _______ _______
 |     \ |______  \  /  ___ |     | |_____] |______ ___ |______  \___/  |_____| |  |  |
 |_____/ |______   \/       |_____| |       ______|     |______ _/   \_ |     | |  |  |
```
# Introduksjon
Oppgave 1 ligger i mappe "kandidat23-generate-image"
Oppgave 2 ligger i mappe "infra"
Oppgave 3 ligger i mappe "java_sqs_client"

Jeg har 5 forskjellige secrets jeg bruker i programmet
Den siste er for alarmer, tengte det var den enkleste måten for sensor å
legge til sin egen mail på en god måte

| Secret |
| --------- |
| AWS_ACCESS_KEY_ID |
| AWS_SECRET_ACCESS_KEY |
| DOCKERHUB_TOKEN |
| DOCKERHUB_USERNAME |
| NOTIFICATION_EMAIL |


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
2. Lenke til en fungerende GitHub Actions workflow (ikke main):
    - https://github.com/Stefannaeve/devops-exam/actions/runs/11991791753
3. SQS-Kø URL:
    - https://eu-west-1.console.aws.amazon.com/sqs/v3/home?region=eu-west-1#/queues/https%3A%2F%2Fsqs.eu-west-1.amazonaws.com%2F244530008913%2Fkandidat23_sqs_queue

# Oppgave 3
#### Oppgave 3A: Skriv en Dockerfile
#### Oppgave 3B: Lag en GitHub Actions workflow som publiserer container image til Docker Hub
1. Beskrivelse av taggestrategi:
    - Jeg endte opp med å gjøre to forskjellige tags, slik at 2 versjoner blir
    pushed til dockerhub hver gang workflowen blir aktivert.
    Den første taggen er git commiten slik den ser ut i github actions, sha
    med bare 7 karakterer. Dette ser jeg for meg er en fantastisk måte å 
    håndtere og følge med på forskjellige versjoner basert på hver git commit.
    Om man vil se hvordan et docker image så ut på en spesifik commit,
    så vil dette være veldig enkelt. Men jeg tenkte også over at dette kan føre
    til stor plass bruk etterhvert, noe som jeg ikke trenger å tenke på under
    denne eksamen, men jeg vil tro det er noe et stort selskap må tenke over.
    Noe kan gjøres med dette med å slette de gamleste images når du har nådd
    et spesifikt nivå foreksempel.

    Tag nr 2 så følger jeg standaren. Der når man lager en oppdatering så setter
    man den nyeste som "latest" slik at det er enkelt for folk å laste ned den
    nyeste versjonen av imaget ditt.
2. Container image + SQS URL
    - stefannaeve/javagenerateimage
    - https://eu-west-1.console.aws.amazon.com/sqs/v3/home?region=eu-west-1#/queues/https%3A%2F%2Fsqs.eu-west-1.amazonaws.com%2F244530008913%2Fkandidat23_sqs_queue

# Oppgave 4
- Add "NOTIFICATION_EMAIL" to your secrets, and add your preferred email
    - Added it as a secret so my own email or the email of the sensor doesnt need
    to openly shown as the repo is public as of delivering the exam
- Skriv om valget mitt av sns istedet for ses

# Oppgave 5

#### Automatisering og Kontinuerlig Levering (CI/CD)
Serverless arkitekrur vil kan oppdatere og håndtere individuelle funksjoner uavhengig av resten av systemet, noe som vil gjøre kontinuerlig levering veldig mye enklere. I motsetning vil mikrotjenester ha mer tydelig avgrenset tjenester, slik at det blir lettere å bygge og vedlikeholde pipelines, men dette kan gjøre det vanskliere å oppdatere små deler av mikrotjenesten.

Med Faas så vil det være enklere å håndtere individuelle funksjoner uavhengig av systemet, man kan i en større grad en mikrotjenester se bort ifra underliggende infrastruktur, dermed gjøre automatisering enklere. Men dette fører også til større mengder funksjoner, dermed økt kompleksitet i pipelines, som krever omfattende automatiserings skripter i utrullings strategier

Mikrotjenester har større og færre som kan føre til enklere pipeline konfigurasjoner og mer stabil utrulling, men dette fører også til kompleks administrasjon når tjenesten kommer til en sådan størrelse at det blir upraktisk.

#### Observability (Overvåkning)
Når man bruker serverless kan man bruke tjenester som Cloudwatch, noe som gjør monitorering av systemet dit meget mye enklere. Men denne "enkelheten" kan føre til større kompleksitet da det er et system som vil være tilkoblet flere individuelle funksjoner.

Mikrotjenester kan i en annen grad få dybere og klarere struktur på logging og overvåkning. Men denne loggingen er krevende, og omfattende overvåkningsverktøy for å kan kommunisere mellom tjenester. 

#### Skalerbarhet og Kostnadskontroll
Skalarbarhet er lett tilgjengelig i faas, og kan dynamisk skaleres basert på etterspørsel, men dette er selvførgelig skummelt med tanke på priser når det gjelds uforsigbare trafikkmønstre. Men betalingsmønstret er på mange andre måter veldig fint, med tanke på servere kan bli kjørt bare på faktiske kall, som setter ned ressursbruken generelt til serveren, som kan være billigere om det passer trafikkmønsteret. Men denne måten å håndtere servere på, men kjøring under faktisk bruk kan være upassende med tanke på begrensninger i minne og ressurser.

Mikrotjenester er veldig fin og forutsigbar, med riktig ressursallokering og administrasjon kan kostnader i stor grad være forutsigbare, men på grunn av arkitekturen så kan man få overprovisjonering av ressurser, som kan føre til høyere kostnader

#### Eierskap og ansvar
Under faas så har man mindre infrastruktur ansvar, som kan få teamet til å fokusere på andre ting som er nødvendig, men dette fører også til mindre kontroll over underliggende infrastruktur. Ansvar for ytelse, pålitelighet og kostnader deles med skyleverandøren, som kan gjøre livet enklere for utvikleren, men samtidig kan skape uklarheter i ansvarsfordelingen

Under mikrotjenester så har man fullt eierskap, da har teamet full kontroll over tjenestene, inkluder ytelse, pålitelighet og kostnader. Men dette gir stor ansvar til teamet, og økt administrasjonsbyrde, som krever større ressurser og kompetanse (i mange tilfeller). Det er enklere og mer tydelig definerte eierskap og ansvar, noe som kan forbedre kvalitet, men mange forskjellige tjenester kan føre til uklarheter og økt kompleksitet i ansvarsfordelig, noe som kan gå utover effektivitet i teamet.

# Konklusjon:
Valget mellom Faas og mikrotjenster bør definitivt bli basert på prosjektet, og teamets behov. Teamets kompetanse er også en stor faktor i en slik situasjon. 

Faas er ideelt for skalerbarhet, og i prosjekter der det kan være forventet med usikker trafikkmønstre, og hvis det er forventet at man har en infrastrukter som skal lages raskt og smått så er det perfekt. Det gir enkel oppdatering av individuelle funksjoner og betalings modellen er basert på faktisk bruk av disse funksjonene. Men dette kan føre til økt kompleksitet og mindre kontroll over infrastrukturen.

På den andre siden har vi mikrotjenester, som gir full kontroll over tjenestene, og tydelig eierskap og ansva. Det passer et team som har kapasiteten til håndtering av kompleksitet i administrasjon og overvåkning. Det passer til et team som kan forvente en mer lineær trafikk, slik at det er en kontinuelig server som går. Men dette kan selvførgelig føre til overprovisjonering av ressurser, og krever mer omfattende administrasjon.

Begge har sine styrker og svakheter, og det beste valget av prosjektets krav og teamets ressurser.



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
