## workflow Terraform

1. Initialize

```
$ terraform init
```

2. Plan

```
$ terraform plan
```

3. Apply the plan

```
$ terraform apply
```

4. Apply the destroy

```
$ terraform destroy
```

instead of typing "yes" -> `terraform apply --auto-approve`

Why is subnetting necessary?

- Because an IP address is limited to indicating the network and the device address, IP addresses cannot be used to indicate which subnet an IP packet should go to. Routers within a network use something called a subnet mask to sort data into subnetworks.

* Terraform doesn't care where the code places:
  For example you have first

- VPC - virtual private cloud
- and then SUBNET

the place declaration of this resources doesn't care Terraform...

### HOMEWORK

1. Create vpc
2. create Internet Gateway
3. create Custom route table
4. create a subnet
5. associate subnet with Route table
6. create security Group to allow port 22, 80,443
7. create a network interface with an ip in the subnet that was created in step 4
8. assign an elastic IP to the network interface created in step 7
9. create Ubuntu server and install/enable apache 2
