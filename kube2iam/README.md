Kube2IAM
========

These manifests are required for installing the `kube2iam` system.

```
kubectl apply -f serviceaccount.yaml
kubectl apply -f clusterrole.yaml
kubectl apply -f daemonset.yaml
```

You also require the correct AWS role to have been configured for this to allow `AssumeRole` functions to work.

See: https://github.com/jtblin/kube2iam#iam-roles
