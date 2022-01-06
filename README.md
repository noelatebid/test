# Terraform

This project uses terraform workspaces https://app.terraform.io/.

Install Terraform CLI and use for local setup.

https://learn.hashicorp.com/tutorials/terraform/install-cli

```shell script
terraform init
# terraform workspace list
# terraform workspace select prod|stage

terraform plan | apply # to make changes
```

# EKS Cluster 

## Configure kubectl

To configure kubectl, you need both [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html).

The following command will get the access credentials for your cluster and automatically
configure `kubectl`.


```shell
$ aws sts get-caller-identity # check your user. root for prod, tilt-stage role for stage
$ aws eks --region us-west-2 update-kubeconfig --name tilt-prod
$ aws eks --region us-west-2 update-kubeconfig --name tilt-stage
```

You can view these outputs again by running:

```shell
$ terraform output
```

## Connecting to clusters

Prod is on the root account.

For stage you need to switch roles, Create the following config, and append --profile tilt-stage

```
[profile tilt-stage]
role_arn = arn:aws:iam::444266008906:role/OrganizationAccountAccessRole
source_profile = default
```
 @TODO - there're some steps missing.. you can also use credentials from that env if you have

## Access Application Logs with Kubernetes

Here are some useful commands incase you need to inspect the application logs

NOTE: It's important to add the `--tail -1` option when using the `-l` option. See https://github.com/kubernetes/kubectl/issues/917 for more detail

```shell script
# First, inspect what labels are assigned to each pod
kubectl get pods -n prod --show-labels

# Get last 24 hours of logs for all containers with the label app=tilt-backend-api
kubectl logs -n prod -l app=tilt-backend-api --timestamps --all-containers --since=24h --tail -1

# Follow/tail new logs as they are digested for all containers with the label app=tilt-backend-api
kubectl logs -n prod -l app=tilt-backend-api --timestamps --all-containers --follow
```

## Deploy and access Kubernetes Dashboard

To verify that your cluster is configured correctly and running, you will install a Kubernetes dashboard and navigate to it in your local browser. 

### Deploy Kubernetes Metrics Server

The Kubernetes Metrics Server, used to gather metrics such as cluster CPU and memory usage
over time, is not deployed by default in EKS clusters.

Download and unzip the metrics server by running the following command.

```shell
helm install metrics-server stable/metrics-server \
  --namespace kube-system \
  -f metrics-server/values.yaml
```
### Deploy Kube2IAM

```shell
kubectl apply -f kube2iam/serviceaccount.yaml
kubectl apply -f kube2iam/clusterrole.yaml
kubectl apply -f kube2iam/daemonset.yaml
```

## Creating a cluster from scratch

 - Create a Terraform workspace `terraform workspace new staging`
 - Create AWS access keys, lets call it `terraform-staging`
 - Set env vars in Terraform workspace
   ```
   AWS_ACCESS_KEY_ID
   AWS_SECRET_ACCESS_KEY
   AWS_DEFAULT_REGION
   ```
 - Set variables in terraform (`environment` and `pgsql_password`) 
 - `terraform apply`

There are a few things that are not Terraformed yet so you need to consider individually:
 - Docker ECR (used in helm charts)
 - Cloudfront (we might add here)
 - DNS: the dns.tf file will update our Route53 in the prod env, but you need to manually create the CNAME pointing to the ELB.
 - On the application side, you need to configure the helm charts to set the proper values.
 - You also need to configure the CI/CD pipeline, mainly the github action credentials (which are an output of terraform)  
 - Database migration in case you want to preserve it is also manual.
   You can't access the RDS instance from outside the cluster. If you want to migrate a Prod DB, you should log in to a Prod pod so you can access the database.
   Then probably allow external connections in your new and empty target DB so you can copy data from the Prod Pod to it. 
