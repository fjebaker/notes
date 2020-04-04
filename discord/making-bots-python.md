# Making Discord bots in Python
Unlike webhooks, discord bots are invited into servers, and managed through a special [developer portal](https://discordapp.com/developers/applications). A link to the discord Python API reference can be found [here](https://discordpy.readthedocs.io/en/latest/api.html).

<!--BEGIN TOC-->
## Table of Contents
1. [Using the developer portal to create a bot](#toc-sub-tag-0)
	1. [Overview of the portal](#toc-sub-tag-1)
		1. [Application features](#toc-sub-tag-2)
		2. [Bot features](#toc-sub-tag-3)
	2. [Adding a bot to the server](#toc-sub-tag-4)
		1. [Generating OAuth2 URIs](#toc-sub-tag-5)
2. [Using python to handle application functionality](#toc-sub-tag-6)
	1. [Connecting to a Discord server](#toc-sub-tag-7)
	2. [Utility functions](#toc-sub-tag-8)
	3. [Responding to events](#toc-sub-tag-9)
		1. [Messages](#toc-sub-tag-10)
		2. [Direct messaging channels](#toc-sub-tag-11)
	4. [Connecting a bot](#toc-sub-tag-12)
		1. [Attaching a bot](#toc-sub-tag-13)
		2. [Bot commands](#toc-sub-tag-14)
		3. [Converting commands](#toc-sub-tag-15)
		4. [Command predicates](#toc-sub-tag-16)
<!--END TOC-->

## Using the developer portal to create a bot <a name="toc-sub-tag-0"></a>
In order to develop a bot, we need to register the correct authentication tokens on the developer portal, through OAuth2. To do this we, on the main dashboard of the portal

- select *New Application*
- give the application a name
- navigate to the *Bot* tab on the hamburger menu, and attach a bot to the application

OAuth2 protocol generates limited-access tokens based on the permissions granted to the application/bot.

### Overview of the portal <a name="toc-sub-tag-1"></a>
The following explains some of the details which may be configured in the developer portal.

#### Application features <a name="toc-sub-tag-2"></a>
TODO; what is the client ID, what is the client secret?

#### Bot features <a name="toc-sub-tag-3"></a>
Bots can be granted special OAuth2 tokens, and as many permissions as they need. It also allows you to access the **secret bot tokens** required to activate the bot remotely from a server.

TODO; what are all the setting available?


### Adding a bot to the server <a name="toc-sub-tag-4"></a>
To add our bot to the server, we require a key from the OAuth2 URI generator.

#### Generating OAuth2 URIs <a name="toc-sub-tag-5"></a>
From the hamburger menu, select OAuth2. This dashboard is a wrapper for the OAuth2 API, and manages and generates credential tokens. 

For our bot we want to add user access to the discord API; to do this, scroll down and select

- *bot* from *SCOPES*
- *Administrator* from *BOT PERMISSIONS*

**NB:** for deployment, best not to select *Administrator* but tailor your needs specifically for the bot. Discord now generates the authorization URI, with the correct scope and permissions for our development bot.

Select *Copy* and paste it into the browser in order to invite the application/bot to your server.

## Using python to handle application functionality <a name="toc-sub-tag-6"></a>
The environment requires the `discord.py` API packages
```
pip install discord.py
```
### Connecting to a Discord server <a name="toc-sub-tag-7"></a>
Require a `Client` instance to connect to the server. The client represents a connection to a given discord server; the servers the bot is currently connected to is handles by `client.guild`. The client is able to interact with the full discord API.
```python
import discord, os
TOKEN = os.getenv("DISCORD_TOKEN")	# read in the secret token

client = discord.Client()

@client.event
async def on_ready():			# once connection established
	print("{} is here lads!".format(client.user))

client.run(TOKEN)
```
We set the environment variable with the secret bot token
```bash
export DISCORD_TOKEN=bot-token
```

The client instance comes with a range of information on the connected server. For example, to print out the user list of a given server, we could use
```python
guild = [g for g in client.guilds if g.name == "YOUR SEVER NAME"]
for member in guild:
	print(member.name)
```

### Utility functions <a name="toc-sub-tag-8"></a>
The discord python API includes a `utils` module to fasciculate quality-of-life functions, such as the ability to find
```python
guild = discord.utils.find(lambda i: i.name == "YOUR SERVER NAME", client.guilds)
```

### Responding to events <a name="toc-sub-tag-9"></a>
Event triggers can be defined by either using the `client.event` decorator, or by creating a custom client class, inheriting from `discord.Client`, and overriding the appropriate methods.
Some common endpoints are
```python

class NewClient(discord.Client)
	async def on_ready(self):
		pass

	async def on_member_join(self, member):
		pass

	async def on_message(self, message):
		pass

```

#### Messages <a name="toc-sub-tag-10"></a>
The message argument given to the `on_message()` function contains the message contents and metadata, for example
```python
if message.author == client.user: 	# encase you messaged yourself
	return

if message.content == "Hey fuck you!":
	resp = "Yes! Yes! Fuck you too!"
	await message.channel.send(resp)
```

#### Direct messaging channels <a name="toc-sub-tag-11"></a>
To direct message a member, we can create a new `dm` channel, with
```python
await member.create_dm()
await member.dm_channel.send("MESSAGE")
```

### Connecting a bot <a name="toc-sub-tag-12"></a>
Subclasses of `Client` include bot, which has tailored functionality for bot interactions. This includes the whole of the commands API, which the superclass `Client` does not have access to.
#### Attaching a bot <a name="toc-sub-tag-13"></a>
Instead of using an instance of `Client`, we instead want to use an instance of `Bot`, with many of the same endpoints as client. The primary difference is that we are going to prefix the bot with a command token, e.g.
```python
from discord.ext import commands

bot = commands.Bot(command_prefix='?')
```
#### Bot commands <a name="toc-sub-tag-14"></a>
Commands, different to the event endpoints, are arbitrary. We can define a command endpoint with
```python
@bot.command(name='beer', help='Ask the bot for a beer.')
async def give_beer(context):
	resp = "nah mate it's my last one"
	await context.send(resp)
```
Given the command prefix of `?`, the bot will now respond to the input `?beer`. Similarly, using `?help` will trigger the help text to be shown.

#### Converting commands <a name="toc-sub-tag-15"></a>
Say we wanted to create a command that takes parameters as arguments, we could do so for our bot with
```python
@bot.command(name='beer', help='Ask the bot for <n> beers')
async def give_beer(context, n: int):
	await content.send(f"You want {n}? Nah mate...")
```
Python3's builtin annotations will automatically get the API to convert the argument into the type you want, and handle exceptions if the input does not match.

#### Command predicates <a name="toc-sub-tag-16"></a>
We can make sure that our commands have the correct permissions or environment in order to execute the desired task. For example, we can ensure we have admin permissions by using
```python
@bot.command(name='create-channel')
@commands.has_role('admin')
async def create_channel(context, channel_name: str):
	if not discord.utils.get(context.guild.channels, name=channel_name):	# make sure channel doesn't already exist
		await guild.create_text_channel(channel_name)
```