# ami-jenkins

## CSYE7125: Advanced Cloud Computing

<br>
<strong>Milestone:</strong> Assignment 01 <br>
<strong>Developer:</strong> SaiMahith Chigurupati <br>
<strong>NUID:</strong> 002700539 <br>
<strong>Email:</strong> chigurupati.sa@northeastern.edu <br>
<br>

## Instruction to run the project

```
// initialize packer
packer init jenkins-ami.pkr.hcl

// format the packer file
packer fmt jenkins-ami.pkr.hcl

// validate the hcl file
packer validate jenkins-ami.pkr.hcl

// run the packer to create AMI
packer build jenkins-ami.pkr.hcl

// flags
--var-file=variables.pkrvars.hcl

```
