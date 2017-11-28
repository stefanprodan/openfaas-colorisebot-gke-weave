# openfaas-colorisebot-gke-weave

OpenFaaS colorisebot GKE deployment instrumented with Weave Cloud

### Setup

Prerequisites: 

* gcloud
* kubectl 
* mc
* faas-cli
* jq, awk, base64

Run `gcloud init` and set the default zone to `europe-west1-d`.

Create the GKE cluster:

```bash
./cluster-up.sh
```

Deploy OpenFaaS services, Weave Cloud agents, Caddy, Nats, Minio, Colorisebot services and functions:

```bash
basic_auth_user=<VAL> \
basic_auth_password=<VAL> \
twitter_account=<VAL> \
twitter_consumer_key=<VAL> \
twitter_consumer_secret=<VAL> \
twitter_access_token=<VAL> \
twitter_access_token_secret=<VAL> \
minio_access_key=<VAL> \
minio_secret_key=<VAL> \
weave_token=<VAL> \
./openfaas-up.sh
```

### Components

Namespace openfaas:

```bash
$ kubectl -n openfaas get deployments
  NAME            DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
  alertmanager    1         1         1            1           3h
  caddy           1         1         1            1           3h
  faas-netesd     1         1         1            1           3h
  gateway         1         1         1            1           3h
  nats            1         1         1            1           3h
  prometheus      1         1         1            1           3h
  tweetlistener   1         1         1            1           3h
```

Namespace openfaas-fn:

```bash
$ kubectl -n openfaas-fn get deployments
  NAME             DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
  colorization     4         4         4            4           3h
  mailbox          1         1         1            1           3h
  minio            1         1         1            1           3h
  normalisecolor   4         4         4            4           3h
  queue-worker     16        16        16           16          3h
  tweetpic         1         1         1            1           3h
```

