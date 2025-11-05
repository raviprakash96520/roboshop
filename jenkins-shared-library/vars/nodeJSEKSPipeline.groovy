def call(Map configMap) {
    pipeline {
        agent {
            label 'AGENT-1'
        }

        options {
            timeout(time: 30, unit: 'MINUTES')
            disableConcurrentBuilds()
        }

        parameters {
            booleanParam(name: 'deploy', defaultValue: false, description: 'Select to deploy or not')
        }

        environment {
            appVersion = ''
            region = 'us-east-1'
            account_id = '315069654700'
            project = configMap.get("project")
            environment = 'dev'
            component = configMap.get("component")
            componentPath = "roboshop-ci/${component}"
        }

        stages {
            stage('Read the version') {
                steps {
                    dir("${componentPath}") {
                        script {
                            def packageJson = readJSON file: 'package.json'
                            appVersion = packageJson.version
                            echo "App version: ${appVersion}"
                        }
                    }
                }
            }

            stage('Install Dependencies') {
                steps {
                    dir("${componentPath}") {
                        sh 'npm install'
                    }
                }
            }

            stage('Docker build') {
                steps {
                    dir("${componentPath}") {
                        withAWS(region: 'us-east-1', credentials: "aws-creds-${environment}") {
                            sh """
                            aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${account_id}.dkr.ecr.us-east-1.amazonaws.com
                            docker build -t ${account_id}.dkr.ecr.us-east-1.amazonaws.com/${project}/${environment}/${component}:${appVersion} .
                            docker push ${account_id}.dkr.ecr.us-east-1.amazonaws.com/${project}/${environment}/${component}:${appVersion}
                            """
                        }
                    }
                }
            }

            stage('Deploy') {
                when {
                    expression { params.deploy }
                }
                steps {
                    build job: "../${component}-cd", parameters: [
                        string(name: 'version', value: "${appVersion}"),
                        string(name: 'ENVIRONMENT', value: "${environment}")
                    ], wait: true
                }
            }
        }

        post {
            always {
                echo "This sections runs always"
                deleteDir()
            }
            success {
                echo "This section runs when pipeline success"
            }
            failure {
                echo "This section runs when pipeline failure"
            }
        }
    }
}
