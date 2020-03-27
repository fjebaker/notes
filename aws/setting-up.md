# AWS Settup

### Creating users and managing groups
Under services, navigate to IAM. Then from that console can create new user, give them a username/password, and manage permissions through different groups.

Can create custom group policies.
NB: Must add policy for dev area, e.g. S3 must be specifically selected.

For tags, always add a name tag. They are completely optional, but adding a name as a default will always show up in management consoles and bills.

Accesses once accounts have been created; access key ID is unique to an account, and permits logins. Identifies them on AWS.

Secret access key is only 'known' to the specific user.

Can either email invites, or distribute the keys.

Instruct user to set up a signed MFA device.

### S3
Creating a bit bucket. Some regions are more feature complete than others (something to bear in mind when selecting location).

Creating a new bit bucket, under properties, can change bucket to host static website. Under permissions, allows control of different users / groups / everyone -- list access provides user the ability to render the webpage.

### AWS CLI
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