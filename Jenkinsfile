#!groovy
import groovy.json.JsonSlurperClassic
node {
    def BUILD_NUMBER = env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR = "tests/${BUILD_NUMBER}"
    def SFDC_USERNAME
    def HUB_ORG = 'jenkins.user@macgregor.com.jeninscli'
    def SFDC_HOST = 'https://test.salesforce.com'
    def JWT_KEY_CRED_ID = 'ed955a55-32e5-418d-b7f6-7351b80ab6a3'
    def CONNECTED_APP_CONSUMER_KEY = '3MVG9LzKxa43zqdJK6JA1ifB15Lp3lwIjs3rwJW1so3K7FZ.xzQLmiC32fC_T85vcNoVhOfV9VcRsMyxw2YaX'
    def toolbelt = tool 'toolbelt'

    stage('Retieve Source') {
        checkout scm
    }

    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
        stage('Authorise Dev Hub') {
            rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:auth:jwt:grant -i ${CONNECTED_APP_CONSUMER_KEY} -u ${HUB_ORG} -f ${jwt_key_file} -d"
            if(rc != 0) {
                error 'Hub Org authorisation failed'
            }
        }
    }
}
