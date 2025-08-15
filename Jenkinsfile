pipeline {
  agent {
    docker {
      image 'tejas1205/maven-docker-agent:jdk17-v1.0'
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock' // mount Docker socket to access the host's Docker daemon
    }
  }
  stages {
    stage('Checkout') {
        steps {
        sh 'echo passed'
      }
    }
    stage('Build and Test') {
      steps {
        sh 'mvn package -DskipTests'
      }
    }


    stage('Static Code Analysis') {
        steps {
          echo 'Running SonarQube analysis...'
          withSonarQubeEnv('MySonarServer') {
            sh "mvn sonar:sonar \
                -Dsonar.projectKey=spring-petclinic-tejas \
                -Dsonar.host.url=http://54.209.232.12:9000/"
            }
        }
    }


    stage('Build and Push Docker Image') {
      environment {
        DOCKER_IMAGE = "tejas1205/petclinic:${BUILD_NUMBER}"
        // DOCKERFILE_LOCATION = "java-maven-sonar-argocd-helm-k8s/spring-boot-app/Dockerfile"
        REGISTRY_CREDENTIALS = credentials('docker-cred')
      }
      steps {
        script {
            sh 'docker build -t ${DOCKER_IMAGE} .'
            def dockerImage = docker.image("${DOCKER_IMAGE}")
            docker.withRegistry('https://index.docker.io/v1/', "docker-cred") {
                dockerImage.push()
            }
        }
      }
    }
    stage('Update Deployment File') {
        environment {
            GIT_REPO_NAME = "spring-petclinic"
            GIT_USER_NAME = "tejas-manu"
        }
        steps {
            withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                sh '''
                    git config user.email "tejasmanus.12@gmail.com"
                    git config user.name "tejas-manu"
                    BUILD_NUMBER=${BUILD_NUMBER}
                    sed -i "s/replaceImageTag/${BUILD_NUMBER}/g" k8s/petclinic.yml
                    git add k8s/petclinic.yml
                    git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                    git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:pipeline
                '''
            }
        }
    }
  }
}


// pipeline{
//     agent any
//     // agent {
//     //     docker {
//     //         image 'maven:3.9.6-eclipse-temurin-17'
//     //         args '-v /var/run/docker.sock:/var/run/docker.sock'
//     //     }
//     // }

//         environment {
//             APP_IMAGE_NAME = 'my-cool-app'
//     }

//     stages {
        // stage('Static Code Analysis') {
        //     agent {
        //         docker {
        //             image 'maven:3.9.6-eclipse-temurin-17'
        //             args '-v /var/run/docker.sock:/var/run/docker.sock'
        //             }
        //         }

        //     steps {
        //         echo 'Running SonarQube analysis...'
        //         withSonarQubeEnv('My SonarQube Server') {
        //             sh "mvn sonar:sonar \
        //             -Dsonar.projectKey=spring-petclinic-tejas \
        //             -Dsonar.host.url=http://54.144.178.91:9000"
        //         }
        //     }
        // }

//         stage('Build Docker Images') {
//             steps {
//                 script {
//                     echo "----------------------------------------"
//                     echo "Building Docker images using docker-compose..."
//                     sh 'docker build -t ${APP_IMAGE_NAME}:latest .'
                    
//                     echo "----------------------------------------"
//                     echo "Docker Build Complete. Images created:"
//                     echo "Application Image: ${APP_IMAGE_NAME}:latest"
//                     echo "----------------------------------------"
//                 }
//             }
//         }
    

//         stage('Test') {
//             steps {
//                 echo 'Testing...'
//             }
//         }
//     }

//     post {
//         always {
//             echo 'Cleaning up...'
//         }
//     }
// }