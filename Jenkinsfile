// A declarative Jenkins pipeline that builds, analyzes, and tests a Maven project.
pipeline {
    // This agent is a fallback; the stages will use their own agents.
    agent any

    stages {
        stage('Build & Analyze') {
            // Use the Docker agent to ensure a consistent environment for both build and analysis.
            agent {
                docker {
                    image 'maven:3.9.6-eclipse-temurin-17'
                }
            }
            steps {
                echo 'Building and running static code analysis...'
                // The `mvnw package` command compiles the code, creating the target/classes directory.
                sh "./mvnw package"

                withSonarQubeEnv('My SonarQube Server') {
                    // Since we are in the same stage, the compiled classes are now available for SonarQube.
                    sh "mvn sonar:sonar \
                    -Dsonar.projectKey=spring-petclinic-tejas \
                    -Dsonar.host.url=http://3.87.53.170:9000"
                }
            }
        }

        stage('Test') {
            // This stage could also run in the same Docker agent for consistency.
            steps {
                echo 'Testing...'
                // Run the tests. The -Dmaven.repo.local property can be used to manage the local repo.
                sh "mvn test"
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            // Clean up the project files after the build is complete.
            sh "mvn clean"
        }
    }
}


// pipeline{
//     agent any

//     stages {
//         stage('Build') {
//             steps {
//                 echo 'Building...'
//                 // Use the built-in WORKSPACE environment variable for a guaranteed absolute path
//                 sh "./mvnw package"
//             }
//         }

//         stage('Static Code Analysis') {
//             agent {
//                 docker {
//                     image 'maven:3.9.6-eclipse-temurin-17'
//                 }
//             }
//             steps {
//                 echo 'Running SonarQube analysis...'
//                 withSonarQubeEnv('My SonarQube Server') {
//                     // Apply the same absolute path fix for the SonarQube step
//                     sh "mvn sonar:sonar \
//                     -Dsonar.projectKey=spring-petclinic-tejas \
//                     -Dsonar.host.url=http://3.87.53.170:9000"
//                 }
//             }
//         }

//         stage('Test') {
//             steps {
//                 echo 'Testing...'
//                 // sh "mvn test -Dmaven.repo.local=${WORKSPACE}/.m2"
//             }
//         }
//     }

//     post {
//         always {
//             echo 'Cleaning up...'
//             // sh "mvn clean -Dmaven.repo.local=${WORKSPACE}/.m2"
//         }
//     }
// }