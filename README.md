
# NiFi-Docker
Enhanced Apache NiFi docker image with more abilities and features then the original one

## Main goals
- Easy to create automated deployment of NiFi clusters
- Fix Bugs / add missing features to the official [NiFi Docker image](https://github.com/apache/nifi/tree/master/nifi-docker/dockerhub)
- Provide backward and forward compatibility with the official [NiFi Docker image](https://github.com/apache/nifi/tree/master/nifi-docker/dockerhub)

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

You can also pass in environment variables to change the NiFi communication ports and hostname using the Docker '-e' switch as follows:

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
By default, you will need to provide the container a pre-created certificate / keystore / truststore along with all the information related to it (type,password etc..)/
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
to avoid having to create all the certificates by hand and providing it to the nodes, you can alternatively use the **CA_SERVER** & **CA_TOKEN** (& optionally **CA_PORT**) environment variables to have the container obtain the certificates / keystore / truststore from a CA server, using the *tls-toolkit*.

you can run a container in this fashion like this:
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
**to be written**
