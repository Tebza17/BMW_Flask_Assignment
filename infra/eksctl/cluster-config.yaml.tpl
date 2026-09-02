apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: __CLUSTER_NAME__
  region: __AWS_REGION__

autoModeConfig:
  enabled: false

managedNodeGroups:
  - name: primary-ng
    instanceType: __NODE_TYPE__
    desiredCapacity: __NODE_COUNT__
    minSize: 2
    maxSize: 4

cloudWatch:
  clusterLogging:
    enableTypes: ["*"]
