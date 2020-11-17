# Docker Swarm

## Getting started

Docker swarm has the notion of `managers` and `workers`; nodes in the swarm cluster can be either, or both. The manager is used to delegate tasks and deploy services, whereas the workers will only do the work.

To create a swarm, use the command
```bash
docker swarm init
```
on the machine destined to be a manager. In the output of this command will be the `join` command, which should be executed on the `worker` nodes.

You can list the nodes and their status from the `manager` with
```bash
docker node ls
```

For more information on operating and maintaining swarms, [see this section of the documentation](https://docs.docker.com/engine/swarm/admin_guide/).

### Scaling a service
[docker docs](https://docs.docker.com/engine/swarm/swarm-tutorial/scale-service/)

## Private registry (no TLS)
For more information, see [the docker docs](https://docs.docker.com/registry/deploying/).

Deploy a registry as a service on a docker swarm with:
```bash
docker service create -p 5000:5000 -d --name registry registry:2
```
If deploying with OpenFaas, or similar, you may need to provide a network flag. In the case of OpenFaas, this is commonly
```bash
--network func_functions
```

Add the registry to your docker daemon configuration file with:
```
"insecure-registries":["192.168.1.150:5000"]
```

The configuration file is located either in
- Linux: `/etc/docker/daemon.json`
- OSX: `~/.docker/daemon.json`


You may have to create this file. You can also access it through the docker dashboard, under the preferences section. After adding the registry, you must reload docker
- Linux

```bash
sudo service docker reload
```
- OSX

Use the docker icon in the application try to restart.


### Pushing an image to a private registry
First, tag the image then push:
```bash
docker tag [image:tag] [registry]/[name:tag] && \
  docker push [registry]/[name:tag]
```

## OpenFaas (no TLS)
Link to [OpenFaas GitHub repositry](https://github.com/openfaas/faas).


To install and spawn OpenFaas, on a `manager` node use
```bash
git clone https://github.com/openfaas/faas && \
  cd faas && \
  ./deploy_stack.sh
```
OpenFaas, by default, will spawn a UI on port `:8080`, and will print out the login details during the above command (keep note, unless you change them).


You can install the [OpenFaas CLI](https://github.com/openfaas/faas-cli) with either
```bash
curl -sSL https://cli.openfaas.com | sh
```
or on OSX:
```bash
brew install faas-cli
```

To prevent having to constantly supply the `--gateway` flag, we can set the environment variable
```bash
export OPENFAAS_URL=http://192.168.1.150:8080
```


The general approach with OpenFaas will be to create a function template using
```bash
faas-cli new hello-world --lang=python --prefix=192.168.1.150:5000
```
wherein you develop your function. Then we build and upload it to the repository:
```bash
faas-cli build -f hello-world.yml
```
and
```bash
faas-cli push -f hello-world.yml
```

Note that you can avoid having to supply `-f *.yml` by renaming the configuration file to `stack.yml`.

You can check the image is in the registry with
```bash
curl 192.168.1.150:5000/v2/hello-python/tags/list
```

Now we deploy the function
```bash
faas-cli deploy -f hello-world.yml
```

And invoke it with either
```bash
curl -X GET localhost:8080/function/hello-python
```
or using the `invoke` command of `faas-cli`.


### Viewing usage in Prometheus
For example, to see the invocation total, adapt the link for your OpenFaas URL:
```
http://192.168.1.150:9090/graph?g0.range_input=2h&g0.stacked=1&g0.expr=rate(gateway_function_invocation_total%5B20s%5D)&g0.tab=0&g1.range_input=12h&g1.expr=gateway_service_count&g1.tab=0
```
