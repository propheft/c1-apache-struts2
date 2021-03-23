import groovy.json.JsonBuilder

node {
  withEnv(['REPOSITORY=c1-apache-struts2']) {
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
              critical: 30,
              high: 100,
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
        docker.withRegistry("https://${K8S_REGISTRY}", 'ecr:eu-west-1:registry-auth') {
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
                           [credentialsId: "ecr:eu-west-1:registry-auth", url: "${K8S_REGISTRY}"],
                         ])
      }
    }
    stage('DS Scan for Recommendations') {
      withCredentials([string(credentialsId: 'deepsecurity-key', variable: 'DSKEY')]) {
        sh 'curl -X POST https://app.deepsecurity.trendmicro.com/api/scheduledtasks/133 -H "api-secret-key: ${DSKEY}" -H "api-version: v1" -H "Content-Type: application/json" -d "{ \\"runNow\\": \\"true\\" }" '
      }     
    }
  }
}
