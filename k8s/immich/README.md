# Народный аналог Google Photos

[Chart](https://github.com/immich-app/immich-charts/tree/main)

```sh
kubectl create namespace immich
# kubectl get secret -n immich immich-postgres-superuser-secret -o json | jq -r .data.password | basenc --base64 -d | xargs
# kubectl get secret -n immich immich-postgres-user-secret -o json | jq -r .data.password | basenc --base64 -d | xargs
kubectl create secret generic immich-postgres-user-secret  \
    -n immich \
    --type=kubernetes.io/basic-auth \
    --from-literal='username=immich' \
    --from-literal="password=$(head -c 24 /dev/urandom | basenc --base64url)"
# kubectl get pvc -n immich
kubectl apply -f library-pvc.yaml
# kubectl get database -n immich
kubectl apply -f postgres.yaml -f postgres-database.yaml
# kubectl get pods -n immich -w
helm install -n immich -f values.yaml immich oci://ghcr.io/immich-app/immich-charts/immich
# kubectl delete cluster -n immich immich-postgres
# kubectl delete database -n immich immich-database
# helm uninstall -n immich immich
# kubectl delete pod --all -n immich
```

