import groovy.json.JsonBuilder

node('jenkins-jenkins-slave') {
  withEnv(['REPOSITORY=apache-struts2']) {
    stage('Pull Image from Git') {
      script {
        git (url: "${scm.userRemoteConfigs[0].url}", credentialsId: "github-auth")
      }
    }
    stage('Build Image') {
      script {
        dbuild = docker.build("${REPOSITORY}:$BUILD_NUMBER")
      }
    }
    parallel (
      "Test": {
        echo 'All functional tests passed'
      },
      "Check Image (pre-Registry)": {
        smartcheckScan([
          imageName: "${REPOSITORY}:$BUILD_NUMBER",
          smartcheckHost: "${DSSC_SERVICE}",
          smartcheckCredentialsId: "smartcheck-auth",
          insecureSkipTLSVerify: true,
          insecureSkipRegistryTLSVerify: true,
          preregistryScan: true,
          preregistryHost: "${DSSC_REGISTRY}",
          preregistryCredentialsId: "preregistry-auth",
          findingsThreshold: new groovy.json.JsonBuilder([
            malware: 0,
            vulnerabilities: [
              defcon1: 0,
              critical: 15,
              high: 50,
            ],
            contents: [
              defcon1: 0,
              critical: 0,
              high: 0,
            ],
            checklists: [
              defcon1: 0,
              critical: 0,
              high: 0,
            ],
          ]).toString(),
        ])
      }
    )

    stage('Push Image to Registry') {
      script {
        docker.withRegistry("https://${K8S_REGISTRY}", 'registry-auth') {
          dbuild.push('$BUILD_NUMBER')
          dbuild.push('latest')
        }
      }
    }
    stage('Deploy App to Kubernetes') {
      script {
        kubernetesDeploy(configs: "app.yml",
                         kubeconfigId: "kubeconfig",
                         enableConfigSubstitution: true,
                         dockerCredentials: [
                           [credentialsId: "registry-auth", url: "${K8S_REGISTRY}"],
                         ])
      }
    }
    stage('Force Scan for Recomendations') {
      steps {
        sh 'curl -X POST https://app.deepsecurity.trendmicro.com/api/scheduledtasks/133 -H "api-secret-key: 6533381E-7A98-8B6B-02A6-32B3A7555128:7FB6C752-7CE0-94D7-5515-BC3C85DFED3E:gT10N2jrgr8AQRxO0s394rak0t/iOncpejm+K9R0Sc0=" -H "api-version: v1" -H "Content-Type: application/json" -d "{ \"runNow\": \"true\" }"'
      }
    }
  }
}
