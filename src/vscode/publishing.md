# Publishing a VSCode extension

Most of the required information for publishing VSCode extensions can be found directly on the [Microsoft website](https://code.visualstudio.com/api/working-with-extensions/publishing-extension). Presented in these notes is an abridged version.

<!--BEGIN TOC-->
## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Packaging and publishing](#packaging-and-publishing)

<!--END TOC-->


## Prerequisites

The following are required to publish a VSCode extension

- a publisher profile, created in the [Publishers & Extensions section of the marketplace](https://marketplace.visualstudio.com/)
- a Azure Personal Access Token (PAT), available from [the developer portal](https://dev.azure.com/)

The publisher can be any identity, and will be used to publish your extension. The PAT ideally needs to be created second, so that it can be created for the specific publisher, and requires *Manage* permissions for the marketplace.

## Packaging and publishing

Assuming you have created your extension using `yo`, then a slight modification of `package.json` is required, to populate the missing `publisher` field. This field should be a string containing the identify of the publisher you wish to keep your extension under.

The tool used to package and publish is `vsce`

```bash
npm i vsce
```

We then login to the marketplace with

```bash
vsce login {identity-of-publisher}
```

which will prompt you for your PAT. Provided this was successful, you can package your extension with

```bash
vsce package
```

or publish it with

```
vsce publish
```