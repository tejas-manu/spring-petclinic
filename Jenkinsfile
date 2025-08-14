pipeline{
    agent none
    // agent {
    //     docker {
    //         image 'maven:3.9.6-eclipse-temurin-17'
    //         args '-v /var/run/docker.sock:/var/run/docker.sock'
    //     }
    // }

        environment {
            APP_IMAGE_NAME = 'my-cool-app'
    }

    stages {
        stage('Static Code Analysis') {
            agent {
                docker {
                    image 'maven:3.9.6-eclipse-temurin-17'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                    }
                }

            steps {
                echo 'Running SonarQube analysis...'
                withSonarQubeEnv('My SonarQube Server') {
                    sh "mvn sonar:sonar \
                    -Dsonar.projectKey=spring-petclinic-tejas \
                    -Dsonar.host.url=http://54.144.178.91:9000"
                }
            }
        }

        stage('Build Docker Images') {
            agent {label 'master'}
            
            steps {
                script {
                    echo "----------------------------------------"
                    echo "Building Docker images using docker-compose..."
                    sh 'docker build -t ${APP_IMAGE_NAME}:latest'
                    
                    echo "----------------------------------------"
                    echo "Docker Build Complete. Images created:"
                    echo "Application Image: ${APP_IMAGE_NAME}:latest"
                    echo "----------------------------------------"
                }
            }
        }
    

        stage('Test') {
            steps {
                echo 'Testing...'
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
        }
    }
}