# AWS Settup

<!--BEGIN TOC-->
## Table of Contents
1. [Creating users and managing groups](#toc-sub-tag-0)
2. [S3](#toc-sub-tag-1)
3. [AWS CLI](#toc-sub-tag-2)
<!--END TOC-->

### Creating users and managing groups <a name="toc-sub-tag-0"></a>
Under services, navigate to IAM. Then from that console can create new user, give them a username/password, and manage permissions through different groups.

Can create custom group policies.
NB: Must add policy for dev area, e.g. S3 must be specifically selected.

For tags, always add a name tag. They are completely optional, but adding a name as a default will always show up in management consoles and bills.

Accesses once accounts have been created; access key ID is unique to an account, and permits logins. Identifies them on AWS.

Secret access key is only 'known' to the specific user.

Can either email invites, or distribute the keys.

Instruct user to set up a signed MFA device.

### S3 <a name="toc-sub-tag-1"></a>
Creating a bit bucket. Some regions are more feature complete than others (something to bear in mind when selecting location).

Creating a new bit bucket, under properties, can change bucket to host static website. Under permissions, allows control of different users / groups / everyone -- list access provides user the ability to render the webpage.

### AWS CLI <a name="toc-sub-tag-2"></a>
To begin, configure with credentials -- best to use a user `.csv` file. Simply write
```
aws configure
```
Probably best to use 
```
Default region name [None]: eu-west-1
Default output format [None]: json
```

To list, for example, the bit buckets, use
```
aws s3 ls
```