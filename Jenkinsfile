pipeline{
    agent any
    
    stages {
        stage('Build') {
        agent {
            docker {
                image 'maven:3.6.3-jdk-11'
                args '-v /root/.m2:/root/.m2'
            }
        }
        steps {
            echo 'Building...'
            sh 'mvn clean package'
        }
        }
    
        stage('Test') {
        steps {
            echo 'Testing...'
            sh 'mvn test'
        }
        }
    }
    
    post {
        always {
        echo 'Cleaning up...'
        sh 'mvn clean'
        }
    }
}