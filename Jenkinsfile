pipeline {
    agent any
    environment {
        REGISTRY = "registry.hub.docker.com"
        dockerRegistryCredential = 'khorshed'
        IMAGE_CREATED_BY = "jenkins"
        PROJECT_NAME = "khorshed-php-app"
        DOCKER_USERNAME = "khorshedparvej3698"
        // Fetch Git tag dynamically during build process
        GIT_TAG = ''
        IMAGE_VERSION = "$BUILD_NUMBER-$IMAGE_CREATED_BY"
        DOCKER_TAG = "$REGISTRY/$DOCKER_USERNAME/$PROJECT_NAME:$IMAGE_VERSION"
        DISCORD_WEBHOOK_URL = 'https://discord.com/api/webhooks/1307553467405041757/gUzx7aIastYyrjMsAgMtwggxz7tfeuaBGBNa9L8uUfEhOKcj_Ht-WOowjZI9A1qWFoIk' // Replace with your Discord webhook URL
    }

    stages {
        stage('Init') {
            steps {
                script {
                    // Fetch the Git tag dynamically and update the GIT_TAG environment variable
                    GIT_TAG = sh(returnStdout: true, script: 'git describe --tags').trim()
                    echo "Commit ID: ${GIT_TAG}"
                }
            }
        }

        // Uncomment this section if you want to enforce a tag check
        // stage('Check for tag') {
        //     steps {
        //         sh '''        
        //         if [ -z "$GIT_TAG" ] #empty check
        //         then
        //             echo ERROR: Tag not found
        //             exit 1 # terminate and indicate error                  
        //         fi
        //         echo "git checking out to $GIT_TAG tag"
        //         git checkout $GIT_TAG
        //         '''    
        //     }
        // }

        // Uncomment this section if you want to clean up local images
        // stage('Clean up local image') {
        //     steps {
        //         echo "Cleaning local docker registry $DOCKER_TAG image"
        //         sh 'docker rmi $DOCKER_TAG'
        //     }
        // }

        stage('Building Docker image') {
            steps {
                script {
                    // Build the Docker image
                    dockerImage = docker.build("$DOCKER_TAG", "-f ./Dockerfile .")
                }
                sh '''
                docker images | grep $PROJECT_NAME
                '''
            }
        }

        stage('Push Docker image') {
            steps {
                script {
                    // Push the Docker image to the registry
                    docker.withRegistry("https://$REGISTRY", dockerRegistryCredential) {
                        dockerImage.push()
                    }
                }
                sh "docker images | grep $PROJECT_NAME"
            }
        }
    }

    post {
        always {
            // Clean up any resources, notifications, or final tasks
            echo 'Cleaning up after the build...'
        }
    }
}


        // stage('Security Scan') {
        //     steps {
        //         script {
        //             // Run Trivy scan on the built image
        //             def scanResult = sh(script: 'trivy image --exit-code 1 --severity HIGH,CRITICAL $DOCKER_TAG', returnStatus: true)
                    
        //             // Check if the scan failed
        //             if (scanResult != 0) {
        //                 // Send failure message to Discord
        //                 def message = "Trivy scan failed for image $DOCKER_TAG. Check the logs for details."
        //                 sh """
        //                 curl -H "Content-Type: application/json" -d '{ "content": "${message}" }' ${DISCORD_WEBHOOK_URL}
        //                 """
        //                 error "Trivy scan failed."
        //             }
        //         }
        //     }
        // }  

        stage('Security Scan') {
            steps {
                script {
                    // Run Trivy scan on the built image
                    def scanResult = sh(script: "trivy image --exit-code 1 --severity HIGH,CRITICAL $DOCKER_TAG", returnStatus: true)
                    
                    // Prepare the message based on the scan result
                    if (scanResult != 0) {
                        // Send failure message to Discord
                        def message = "Trivy scan failed for image $DOCKER_TAG. Check the logs for details."
                        sh """
                        curl -H "Content-Type: application/json" -d '{ "content": "${message}" }' ${DISCORD_WEBHOOK_URL}
                        """
                    } else {
                        // Send success message to Discord
                        def message = "Trivy scan succeeded for image $DOCKER_TAG. No critical vulnerabilities found."
                        sh """
                        curl -H "Content-Type: application/json" -d '{ "content": "${message}" }' ${DISCORD_WEBHOOK_URL}
                        """
                    }
                }
            }
        }              

        stage('Run Docker container') {
            steps {
                echo "Running Docker container for PHP app"
                sh '''
                if [ $(docker ps -aq -f name=khorshed-php-app) ]; then
            echo "Stopping and removing existing container..."
            docker stop khorshed-php-app || true
            docker rm khorshed-php-app || true
                fi
                docker run -d --name khorshed-php-app -p 8090:80 $DOCKER_TAG
                '''
            }
        }
       
    //     stage('Run PHPUnit Tests') {
    //         steps {
    //             echo "Running PHPUnit tests in Docker container"
    //             sh '''
    //             docker exec php-app /var/www/html/vendor/bin/phpunit --configuration phpunit.xml
    //             '''
    //         }
    //     }

    //     stage('Run SQA Testing') {
    //         steps {
    //             echo "Running SQA testing for PHP application"
    //             // Add your custom SQA testing scripts here
    //             sh '''
    //             # Example placeholder for running SQA tests
    //             echo "Running SQA tests..."
    //             '''
    //         }
    //     }
    // }

        stage('Run PHPUnit Tests') {
            steps {
                script {
                    echo "Running PHPUnit tests in Docker container"
                    def testResult = sh(script: '''
                    docker exec khorshed-php-app /var/www/html/vendor/bin/phpunit --configuration phpunit.xml
                    ''', returnStatus: true)

                    // Send test result to Discord
                    if (testResult != 0) {
                        def message = "Unit tests failed in Docker container php-app. Check the logs for details."
                        sh """
                        curl -H "Content-Type: application/json" -d '{ "content": "${message}" }' ${DISCORD_WEBHOOK_URL}
                        """
                    } else {
                        def message = "Unit tests passed successfully in Docker container php-app."
                        sh """
                        curl -H "Content-Type: application/json" -d '{ "content": "${message}" }' ${DISCORD_WEBHOOK_URL}
                        """
                    }
                }
            }
        }
        stage('Run SQA Testing') {
            steps {
                script {
                    echo "Running SQA testing for PHP application"
                    def sqaResult = sh(script: '''
                    # Example placeholder for running SQA tests
                    echo "Running SQA tests..."
                    # Add your actual SQA testing commands here
                    ''', returnStatus: true)

                    // Send SQA test result to Discord
                    if (sqaResult != 0) {
                        def message = "SQA tests failed for the PHP application. Check the logs for details."
                        sh """
                        curl -H "Content-Type: application/json" -d '{ "content": "${message}" }' ${DISCORD_WEBHOOK_URL}
                        """
                    } else {
                        def message = "SQA tests passed successfully for the PHP application."
                        sh """
                        curl -H "Content-Type: application/json" -d '{ "content": "${message}" }' ${DISCORD_WEBHOOK_URL}
                        """
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    // Deploy your Docker image here
                    sh 'docker run -d $DOCKER_TAG'
                    
                    // Send deployment success message to Discord
                    def message = "Deployment of $DOCKER_TAG was successful by khorshed@ba-systems.com."
                    sh """
                    curl -H "Content-Type: application/json" -d '{ "content": "${message}" }' ${DISCORD_WEBHOOK_URL}
                    """
                }
            }
        }
    }    

    // post {
    //     always {
    //         echo "Stopping and removing Docker container"
    //         sh '''
    //         docker stop php-app || true
    //         docker rm php-app || true
    //         '''
    //     }
    // }
}
