# Higeco - E-Controller connector
#### _The Industry 4.0 E-Power integration_
\
![MarineGEO circle logo](https://widget.energia-europa.com/logo.jpg "MarineGEO logo")
\
Powered by Energia Euorpa S.p.A.

## Getting Started

With these instructions you will be able to setting up your system to run a container on your server. See deployment's notes to deploy the project on a live system.

### Prerequisites

To perform a login on the direct host of the e-controller you need the correct credentials given by Energia Europa.
Setup your network to allow request HTTP/HTTPS forward all e-controller you wont.

### Installing

I recommend using [Docker](https://www.docker.com/) to run the script as the container is updated according to the machine versions.
The container do not require any specified configuration because the software works like a HTTP web middleware

## Docker cli

```
docker run -dit --restart always -ubyte/higeco-gwc-connector:latest
```

## Features

- Export instant data from e-controller in JSON format
- Send configuration commend to device through API Rest

> Most of the interactive commands can be obtained using the remote management service from the cloud [NOW](https://now.energia-europa.com/) portal

A single instance can be used to manage multiple e-controllers.
Some configuration parameters are required in the [HTTP query string](https://en.wikipedia.org/wiki/Query_string) request that you will perform.

| key | value |
| ------ | ------ |
| host | Indicates the destination IP address on which the connector will perform requests |
| port | The destination port where the e-controller exposes its HTTP/HTTPS service. Usually 8001 |
| protocol | The protocol that the connector will use to make the request |

## Request using basic http authentication

The [HTTP Basic Authentication](https://en.wikipedia.org/wiki/Basic_access_authentication) header is required to perform the request to e-controller.
How to set the header to perform requests:

| key | value |
| ------ | ------ |
| Authorization | Basic <base64 username:password> |

```
curl --user name:password http://my.middleware.instance.lan/get?host=<e-controller-ip>&port=<e-controller-port>&protocol=<e-controller-protocol>
```

OR

Eexplicitly indicate the Authentication Header

```
curl -H "authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=" http://my.middleware.instance.lan/get?host=<e-controller-ip>&port=<e-controller-port>&protocol=<e-controller-protocol>
```

## Read data

Below there is an example of data download from a remote e-controller http://192.168.80.100:8001/

### Success - HTTP 200

Sometimes it could happen that the data that are displayed aren't configured by [Energia Europa S.p.A.](https://www.energia-europa.com/en/) on the e-controller as required by the customer.
In this case, the omitted values take the value zero.

```
curl -H "authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=" http://192.168.180.180:8078/get?host=192.168.80.100&port=8001&protocol=http
```

```
{
   "status":true,
   "data":[
      {
         "id":1999812100,
         "name":"Theshold",
         "um":"V",
         "utc":1642433899,
         "value":214
      },
      {
         "id":1999812101,
         "name":"Level",
         "um":"",
         "utc":1642433899,
         "value":0
      },
      {
         "id":1999812117,
         "name":"Active energy",
         "um":"kWh",
         "utc":1642433899,
         "value":551164.3
      }
   ]
}
```

### Warning - HTTP 200

To semplify integration by external software houses, the middlware responds with a description that helps the programmer during the troubleshoot.
As you can see from the example below, you can easily understand when a problem occurs and where it is localized.
In this case, the system returns "status:false"

```
curl -H "authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=" http://192.168.180.180:8078/get?host=192.168.80.100
```

```
{
   "status":false,
   "notice":"Not logged user",
   "errors":[
      {
         "name":"PROTOCOL",
         "required":true,
         "notice":"querystring: Specifies the destination protocol http or https"
      },
      {
         "name":"PORT",
         "required":true,
         "notice":"querystring: Specifies the destination port"
      }
   ]
}
```

## Set configuration

This software allows you to set specific configurations that are often required by our regular customers

### Set Threshold

Below there is an example of how setting up the configuration threshold on a remote e-controller http://192.168.80.100:8001/

```
curl -H "authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=" -X POST --data '216.4' http://192.168.180.180:8078/set/threshold?host=192.168.80.100&port=8001&protocol=http
```

The middleware will do a quick check to verify that the data being sent is a number.
Strings cannot be configured using this system

```
{"status": true}
```
### Set Bypass or Saving

Below there is an example of how execute a bypass command on a remote e-controller http://192.168.80.100:8001/

| value | description |
| ------ | ------ |
| 0 | Send command to perform saving command |
| 1 | Send command to perform bypass command |

```
curl -H "authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=" -X POST --data '1' http://192.168.180.180:8078/set/bypass?host=192.168.80.100&port=8001&protocol=http
```

The middleware will do a quick check to verify that the data being sent is a number.
Strings cannot be configured using this system

```
{"status": true}
```

## Built With

* [Docker](https://www.docker.com/) - Get Started with Docker
* [Alpine Linux](https://alpinelinux.org/) - Alpine Linux
* [Nginx](https://www.nginx.com/) - Nginx
* [JQ](https://stedolan.github.io/jq/) - JQ
* [cURL](https://curl.se/) - cURL

## Contributing

Please read [CONTRIBUTING.md](https://github.com/energia-source/higeco-gwc-connector/blob/main/CONTRIBUTING.md) for details on our code of conduct, and the process for submitting us pull requests.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/energia-source/higeco-gwc-connector/tags). 

## Authors

* **Paolo Fabris** - *Initial work* - [energia-europa.com](https://www.energia-europa.com/)

See also the list of [contributors](https://github.com/energia-source/higeco-gwc-connector/blob/main/CONTRIBUTORS.md) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details