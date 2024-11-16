pipeline {
    agent any
    environment {
        REGISTRY = "hub.docker.com"
        dockerRegistryCredential = 'docker-credentials-id' // Replace with your Jenkins credential ID for Docker registry
        DOCKER_REGISTRY_URL = "https://${REGISTRY}"
        IMAGE_CREATED_BY = "jenkins"
        PROJECT_NAME = "NEW-PROJECT-CICD"
        BUILD_TAG = "${BUILD_NUMBER}-${IMAGE_CREATED_BY}"
        DOCKER_TAG = "${REGISTRY}/${PROJECT_NAME}:${BUILD_TAG}"
        DISCORD_WEBHOOK_URL = credentials('https://discord.com/channels/1201941014948876328/1207622436925866065') // Replace with your Jenkins credential ID for Discord webhook
    }

    stages {
        stage('Init') {
            steps {
                echo "Initializing pipeline..."
                script {
                    COMMIT_ID = sh(
                        script: "git log -1 --format='%H'",
                        returnStdout: true
                    ).trim()
                    echo "Last Commit ID: ${COMMIT_ID}"
                }
            }
        }

        stage('Building Docker image') {
            steps {
                script {
                    echo "Building Docker image..."
                    dockerImage = docker.build(DOCKER_TAG, "-f ./Dockerfile .")
                }
            }
        }

        stage('Push Docker image') {
            steps {
                script {
                    echo "Pushing Docker image to registry..."
                    docker.withRegistry(DOCKER_REGISTRY_URL, dockerRegistryCredential) {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Security Scan') {
            steps {
                script {
                    echo "Running Trivy security scan..."
                    def scanResult = sh(
                        script: "trivy image --exit-code 1 --severity HIGH,CRITICAL ${DOCKER_TAG}",
                        returnStatus: true
                    )

                    def message
                    if (scanResult != 0) {
                        message = "🚨 *Security Scan Failed!* Trivy detected critical issues in the image ${DOCKER_TAG}."
                        error "Security scan failed."
                    } else {
                        message = "✅ *Security Scan Passed!* No critical vulnerabilities found in the image ${DOCKER_TAG}."
                    }
                    sendDiscordNotification(message)
                }
            }
        }

        stage('Run Docker container') {
            steps {
                echo "Running Docker container for application..."
                sh "docker run -d --name php-app -p 8088:80 ${DOCKER_TAG}"
            }
        }

        stage('Run PHPUnit Tests') {
            steps {
                script {
                    echo "Executing PHPUnit tests..."
                    def testResult = sh(
                        script: "docker exec php-app /var/www/html/vendor/bin/phpunit --configuration phpunit.xml",
                        returnStatus: true
                    )

                    def message
                    if (testResult != 0) {
                        message = "🚨 *Unit Tests Failed!* Check logs for details."
                        error "Unit tests failed."
                    } else {
                        message = "✅ *Unit Tests Passed!*"
                    }
                    sendDiscordNotification(message)
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Deploying application..."
                    sh "docker run -d ${DOCKER_TAG}"

                    def message = "🚀 *Deployment Successful!* Image ${DOCKER_TAG} has been deployed."
                    sendDiscordNotification(message)
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Cleaning up resources..."
                sh '''
                docker stop php-app || true
                docker rm php-app || true
                docker rmi ${DOCKER_TAG} || true
                '''
            }
        }
    }
}

def sendDiscordNotification(String message) {
    def payload = [
        content: message
    ]
    sh """
    curl -H "Content-Type: application/json" \
        -d '${groovy.json.JsonOutput.toJson(payload)}' \
        ${DISCORD_WEBHOOK_URL}
    """
}
