

# NiFi-Docker
Enhanced Apache NiFi docker image with more abilities and features then the original one

## Main goals
- Easy to create automated deployment of NiFi clusters
- Fix Bugs / add missing features to the official [NiFi Docker image](https://github.com/apache/nifi/tree/master/nifi-docker/dockerhub)
- Provide backward and forward compatibility with the official [NiFi Docker image](https://github.com/apache/nifi/tree/master/nifi-docker/dockerhub)

## Features

## Certificate generation
If all the mandatory variables are set, before startup, certificates will be requested automatically from a certificate authority
using the NiFi tls-toolkit

| Environment Variable                                  | Description                   |
|-------------------------------------------|----------------------------------------|
| **CA_SERVER**                      | Server to request certificates from                   |
| **CA_TOKEN**                 | Token to use when requesting certificates from the CA server          |
| CA_PORT           | The port to use when generating certificates with the tls toolkit, default: 8443        |

*For the image to generate certificates, **CA_SERVER** and **CA_TOKEN** must be set*
 
## Pull additional nars from git
If all the mandatory variables are set, before startup, additional nars will be requested automatically
from a git repository
*Important note: currently, this will configure NiFi to automatically treat the directory of pulled nars another lib directory, the user must
configure it itself, to avoid confusion and hidden situations*

| Environment Variable                                  | Description                   |
|-------------------------------------------|----------------------------------------|
| **NAR_GIT_REPO**        | The git repository from which to pull the additional nars      |
| **NAR_GIT_USER**    | The git user to user to pull the additional nars  |
| **NAR_GIT_TOKEN**             | The git access token to use to pull the additional nars                 |
| NAR_GIT_BRANCH                  | The git branch to pull the additional nars from, default: master                      |
| NAR_GIT_DIRECTORY  | The directory to store the pulled nars, defauls: ${NIFI_HOME}/lib2                |

*For the image to pull nars from the git repository, **NAR_GIT_REPO**, **NAR_GIT_USER** and **NAR_GIT_TOKEN** must be set*

## Building

The Docker image can be built using the following command:

```
docker build -t sierra/nifi:latest .
```
This build will result in an image tagged sierra/nifi:latest
```
# user @ machine in ~/NiFi-Docker
$ docker images
REPOSITORY               TAG                 IMAGE ID            CREATED                 SIZE
sierra/nifi             latest              f0f564eed149        A long, long time ago   1.62GB
```
## Running a container
since we strive for backwards compatibility with the official NiFi image, running a container seems very similar in a lot of cases
### Standalone Instance, Unsecured

The minimum to run a NiFi instance is as follows:

```
docker run --name nifi \
  -p 8080:8080 \
  -d \
  sierra/nifi:latest

```

This will provide a running instance, exposing the instance UI to the host system on at port 8080, viewable at  `http://localhost:8080/nifi`.

environment variables can also be passed as arguments, to change the NiFi communication ports and hostname using the Docker '-e' switch as follows:

```
docker run --name nifi \
  -p 9090:9090 \
  -d \
  -e NIFI_WEB_HTTP_PORT='9090' \
  sierra/nifi:latest

```

For a list of the environment variables recognized in this build, look into the .sh/map-properties.sh script

### Cluster, Unsecured

Clustering can be enabled by adding a few environment variables to indicate running in a cluster environment
```
docker run --name nifi-node1 -p 8080:8080 -e NIFI_CLUSTER_IS_NODE=true -e\
NIFI_CLUSTER_NODE_PROTOCOL_PORT=9000 -e NIFI_ZK_CONNECT_STRING=zookeeper:2181\
-e NIFI_ELECTION_MAX_CANDIDATES=1 -d sierra/nifi

```
of course to add another node just add more containers to connect to the same zookeeper

to enable advance clustering features the image provides a way to insert all important configuration through environment variables
  
##### nifi.properties

| Property                                  | Environment Variable                   |
|-------------------------------------------|----------------------------------------|
| nifi.cluster.is.node                      | NIFI_CLUSTER_IS_NODE                   |
| nifi.cluster.node.address                 | NIFI_CLUSTER_ADDRESS                   |
| nifi.cluster.node.protocol.port           | NIFI_CLUSTER_NODE_PROTOCOL_PORT        |
| nifi.cluster.node.protocol.threads        | NIFI_CLUSTER_NODE_PROTOCOL_THREADS     |
| nifi.cluster.node.protocol.max.threads    | NIFI_CLUSTER_NODE_PROTOCOL_MAX_THREADS |
| nifi.zookeeper.connect.string             | NIFI_ZK_CONNECT_STRING                 |
| nifi.zookeeper.root.node                  | NIFI_ZK_ROOT_NODE                      |
| nifi.cluster.flow.election.max.wait.time  | NIFI_ELECTION_MAX_WAIT                 |
| nifi.cluster.flow.election.max.candidates | NIFI_ELECTION_MAX_CANDIDATES           |

##### state-management.xml

| Property Name  | Environment Variable   |
|----------------|------------------------|
| Connect String | NIFI_ZK_CONNECT_STRING |
| Root Node      | NIFI_ZK_ROOT_NODE      |

### Standalone Instance, LDAP Secured
By default, pre-created certificate / keystore / truststore , along with all the information related to it (type,password etc..), will need to be provided when running a container of the image
an example to it running such a container:
```
docker run --name nifi-secure --hostname nifi-secure -v \
~/certs:/opt/certs -p 8443:8443 -e AUTH=ldap -e \
KEYSTORE_PATH=/opt/certs/keystore.jks -e KEYSTORE_TYPE=JKS -e \
KEYSTORE_PASSWORD=a/82bre69FXQe9EKQKMkvv8yhKnKlztZlfgULm716lQ -e \
TRUSTSTORE_PATH=/opt/certs/truststore.jks -e \
TRUSTSTORE_PASSWORD=PynvGEkUcOJeh1qB4dMFu9V9lPhACTXe5LlaOsfCI7s -e \
TRUSTSTORE_TYPE=JKS -e INITIAL_ADMIN_IDENTITY='admin' -e \
LDAP_AUTHENTICATION_STRATEGY='SIMPLE' -e \
LDAP_MANAGER_DN='cn=admin,dc=example,dc=org' -e LDAP_MANAGER_PASSWORD='admin' -e \
LDAP_USER_SEARCH_BASE='dc=example,dc=org' -e LDAP_USER_SEARCH_FILTER='cn={0}' -e \
LDAP_IDENTITY_STRATEGY='USE_USERNAME' -e LDAP_URL='ldap://ldap:389' -d \
sierra/nifi:latest
```
**note**: to make the container secure using ldap make sure to configure the **AUTH** environment variable to **ldap**.
to avoid having to create all the certificates by hand and providing it to the nodes, the **CA_SERVER** & **CA_TOKEN** (& optionally **CA_PORT**) arguments can be alternatively used. environment variables to have the container obtain the certificates / keystore / truststore from a CA server, using the *tls-toolkit*.

an example of how to run the container in this fashion.
```
docker run --name nifi-secure --hostname nifi-secure -p 8443:8443 -e AUTH=ldap -e \
CA_SERVER=ca-server -e CA_TOKEN=myverylongcatoken -e CA_PORT=443 -e \
INITIAL_ADMIN_IDENTITY='admin' -e LDAP_AUTHENTICATION_STRATEGY='SIMPLE' -e \
LDAP_MANAGER_DN='cn=admin,dc=example,dc=org' -e LDAP_MANAGER_PASSWORD='admin' -e \
LDAP_USER_SEARCH_BASE='dc=example,dc=org' -e LDAP_USER_SEARCH_FILTER='cn={0}' -e \
LDAP_IDENTITY_STRATEGY='USE_USERNAME' -e LDAP_URL='ldap://ldap:389' -e \
-d sierra/nifi:latest
```

**note**: CA_PORT is set to a default of **8443**

### Cluster, LDAP Secured
to run a secure cluster it mainly is a combination of the previous examples:
```
sudo docker run --name nifi-secure --hostname nifi-secure -p 8443:8443 -e AUTH=ldap \
-e CA_SERVER=20.186.45.162 -e CA_TOKEN=aaaaaaaaaaaaaaaa -e CA_PORT=443 -e \
INITIAL_ADMIN_IDENTITY='admin' -e LDAP_AUTHENTICATION_STRATEGY='SIMPLE' -e \
LDAP_MANAGER_DN='cn=admin,dc=example,dc=org' -e LDAP_MANAGER_PASSWORD='admin' -e \
LDAP_USER_SEARCH_BASE='dc=example,dc=org' -e LDAP_USER_SEARCH_FILTER='cn={0}' -e \
LDAP_IDENTITY_STRATEGY='USE_USERNAME' -e LDAP_URL='ldap://ldap:389' -e \
NODE_IDENTITY='CN=nifi-secure, OU=NIFI' -e NIFI_CLUSTER_IS_NODE=true -e \
NIFI_CLUSTER_NODE_PROTOCOL_PORT=9000 -e NIFI_ZK_CONNECT_STRING=zookeeper:2181 -e \
NIFI_ELECTION_MAX_CANDIDATES=1 sierra/nifi:latest
```
the only addition is the NODE_IDENTITY, which will be added as an *initial node identity*.

## Secure Cluster in a kubernetes environment
**to be written**

## Development
### updating NiFi version
the goal of the image is for upgrading NiFi version to be easy. the only thing that needs to be changed is the Dockerfile, the FROM section needs to be changed to the current apcahe/nifi image the this image will be based on.

### Handling automatically exporting NODE_IDENTITY when generating certificates
in the current NiFi version (1.11.4) there is still a "bug" where nodes with an empty flow cannot connect if they don't also have an empty / matching authorizations.xml and users.xml. this stops us from easily connecting nodes to the cluster. since authorization files will be created for them, which will prevent them from joining to the cluster. that's why we are currently not exporting the NODE_IDENTITY environment variable, which will cause the image script to generate authorizers. 
#### how to fix
we are dependent on this [JIRA Issue](https://issues.apache.org/jira/browse/NIFI-6849) to be resolved, once it is, we can uncomment the row which exports the NODE_IDENTITY environment variable in the [fetch_certificate.sh](sh/fetch_certificate.sh)

### development environment
to assist in the development and testing of the image its easy to setup a zookeeper and ldap server on a docker container.

**Note**: it's important to create a docker network for all the containers to be able to communicate between one another
```
docker create network mynet
```
#### zookeeper
pull:
```
docker pull bitnami/zookeeper
```
run:
```
docker run -p 2181:2181 --name zookeeper --hostname zookeeper -e ALLOW_ANONYMOUS_LOGIN=yes --net mynet -d bitnami/zookeeper
```
now the zookeeper running with the address of `zookeeper:2181`
#### LDAP
pull:
```
docker pull osixia/openldap
```
run:
```
docker run -p 389:389 -p 636:636 --name ldap --hostname ldap --net mynet -d osixia/openldap
```
now the ldap server running with the address of `ldap:389`, to access it using the ldap protocol: `ldap://ldap:389`

**Note**:when running the sierra/nifi image, the `--net mynet` argument needs to be used argument to allow the container to talk to the zookeeper and ldap server containers.

the [prepare.sh](utils/prepare.sh) makes it easy to re-setup the dev environment. it deletes all running containers, rebuilds the sierra/nifi image and sets up the zookeeper and ldap containers
