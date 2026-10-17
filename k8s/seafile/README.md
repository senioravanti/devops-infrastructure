# Развёртывание seafile

[Инструкции](https://manual.seafile.com/14.0/setup/helm_chart_single_node/#preparation)
[Документация переменных среды](https://manual.seafile.com/14.0/config/env/#seafile-server-configurations)
[Документация HelmChart](https://haiwen.github.io/seafile-helm-chart/)

[Оператор mariadb](https://github.com/mariadb-operator/mariadb-operator)

```sh
kubectl create namespace mariadb-operator-system
helm install -n mariadb-operator-system \
    --version 26.10.1 mariadb-operator-crds \
    oci://ghcr.io/mariadb-operator/charts/mariadb-operator-crds
helm install -n mariadb-operator-system \
    --version 26.10.1 mariadb-operator \
    oci://ghcr.io/mariadb-operator/charts/mariadb-operator
helm install -n mariadb-operator-system \
    --version 26.10.1 mariadb-cluster \
    oci://ghcr.io/mariadb-operator/charts/mariadb-cluster
```

[Оператор valkey](https://valkey.io/valkey-helm/)

`helm show values valkey/valkey > values.yaml` :: Получить values.yaml helm chart.
`kubectl get svc -n seafile` :: Проверить доменные имена

```sh
curl -Lo values.yaml 'https://haiwen.github.io/seafile-helm-chart/values/latest/ce.yaml'
kubectl create namespace seafile
# NAME                               TYPE            DATA   AGE
# seafile-secret                     Opaque          6      17s
kubectl create secret generic seafile-secret -n seafile \
--from-literal=JWT_PRIVATE_KEY="$(head -c 40 /dev/urandom | basenc --base64url | tr -d '=')" \
--from-literal=SEAFILE_MYSQL_DB_PASSWORD="$(head -c 24 /dev/urandom | basenc --base64url | tr -d '=')" \
--from-literal=INIT_SEAFILE_ADMIN_PASSWORD="$(head -c 24 /dev/urandom | basenc --base64url | tr -d '=')" \
--from-literal=INIT_SEAFILE_MYSQL_ROOT_PASSWORD="$(head -c 32 /dev/urandom | basenc --base64url | tr -d '=')" \
--from-literal=REDIS_PASSWORD="$(head -c 16 /dev/urandom | basenc --base64url | tr -d '=')"

helm repo add valkey https://valkey.io/valkey-helm/
helm repo add seafile https://haiwen.github.io/seafile-helm-chart/repo
helm repo update

# helm -n seafile uninstall valkey
# kubectl get secret seafile-secret -n seafile -o json | jq -r '.data.REDIS_PASSWORD' | basenc -d --base64url | xargs | copy-osc52
# kubectl exec -it valkey -n seafile -- valkey-cli --user default --askpass
helm install valkey valkey/valkey -f valkey.yaml -n seafile

# kubectl delete -f mariadb.yaml --ignore-not-found
# kubectl exec -it mariadb-0 -n seafile -- mariadb -u seafile -p seafile_db
kubectl apply -f ./mariadb.yaml

helm install seafile seafile/ce -n seafile \
    --values values.yaml \
    --version 13.0
# helm delete seafile --namespace seafile
```

