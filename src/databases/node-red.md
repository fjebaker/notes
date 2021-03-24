# NodeRed Notes
Maybe the coolest tool I've been introduced to. Since the usage is fairly self explanatory, I will just document tips, tricks, and recipes.

## NodeRed with Docker
There are a multitude of guides available, including the [Official NodeRed](https://nodered.org/docs/getting-started/docker) getting started guide. In short, to get a simple docker container running with NodeRed, execute
```bash
docker pull nodered/node-red
```
to pull the [latest image](https://hub.docker.com/r/nodered/node-red/), and

```bash
docker run -it -p 1880:1880 -v ~/nodered:/data --name noddy nodered/node-red
```
to start the container. Optionally with `-d` to detach, or use the `Ctrl-P`, `Ctrl-Q` on the attached container to lower into a daemon. Connect to port `1880` with your web browser to get started.

The volume we attach in the above command allows for container persistence. 

## Useful guides
Creating custom nodes [here](https://nodered.org/docs/creating-nodes/first-node).

On messages [here](https://nodered.org/docs/user-guide/messages).
