#!/bin/bash

set -e

docker build -t gcr.io/${PROJECT_NAME}/${DOCKER_IMAGE_NAME}:$TRAVIS_COMMIT -t gcr.io/${PROJECT_NAME}/${DOCKER_IMAGE_NAME}:latest .

echo $GCLOUD_SERVICE_KEY | base64 --decode -i > ${HOME}/gcloud-service-key.json
gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

gcloud --quiet config set project $PROJECT_NAME
gcloud --quiet config set container/cluster $CLUSTER_NAME
gcloud --quiet config set compute/zone ${CLOUDSDK_COMPUTE_ZONE}
gcloud --quiet container clusters get-credentials $CLUSTER_NAME
gcloud --quiet auth configure-docker

docker push gcr.io/${PROJECT_NAME}/${DOCKER_IMAGE_NAME}:$TRAVIS_COMMIT
docker push gcr.io/${PROJECT_NAME}/${DOCKER_IMAGE_NAME}:latest

# yes | gcloud beta container images add-tag gcr.io/${PROJECT_NAME}/${DOCKER_IMAGE_NAME}:$TRAVIS_COMMIT gcr.io/${PROJECT_NAME}/${DOCKER_IMAGE_NAME}:latest

kubectl config view
kubectl config current-context

# kubectl set image deployment/${KUBE_DEPLOYMENT_NAME} ${KUBE_DEPLOYMENT_CONTAINER_NAME}=gcr.io/${PROJECT_NAME}/${DOCKER_IMAGE_NAME}:$TRAVIS_COMMIT
envsubst < k8s.template.yml > k8s.yml

kubectl apply -f k8s.yml