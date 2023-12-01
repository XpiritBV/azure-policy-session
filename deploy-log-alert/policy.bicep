targetScope = 'subscription'

resource policy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: 'deploy-keyvault-availability-alert'
  properties: {
    displayName: 'Deploy KeyVault Availability Alert'
    description: 'DeployIfNotExists to audit/deploy KeyVault Availability Alert'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Custom'
      source: 'Bicep'
      version: '0.1.0'
    }
    parameters: {
      severity: {
        type: 'String'
        metadata: {
          displayName: 'Severity'
          description: 'Severity of the Alert'
        }
        allowedValues: [ '0', '1', '2', '3', '4' ]
        defaultValue: '1'
      }
      windowSize: {
        type: 'String'
        metadata: {
          displayName: 'Window Size'
          description: 'Window size for the alert'
        }
        allowedValues: [
          'PT1M'
          'PT5M'
          'PT15M'
          'PT30M'
          'PT1H'
          'PT6H'
          'PT12H'
          'P1D'
        ]
        defaultValue: 'PT5M'
      }
      evaluationFrequency: {
        type: 'String'
        metadata: {
          displayName: 'Evaluation Frequency'
          description: 'Evaluation frequency for the alert'
        }
        allowedValues: [ 'PT1M', 'PT5M', 'PT15M', 'PT30M', 'PT1H' ]
        defaultValue: 'PT1M'
      }
      autoMitigate: {
        type: 'String'
        metadata: {
          displayName: 'Auto Mitigate'
          description: 'Auto Mitigate for the alert'
        }
        allowedValues: [ 'true', 'false' ]
        defaultValue: 'true'
      }
      enabled: {
        type: 'String'
        metadata: {
          displayName: 'Alert State'
          description: 'Alert state for the alert'
        }
        allowedValues: [ 'true', 'false' ]
        defaultValue: 'true'
      }
      threshold: {
        type: 'String'
        metadata: {
          displayName: 'Threshold'
          description: 'Threshold for the alert'
        }
        defaultValue: '90'
      }
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Effect of the policy'
        }
        allowedValues: [ 'deployIfNotExists', 'disabled' ]
        defaultValue: 'deployIfNotExists'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'microsoft.keyvault/vaults'
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          type: 'Microsoft.Insights/metricAlerts'
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Insights/metricAlerts/criteria.Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria.allOf[*].metricNamespace'
                equals: 'microsoft.keyvault/vaults'
              }
              {
                field: 'Microsoft.Insights/metricAlerts/criteria.Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria.allOf[*].metricName'
                equals: 'Availability'
              }
              {
                field: 'Microsoft.Insights/metricalerts/scopes[*]'
                equals: '[concat(subscription().id, \'/resourceGroups/\', resourceGroup().name, \'/providers/microsoft.keyvault/vaults/\', field(\'fullName\'))]'
              }
              {
                field: 'Microsoft.Insights/metricAlerts/enabled'
                equals: '[parameters(\'enabled\')]'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  resourceName: {
                    type: 'String'
                    metadata: {
                      displayName: 'resourceName'
                      description: 'Name of the resource'
                    }
                  }
                  resourceId: {
                    type: 'String'
                    metadata: {
                      displayName: 'resourceId'
                      description: 'Resource ID of the resource emitting the metric that will be used for the comparison'
                    }
                  }
                  severity: {
                    type: 'String'
                  }
                  windowSize: {
                    type: 'String'
                  }
                  evaluationFrequency: {
                    type: 'String'
                  }
                  autoMitigate: {
                    type: 'String'
                  }
                  enabled: {
                    type: 'String'
                  }
                  threshold: {
                    type: 'String'
                  }
                }
                variables: {}
                resources: [
                  {
                    type: 'Microsoft.Insights/metricAlerts'
                    apiVersion: '2018-03-01'
                    name: '[concat(parameters(\'resourceName\') \'-Availability\')]'
                    location: 'global'
                    properties: {
                      description: 'Metric Alert for KeyVault Availability'
                      severity: '[parameters(\'severity\')]'
                      enabled: '[parameters(\'enabled\')]'
                      scopes: '[[parameters(\'resourceId\')]]'
                      evaluationFrequency: '[parameters(\'evaluationFrequency\')]'
                      windowSize: '[parameters(\'windowSize\')]'
                      criteria: {
                        allOf: [
                          {
                            name: 'Availability'
                            metricNamespace: 'microsoft.keyvault/vaults'
                            metricName: 'Availability'
                            operator: 'LessThan'
                            threshold: '[parameters(\'threshold\')]'
                            timeAggregation: 'Average'
                            criterionType: 'StaticThresholdCriterion'
                          }
                        ]
                        'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
                      }
                      autoMitigate: '[parameters(\'autoMitigate\')]'
                      parameters: {
                        severity: {
                          value: ' parameters(\'severity\')]'
                        }
                        windowSize: {
                          value: '[parameters(\'windowSize\')]'
                        }
                        evaluationFrequency: {
                          value: '[parameters(\'evaluationFrequency\')]'
                        }
                        autoMitigate: {
                          value: '[parameters(\'autoMitigate\')]'
                        }
                        enabled: {
                          value: '[parameters(\'enabled\')]'
                        }
                        threshold: {
                          value: '[parameters(\'threshold\')]'
                        }
                      }
                    }
                  }
                ]
              }
              parameters: {
                resourceName: {
                  value: '[field(\'name\')]'
                }
                resourceId: {
                  value: '[field(\'id\')]'
                }
                severity: {
                  value: '[parameters(\'severity\')]'
                }
                windowSize: {
                  value: '[parameters(\'windowSize\')]'
                }
                evaluationFrequency: {
                  value: '[parameters(\'evaluationFrequency\')]'
                }
                autoMitigate: {
                  value: '[parameters(\'autoMitigate\')]'
                }
                enabled: {
                  value: '[parameters(\'enabled\')]'
                }
                threshold: {
                  value: '[parameters(\'threshold\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}

output id string = policy.id
output name string = policy.name
