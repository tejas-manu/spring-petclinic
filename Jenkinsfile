pipeline{
    agent any
    
    stages {
        stage('Build') {
        steps {
            echo 'Building...'
            sh './mvnw package'
        }
        }

        stage('Static Code Analysis') {
        environment {
            SONAR_URL = "http://3.87.53.170:9000/"
        }
        steps {
            withCredentials([string(credentialsId: 'Sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
            sh 'mvn sonar:sonar -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL}'
            }
        }
        }
    
        stage('Test') {
        steps {
            echo 'Testing...'
            // sh 'mvn test'
        }
        }
    }
    
    post {
        always {
        echo 'Cleaning up...'
        // sh 'mvn clean'
        }
    }
}