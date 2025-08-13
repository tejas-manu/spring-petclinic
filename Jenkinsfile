pipeline{
    agent {
        docker {
            image 'maven:3.9.6-eclipse-temurin-17'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    stages {
        stage('Build') {
            steps {
                echo 'Building...'
                sh "mvn package"
            }
        }
        stage('Static Code Analysis') {

            steps {
                echo 'Running SonarQube analysis...'
                withSonarQubeEnv('My SonarQube Server') {
                    sh "mvn sonar:sonar \
                    -Dsonar.projectKey=spring-petclinic-tejas \
                    -Dsonar.host.url=http://3.87.53.170:9000"
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