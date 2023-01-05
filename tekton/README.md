# Running Tekton in a local Kubernetes Cluster

## Installing Tekton in minikube

```
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/tekton-dashboard-release.yaml
```

## Deploying the event listener and PR pipeline

```
kubectl apply -f pr-pipeline.yaml
kubectl apply -f reference-event-listener.yaml
```

This creates everything in a namespace called `reference-service-ci`

## Exposing the Tekton dashboard

```
kubectl --namespace tekton-pipelines port-forward svc/tekton-dashboard 9097:9097
```

[Tekton Dashboard](http://localhsot:9097)

## Exposing the event listener to a GitHub WebHook

To allow GitHub webhooks to connect to a local cluster.

Expose the service with port forwarding:
```
kubectl port-forward -n reference-service-ci services/el-github-listener 8080
```

Expose your local workstation e.g. with ngrok:

```
ngrok http 8080
```

In a real environment the event listener would need to be exposed via ingress or a service load balancer in GKE or EKS.

## GitHub SSH Key

Tekton requires a ssh key to checkout the repo.

This can be created as a [Deploy Key](https://docs.github.com/en/developers/overview/managing-deploy-keys)
on the repo.

Put the private key and known hosts file into a secret called `git-auth` e.g.

```
apiVersion: v1
kind: Secret
metadata:
  name: git-credentials
  namespace: reference-service-ci
data:
  id_ed25519: LS0ta...
  known_hosts: Z2l0aHViLmNvbSwxNDAuODIuMTIxLjMgc3NoLXJzYSBBQUFBQjNOemFDMXljMkVBQUFBQkl3QUFBUUVBcTJBN2hSR21kbm05dFVEYk85SURTd0JLNlRiUWErUFhZUENQeTZyYlRyVHR3N1BIa2NjS3JwcDB5VmhwNUhkRUljS3I2cExsVkRCZk9MWDlRVXN5Q09WMHd6ZmpJSk5sR0VZc2RsTEppekhoYm4ybVVqdlNBSFFxWkVUWVA4MWVGekxRTm5QSHQ0RVZWVWg3VmZERVNVODRLZXptRDVRbFdwWExtdlUzMS95TWYrU2U4eGhIVHZLU0NaSUZJbVd3b0c2bWJVb1dmOW56cElvYVNqQit3ZXFxVVVtcGFhYXNYVmFsNzJKK1VYMkIrMlJQVzNSY1QwZU96UWdxbEpMM1JLclRKdmRzakUzSkVBdkdxM2xHSFNaWHkyOEczc2t1YTJTbVZpL3c0eUNFNmdiT0RxblRXbGc3K3dDNjA0eWRHWEE4VkppUzVhcDQzSlhpVUZGQWFRPT0KMTQwLjgyLjEyMS40IHNzaC1yc2EgQUFBQUIzTnphQzF5YzJFQUFBQUJJd0FBQVFFQXEyQTdoUkdtZG5tOXRVRGJPOUlEU3dCSzZUYlFhK1BYWVBDUHk2cmJUclR0dzdQSGtjY0tycHAweVZocDVIZEVJY0tyNnBMbFZEQmZPTFg5UVVzeUNPVjB3emZqSUpObEdFWXNkbExKaXpIaGJuMm1VanZTQUhRcVpFVFlQODFlRnpMUU5uUEh0NEVWVlVoN1ZmREVTVTg0S2V6bUQ1UWxXcFhMbXZVMzEveU1mK1NlOHhoSFR2S1NDWklGSW1Xd29HNm1iVW9XZjluenBJb2FTakIrd2VxcVVVbXBhYWFzWFZhbDcySitVWDJCKzJSUFczUmNUMGVPelFncWxKTDNSS3JUSnZkc2pFM0pFQXZHcTNsR0hTWlh5MjhHM3NrdWEyU21WaS93NHlDRTZnYk9EcW5UV2xnNyt3QzYwNHlkR1hBOFZKaVM1YXA0M0pYaVVGRkFhUT09Cg==
```

You can use the existing known hosts base64 which includes the GitHub IPs.

For the id_ed25519 field create a key with, full instructions [here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key):

```
 ssh-keygen -t ed25519 -C "deploy@bootcamp"
```

Add it as the Deploy Key, and take the contents of the private key with ` cat id_ed25519 | base64`

## Creating a web hook

For GitHub to call out to Tekton for CI we need a webhook.

Go to your fork -> Settings -> Webhook -> Add WebHook

URL: should be the ngrok URL. This expires every 2 hours unless you have an account so this will need updating.
Content Type: application/json
Secret: 1234567 (match up with the secret in `reference-event-listener.yaml`)

In a real scenario the secret could be from a system like Vault and the event listener would have some firewall rules
to only accept connections from the GitHub IPs.

## Testing it out!

Open a PR on your fork. That shoudl trigger the webhook and a pipeline run in Tekton.

