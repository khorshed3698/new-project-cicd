pipeline {
    agent any
    environment {
        REGISTRY = "registry.hub.docker.com"
        dockerRegistryCredential = 'khorshed'
        dockerImage = ''
        DOCKER_REGISTRY_URL = "https://$REGISTRY"
        IMAGE_CREATED_BY = "jenkins"
        PROJECT_NAME = "khorshed-app-prod"
        IMAGE_VERSION = "$BUILD_NUMBER-$IMAGE_CREATED_BY"
        DOCKER_TAG = "$REGISTRY/$PROJECT_NAME:$IMAGE_VERSION"
    }

    stages {
        stage('Init') {
            steps {
                script {
                    GIT_TAG = sh(returnStdout: true, script: 'git describe --tags || echo "no-tag"').trim()
                    COMMIT_ID = sh(returnStdout: true, script: 'git log -1 --pretty=%H').trim()
                    echo "Git Tag: ${GIT_TAG}"
                    echo "Commit ID: ${COMMIT_ID}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_TAG}", "-f ./Dockerfile .")
                    sh 'docker images | grep $PROJECT_NAME'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry("$DOCKER_REGISTRY_URL", dockerRegistryCredential) {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Security Scan') {
            steps {
                script {
                    def scanResult = sh(script: "trivy image --exit-code 1 --severity HIGH,CRITICAL $DOCKER_TAG", returnStatus: true)
                    def message = scanResult != 0 ?
                        "Trivy scan failed for image $DOCKER_TAG. Check the logs for details." :
                        "Trivy scan succeeded for image $DOCKER_TAG. No critical vulnerabilities found."
                    withCredentials([string(credentialsId: 'discord-webhook-id', variable: 'DISCORD_WEBHOOK_URL')]) {
                        sh "curl -H 'Content-Type: application/json' -d '{ \"content\": \"${message}\" }' ${DISCORD_WEBHOOK_URL}"
                    }
                    if (scanResult != 0) error "Trivy scan failed."
                }
            }
        }

        stage('Run Tests in Docker Container') {
            steps {
                script {
                    echo "Starting Docker container for testing"
                    sh '''
                    docker stop php-app || true
                    docker rm php-app || true
                    docker run -d --name php-app $DOCKER_TAG
                    '''
                    def testResult = sh(script: '''
                    docker exec php-app /var/www/html/vendor/bin/phpunit --configuration phpunit.xml
                    ''', returnStatus: true)
                    def message = testResult != 0 ?
                        "Unit tests failed in Docker container php-app. Check the logs for details." :
                        "Unit tests passed successfully in Docker container php-app."
                    withCredentials([string(credentialsId: 'discord-webhook-id', variable: 'DISCORD_WEBHOOK_URL')]) {
                        sh "curl -H 'Content-Type: application/json' -d '{ \"content\": \"${message}\" }' ${DISCORD_WEBHOOK_URL}"
                    }
                    if (testResult != 0) error "Unit tests failed."
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh '''
                    docker stop php-app || true
                    docker rm php-app || true
                    docker run -d --name php-app -p 8088:80 $DOCKER_TAG
                    '''
                    def message = "Deployment of $DOCKER_TAG was successful."
                    withCredentials([string(credentialsId: 'discord-webhook-id', variable: 'DISCORD_WEBHOOK_URL')]) {
                        sh "curl -H 'Content-Type: application/json' -d '{ \"content\": \"${message}\" }' ${DISCORD_WEBHOOK_URL}"
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Cleaning up Docker resources"
                sh '''
                docker stop php-app || true
                docker rm php-app || true
                docker rmi $DOCKER_TAG || true
                '''
            }
        }
    }
}
