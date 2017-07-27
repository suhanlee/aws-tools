# aws-tools
aws custom tools

## deploy.rb
```bash
$ curl -sSL https://raw.githubusercontent.com/suhanlee/aws-tools/master/scripts/deploy.rb > deploy.rb
$ ruby deploy.rb ssh web
please input <app>, default is puff
please input <env>, default is staging
tag: puff-staging-web
pem: ~/.ssh/puff.pem
target: ec2-user@13.124.140.156
Last login: Thu Jul 27 17:49:36 2017 from 175.223.30.65

       __|  __|_  )
       _|  (     /   Amazon Linux AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-ami/2017.03-release-notes/
No packages needed for security; 3 packages available
Run "sudo yum update" to apply all updates.
```
