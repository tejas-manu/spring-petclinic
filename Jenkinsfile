pipeline{
    agent {
        docker {
            image 'maven:3.9.6-eclipse-temurin-17'
        }
    }

    stages {

        stage('Build') {
        steps {
            echo 'Building...'
            sh './mvnw package -DskipTests -Dmaven.repo.local=./.m2'
        }
        }

        stage('Static Code Analysis') {
            steps {
                echo 'Running SonarQube analysis...'
                
                // This step connects to the SonarQube server configured in Jenkins,
                // and injects SONAR_TOKEN and SONAR_HOST_URL environment variables.
                withSonarQubeEnv('My SonarQube Server') {
                    sh 'mvn sonar:sonar \
                    -Dsonar.projectKey=spring-petclinic-tejas \
                    -Dsonar.host.url=http://3.87.53.170:9000 \
                    -Dmaven.repo.local=./.m2'
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