pipeline{
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building...'
                // Use the built-in WORKSPACE environment variable for a guaranteed absolute path
                sh "./mvnw package"
            }
        }

        stage('Static Code Analysis') {
            steps {
                echo 'Running SonarQube analysis...'
                withSonarQubeEnv('My SonarQube Server') {
                    // Apply the same absolute path fix for the SonarQube step
                    sh "mvn sonar:sonar \
                    -Dsonar.projectKey=spring-petclinic-tejas \
                    -Dsonar.host.url=http://3.87.53.170:9000"
                }
            }
        }

        stage('Test') {
            steps {
                echo 'Testing...'
                // sh "mvn test -Dmaven.repo.local=${WORKSPACE}/.m2"
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            // sh "mvn clean -Dmaven.repo.local=${WORKSPACE}/.m2"
        }
    }
}