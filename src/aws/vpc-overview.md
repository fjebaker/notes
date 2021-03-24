# VPC overview
VPC, or virtual private cloud, is a network controller for a configurable pool of machines. It is able to restrict and control security measures for the whole network, individual submasks, as well as individual machines.

<!--BEGIN TOC-->
## Table of Contents
1. [Components and uses](#toc-sub-tag-0)
	1. [ACL](#toc-sub-tag-1)
	2. [Security groups](#toc-sub-tag-2)
	3. [Internet gateway](#toc-sub-tag-3)
	4. [NAT](#toc-sub-tag-4)
	5. [Route tables](#toc-sub-tag-5)
2. [Working with EC2s](#toc-sub-tag-6)
<!--END TOC-->

## Components and uses <a name="toc-sub-tag-0"></a>

### ACL <a name="toc-sub-tag-1"></a>
The access control list (ACL) is essentially just a firewall, in the sense that you can configure a series of input and output rules to navigate traffic. It is a very coarse system, dealing mainly with submask accesses.

### Security groups <a name="toc-sub-tag-2"></a>
Security groups are fine tuned for each machine behind the ACL, able to expose and configure access for individual ports and IP addresses. It is a binary firewall, in the sense that it can either ACCEPT or DROP requests. For specialized use, such as allowing existing connections to still work, it may still be useful to use `iptables` on the machine.

### Internet gateway <a name="toc-sub-tag-3"></a>
The internet gateway is the route of access from the VPC into the public domain. It is essentially the bottleneck, and provides public domain or an ip address where the VPC is accessible.

### NAT <a name="toc-sub-tag-4"></a>
The network address table (NAT) maps internal addresses to external addresses, so that addresses do not have to be reconfigured if the gateway is reconfigured.

### Route tables <a name="toc-sub-tag-5"></a>
Route tables allow the configuration of the different protocol routes for the whole of the VPC; for both individual IP addresses and submasks.

## Working with EC2s <a name="toc-sub-tag-6"></a>
When creating EC2 instances, they are 'hidden' behind a VPC, and have a security group assigned. AWS provides options in the security groups for only allowing your IP address to access certain services, such as SSH ports.
