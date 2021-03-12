# TILT!

Sposób na lokalny development na promilu

---

### Idealne środowisko developerskie

Jakie powinno być?

- łatwo się powinno stawiać
- w miare lekkie
- identyczne z produkcyjnym
- szybki wgląd w zmiany

---
# Lekcja historii
---

# Le Grande Vagrant devaux enveau

[listen](https://translate.google.com/?sl=fr&tl=pl&text=Le%20Grande%20Vagrant%20devaux%20enveau&op=translate)
---

## Proste jak elektronika w peugocie

[PPMB 5.0.1 - how to dev](https://github.com/PiwikPRO/common-PPMB-Dev-Environment/blob/5.0.1/docs/HOW_TO_SETUP_DEVELOPMENT_SUITE.md)

---

# Devka per repo

- Nigdy wiecej Vagranta
- Stawiamy tylko zależności danego serwisu
- Działa szybciej, nie zabija hosta

---

## Dobre dobre, ale słabe

docker-compose services:

```yaml 
apps:
    build:
        context: ./
        dockerfile: Dockerfile
    image: apps

message-relay:
    image: 682510200394.dkr.ecr.us-east-1.amazonaws.com/piwikprocloud/message-relay:dev-master

access-control-internal:
    image: 682510200394.dkr.ecr.us-east-1.amazonaws.com/piwikprocloud/access-control:1.3.0

consul-fixtures-loader:
    image: 682510200394.dkr.ecr.us-east-1.amazonaws.com/piwikprocloud/consul-fixtures-loader:0.1.0

users:
    image: 682510200394.dkr.ecr.us-east-1.amazonaws.com/piwikprocloud/users:1.9.0

license-keeper:
    image: jordimartin/mmock:v2.7.9
    
db:
    image: mariadb:10.2.26 
```

---
start.sh

```bash 
#!/bin/sh
set -e

. $(pwd)/$(dirname $0)/init.sh
. ${DOCKER_DEV_DIR}/wait-for-container.sh

if [ ${APP_ENV} = "prod" ]; then
    echo "Building production artifact"
    ( . ${DOCKER_DEV_DIR}/build-artifact.sh )
else
    echo "Running development container"
    composer install --ignore-platform-reqs --no-interaction
fi

echo "Running shared environment..."
docker network create local-dev || true

if [ ${EXTERNAL_AC:-0} -eq 1 ]; then
    export ACCESS_CONTROL_INTERNAL_API_URL=http://access-control.local-dev
else
    export ACCESS_CONTROL_INTERNAL_API_URL=http://access-control-internal
fi

docker-compose ${DC_ARGS_SHARED} up -d

echo "Running db..."
docker-compose ${DC_ARGS} up -d db
waitForContainerLogEntry "db" "ready for connections"

echo "Loading consul fixtures..."
docker-compose ${DC_ARGS} run --rm consul-fixtures-loader

echo "Running access-control, users and mocked services..."
docker-compose ${DC_ARGS} up -d access-control-internal users license-keeper
waitForContainerLogEntry "users" "php-fpm entered RUNNING state"
waitForContainerLogEntry "access-control-internal" "php-fpm entered RUNNING state"

echo "Running apps..."
docker-compose ${DC_ARGS} up --build -d ${APP_CONTAINER}
echo "Fetching events (schemas + examples)..."
./${DOCKER_DEV_DIR}/download_events.sh
waitForContainerLogEntry ${APP_CONTAINER} "php-fpm entered RUNNING state" 180

echo "Running message relay..."
docker-compose ${DC_ARGS} up --build -d message-relay

echo "Running fixtures ..."
. ${DOCKER_DEV_DIR}/fixtures.sh

echo "\nFor current (master) documentation check:"
echo "https://piwikpro-artifactory.s3.eu-central-1.amazonaws.com/long/platform/api-docs/master/index.html?path=./apps/public_v2.yaml"
```

--- 

fixtures.sh

```sh 
#!/bin/sh

echo "Adding users fixtures..."
docker-compose ${DC_ARGS} exec users su-exec devel bin/console users:add \
    --user-id=d033820f-18fc-44e9-873e-5b8846e6c984 --email=john@doe.com \
    --password=Secret123 --organization=default --role=OWNER

docker-compose ${DC_ARGS} exec users su-exec devel bin/console users:add \
    --user-id=e39e2822-91db-4d22-90eb-db301d5783b4 --email=jane@doe.com \
    --password=Secret123 --organization=default --role=USER

docker-compose ${DC_ARGS} exec users su-exec devel bin/console users:add \
    --user-id=f89c549e-0b24-43d6-9baa-aa7e0dd9b39d --email=other@org.com \
    --password=Secret123 --organization=other_org --role=OWNER


if [ ${APP_ENV} = "dev" ]; then
    echo "Adding apps & meta-sites fixtures..."
    docker-compose ${DC_ARGS} exec ${APP_CONTAINER} bin/console doctrine:fixtures:load --append
fi
```

---

# Promil!

PPAS na localhoście! O ile starczy Ci RAMu

---

## Z promilem możemy więcej!

Ale jeszcze nie teraz - teraz to:

- Zrób zmiany na lokalnej devce
- Przetestuj
- Wypchnij testowy obraz na rejestr
- Zdeployuj na promilu
- Sprawdź jak się zachowa na promilu

---

# TILT!

---

## CTK jest Tilt

> Tilt automates all the steps from a code change to a new process: watching files, building container images, and bringing your environment up-to-date.
>
> Think docker build && kubectl apply or docker-compose up.
---

# Korzyści

- Promil jest twoją devką
- Praca z dowolną ilością środowisk developerskich
- Aktualizacja plików na żywo*
- Udostępnianie usług z klastra
- Praca z lokalnym jak i zdalnym klastrem
- Spersonalizowane komendy
- Panel sterowania w przeglądarce

---

## To jak zacząć?

- Postawić promila lokalnie
- Dorzucić odpowiednią annotacje do węzła
    - [tiltthenode](https://github.com/PiwikPRO/Promil-application-middleware#bash-aliases)
- Napisać `Tiltfile` dla danego serwisu
- `Tilt up`

W razie problemów - [PKD](https://docs.tilt.dev/)

---

## CTK jest [Tiltfile](https://docs.tilt.dev/api.html)

Plik konfiguracyjny Tilta pisany w Starlarku.

## CTK jest [Starlark](https://github.com/bazelbuild/starlark/blob/master/spec.md)

Język, który jest dialektem Pythona.

Znasz pythona, nie ma problemu.

---

## Nie taki znowu przykładowy Tiltfile

```
client_dir = read_file("%s/.barman/context/infra-dir" % os.environ["HOME"])
k8s_yaml("%s/kubernetes/middleware/templates/audit-log/deployment.yaml" % client_dir)

docker_build(
    "piwikpro.azurecr.io/piwikprocloud/audit-log",
    ".",
    dockerfile="docker/Dockerfile",
    build_args={
        "CI_USER_TOKEN": os.environ["CI_USER_TOKEN"],
    },
    live_update=[
        sync("audit_log", "/home/app/app/audit_log"),
    ]
)

k8s_resource("audit-log", port_forwards="9999")
```

---

## Demonstracja na żywo!

---

## Tilt w środziemiu

[Jak postawić więcej niż jednego Tilta na raz?](https://github.com/PiwikPRO/Promil-application-middleware#development)

---

## Demonstracja na żywo!

---

## Co jest jeszcze do zrobienia

- Aktualizacja plików zależności w czasie rzeczywistym  
  package.json / requirements.txt / composer.json etc

---

# Done?

Questions?

---

# Done!

You know what?

[It is Wednesday my dudes](https://youtu.be/PAnKl7862qc)
