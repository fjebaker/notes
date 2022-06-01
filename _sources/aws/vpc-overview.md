# VPC overview

VPC, or virtual private cloud, is a network controller for a configurable pool of machines. It is able to restrict and control security measures for the whole network, individual submasks, as well as individual machines.

<!--BEGIN TOC-->
## Table of Contents
1. [Components and uses](#components-and-uses)
    1. [ACL](#acl)
    2. [Security groups](#security-groups)
    3. [Internet gateway](#internet-gateway)
    4. [NAT](#nat)
    5. [Route tables](#route-tables)
2. [Working with EC2s](#working-with-ec2s)

<!--END TOC-->

## Components and uses

### ACL
The access control list (ACL) is essentially just a firewall, in the sense that you can configure a series of input and output rules to navigate traffic. It is a very coarse system, dealing mainly with submask accesses.

### Security groups
Security groups are fine tuned for each machine behind the ACL, able to expose and configure access for individual ports and IP addresses. It is a binary firewall, in the sense that it can either ACCEPT or DROP requests. For specialized use, such as allowing existing connections to still work, it may still be useful to use `iptables` on the machine.

### Internet gateway
The internet gateway is the route of access from the VPC into the public domain. It is essentially the bottleneck, and provides public domain or an ip address where the VPC is accessible.

### NAT
The network address table (NAT) maps internal addresses to external addresses, so that addresses do not have to be reconfigured if the gateway is reconfigured.

### Route tables
Route tables allow the configuration of the different protocol routes for the whole of the VPC; for both individual IP addresses and submasks.

## Working with EC2s
When creating EC2 instances, they are 'hidden' behind a VPC, and have a security group assigned. AWS provides options in the security groups for only allowing your IP address to access certain services, such as SSH ports.
