pipeline {
    agent any
    environment {
        REGISTRY = "registry.hub.docker.com"
        dockerRegistryCredential = 'khorshedparvej3698'
        DOCKER_REGISTRY_URL = "https://${REGISTRY}"
        IMAGE_CREATED_BY = "jenkins"
        PROJECT_NAME = "khorshed-app-prod"
        DOCKER_USERNAME = "khorshedparvej3698"
        IMAGE_VERSION = "${BUILD_NUMBER}-${IMAGE_CREATED_BY}"
        DOCKER_TAG = "${DOCKER_USERNAME}/${PROJECT_NAME}:${IMAGE_VERSION}"
        DISCORD_WEBHOOK_URL = 'https://discord.com/api/webhooks/1307553467405041757/gUzx7aIastYyrjMsAgMtwggxz7tfeuaBGBNa9L8uUfEhOKcj_Ht-WOowjZI9A1qWFoIk' // Replace with your Discord webhook URL
    }

    stages {
        stage('Init') {
            steps {
                script {
                    GIT_TAG = sh(returnStdout: true, script: "git describe --tags").trim()
                    COMMIT_ID = sh(returnStdout: true, script: "git log -1 --pretty=%H").trim()
                    echo "Commit ID: ${COMMIT_ID}"
                    echo "Git Tag: ${GIT_TAG}"
                }
            }
        }

        stage('Building Docker image') { 
            steps { 
                script { 
                    dockerImage = docker.build("${DOCKER_TAG}", "-f ./Dockerfile .")
                    sh "docker images | grep ${PROJECT_NAME}"
                }
            } 
        }

        stage('Push Docker image') {
            steps {
                script {
                    docker.withRegistry("https://${REGISTRY}", dockerRegistryCredential) {
                        dockerImage.push()
                        sh "docker images | grep ${PROJECT_NAME}"
                    }
                }
            }
        }

        stage('Security Scan') {
            steps {
                script {
                    def scanResult = sh(script: "trivy image --exit-code 1 --severity HIGH,CRITICAL ${DOCKER_TAG}", returnStatus: true)
                    
                    if (scanResult != 0) {
                        def message = "Trivy scan failed for image ${DOCKER_TAG}. Check the logs for details."
                        sh "curl -H 'Content-Type: application/json' -d '{\"content\": \"${message}\"}' ${DISCORD_WEBHOOK_URL}"
                        error "Trivy scan failed."
                    } else {
                        def message = "Trivy scan succeeded for image ${DOCKER_TAG}. No critical vulnerabilities found."
                        sh "curl -H 'Content-Type: application/json' -d '{\"content\": \"${message}\"}' ${DISCORD_WEBHOOK_URL}"
                    }
                }
            }
        }

        stage('Run Docker container') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin'
                    }
                    sh '''
                    if [ $(docker ps -aq -f name=khorshed-app-prod) ]; then
                        echo "Stopping and removing existing container..."
                        docker stop khorshed-app-prod || true
                        docker rm khorshed-app-prod || true
                    fi
                    docker run -d --name khorshed-app-prod -p 8090:80 ${DOCKER_TAG}
                    '''
                }
            }
        }

        stage('Run PHPUnit Tests') {
            steps {
                script {
                    def testResult = sh(script: '''
                    docker exec khorshed-app-prod /var/www/html/vendor/bin/phpunit --configuration phpunit.xml
                    ''', returnStatus: true)

                    if (testResult != 0) {
                        def message = "Unit tests failed in Docker container. Check the logs for details."
                        sh "curl -H 'Content-Type: application/json' -d '{\"content\": \"${message}\"}' ${DISCORD_WEBHOOK_URL}"
                    } else {
                        def message = "Unit tests passed successfully in Docker container."
                        sh "curl -H 'Content-Type: application/json' -d '{\"content\": \"${message}\"}' ${DISCORD_WEBHOOK_URL}"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh "docker run -d ${DOCKER_TAG}"
                    def message = "Deployment of ${DOCKER_TAG} was successful by khorshed@ba-systems.com."
                    sh "curl -H 'Content-Type: application/json' -d '{\"content\": \"${message}\"}' ${DISCORD_WEBHOOK_URL}"
                }
            }
        }
    }
}
