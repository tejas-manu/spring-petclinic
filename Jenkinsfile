pipeline{
    agent {
        docker {
        image 'abhishekf5/maven-abhishek-docker-agent:v1'
        args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    
    stages {

        stage('Debug Environment') {
            steps {
                echo 'Printing PATH variable'
                sh 'echo $PATH'
                echo 'Checking for docker command'
                sh 'which docker'
            }
        }
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
            withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
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