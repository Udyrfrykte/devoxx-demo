auth=$(echo "gitlab-ci-token:$CI_JOB_TOKEN" | openssl base64 -e | tr -d '\n')
cat > creds.json <<EOF
{"$CI_REGISTRY":{"username":"gitlab-ci-token","password":"$CI_JOB_TOKEN","email":"gitlab@octo.com","auth":"$auth"}}
EOF
cat > conf-redis.yaml <<EOF
---
apiVersion: v1
kind: Service
metadata:
  labels:
    name: sentinel
    app: __CI_ENVIRONMENT_SLUG__-redis-sentinel
    environment: __CI_ENVIRONMENT_SLUG__
  name: __CI_ENVIRONMENT_SLUG__-redis-sentinel
spec:
  ports:
    - port: 26379
      targetPort: 26379
  selector:
    app: __CI_ENVIRONMENT_SLUG__-redis-sentinel

---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: __CI_ENVIRONMENT_SLUG__-redis-sentinel
  labels:
    app: __CI_ENVIRONMENT_SLUG__-redis-sentinel
    environment: __CI_ENVIRONMENT_SLUG__
spec:
  replicas: 1
  selector:
    matchLabels:
      app: __CI_ENVIRONMENT_SLUG__-redis-sentinel
  template:
    metadata:
      labels:
        app: __CI_ENVIRONMENT_SLUG__-redis-sentinel
        environment: __CI_ENVIRONMENT_SLUG__
      name: __CI_ENVIRONMENT_SLUG__-redis
    spec:
      containers:
        - name: master
          image: gcr.io/google_containers/redis:v1
          env:
            - name: MASTER
              value: "true"
          ports:
            - containerPort: 6379
          resources:
            limits:
              cpu: "0.1"
          volumeMounts:
            - mountPath: /redis-master-data
              name: data
        - name: sentinel
          image: kubernetes/redis:v1
          env:
            - name: SENTINEL
              value: "true"
          ports:
            - containerPort: 26379
      volumes:
        - name: data
          emptyDir: {}
EOF

cat > conf.yaml <<EOF
---
apiVersion: v1
data:
  .dockercfg: $(cat creds.json | openssl base64 -e | tr -d '\n')
kind: Secret
metadata:
  name: __CI_ENVIRONMENT_SLUG__-myregistrykey
  labels:
    app: __CI_ENVIRONMENT_SLUG__
    environment: __CI_ENVIRONMENT_SLUG__
type: kubernetes.io/dockercfg

---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: __CI_ENVIRONMENT_SLUG__
  labels:
    app: __CI_ENVIRONMENT_SLUG__
    environment: __CI_ENVIRONMENT_SLUG__
spec:
  rules:
  - host: __CI_ENVIRONMENT_SLUG__.k8s.bogops.io
    http:
      paths:
      - path: /
        backend:
          serviceName: __CI_ENVIRONMENT_SLUG__
          servicePort: 8080

---
apiVersion: v1
kind: Service
metadata:
  name: __CI_ENVIRONMENT_SLUG__
  labels:
    app: __CI_ENVIRONMENT_SLUG__
    environment: __CI_ENVIRONMENT_SLUG__
spec:
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app: __CI_ENVIRONMENT_SLUG__
  sessionAffinity: None
  type: NodePort

---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: __CI_ENVIRONMENT_SLUG__
  labels:
    app: __CI_ENVIRONMENT_SLUG__
    environment: __CI_ENVIRONMENT_SLUG__
spec:
  replicas: 2
  selector:
    matchLabels:
      app: __CI_ENVIRONMENT_SLUG__
  template:
    metadata:
      labels:
        app: __CI_ENVIRONMENT_SLUG__
        environment: __CI_ENVIRONMENT_SLUG__
      annotations:
        "prometheus.io/scrape": "true"
    spec:
      containers:
      - image: __IMAGE_URL__
        env:
        - name: REDIS_SENTINEL_ADDR
          value: "__CI_ENVIRONMENT_SLUG__-redis-sentinel:26379"
        name: __CI_ENVIRONMENT_SLUG__
        resources:
          requests:
            cpu: 20m
        ports:
        - containerPort: 8080
          protocol: TCP
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 3
          timeoutSeconds: 3
          periodSeconds: 30
          successThreshold: 1
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /healthz
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 3
          periodSeconds: 5
      terminationGracePeriodSeconds: 3
      imagePullSecrets:
      - name: __CI_ENVIRONMENT_SLUG__-myregistrykey
EOF

sed -e "s/__CI_ENVIRONMENT_SLUG__/metrics-app-dev-$CI_COMMIT_REF_NAME/" -e "s!__IMAGE_URL__!$CONTAINER_COMMIT_IMAGE!" conf.yaml > conf-ok.yaml
sed -e "s/__CI_ENVIRONMENT_SLUG__/metrics-app-dev-$CI_COMMIT_REF_NAME/" -e "s!__IMAGE_URL__!$CONTAINER_COMMIT_IMAGE!" conf-redis.yaml > conf-redis-ok.yaml
kubectl apply -f conf-redis-ok.yaml
sleep 3
kubectl apply -f conf-ok.yaml
sleep 3
