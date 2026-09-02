apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: flask-kafka-app-prod
  namespace: argocd
spec:
  project: default
  source:
    repoURL: __REPO_URL__
    targetRevision: main
    path: helm/flask-kafka-app
    helm:
      valueFiles:
        - values-prod.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: assessment-prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
