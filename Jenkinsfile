pipeline {
  agent none
  // agent {
  //   docker {
  //     image 'tejas1205/maven-docker-agent:jdk17-v1.0'
  //     args '--user root -v /var/run/docker.sock:/var/run/docker.sock' // mount Docker socket to access the host's Docker daemon
  //   }
  // }

  stages {
    stage('Checkout') {
      agent any
      steps {
        checkout scm
      }
    }
    stage('Build and Test') {
      agent {
        docker {
          image 'maven:3.9.6-eclipse-temurin-17'
          args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
      }
      steps {
        sh 'mvn clean package'
      }
    }

    stage('Static Code Analysis') {
        agent {
            docker {
              image 'maven:3.9.6-eclipse-temurin-17'
              args '-v /var/run/docker.sock:/var/run/docker.sock'
            }
        }
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
      agent {
        docker {
          image 'tejas1205/maven-docker-agent:jdk17-v1.0'
          args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
      }
      environment {
        DOCKER_IMAGE = "tejas1205/petclinic:${BUILD_NUMBER}"
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

    stage('Update Manifests') {
            agent {
              docker {
                image 'tejas1205/maven-docker-agent:jdk17-v1.0'
                args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
              }
            }
            environment {
              GIT_REPO_NAME = "spring-petclinic-manifest"
              GIT_USER_NAME = "tejas-manu"
            }
            steps {
                script {
                    // Define manifest repo variables
                    def manifestRepoUrl = 'https://github.com/tejas-manu/spring-petclinic-manifest.git'
                    def manifestRepoDir = 'manifests'

                    // Use a temporary directory to clone the manifest repo
                    dir(manifestRepoDir) {
                        // This step clones the manifest repository, NOT the app repository
                        // Replace 'github' with the credentialsId you use for Git access
                        git branch: 'main', credentialsId: 'github', url: manifestRepoUrl

                        // Now, run the same commands you had before
                        withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                            sh '''
                                git config user.email "tejasmanus.12@gmail.com"
                                git config user.name "tejas-manu"

                                # Modify the YAML file in this new directory
                                sed -i "s|tejas1205/petclinic:.*|tejas1205/petclinic:${BUILD_NUMBER}|g" k8s/petclinic.yml
                                
                                git add k8s/petclinic.yml
                                git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                                git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/spring-petclinic-manifest HEAD:main
                            '''
                        }
                    }
                }
            }
        }



    // stage('Update Deployment File') {
        // agent {
        //   docker {
        //     image 'tejas1205/maven-docker-agent:jdk17-v1.0'
        //     args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        //   }
        // }
        // environment {
        //     GIT_REPO_NAME = "spring-petclinic-manifest"
        //     GIT_USER_NAME = "tejas-manu"
        // }
    //     steps {
    //         withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
    //             sh '''
    //                 git config user.email "tejasmanus.12@gmail.com"
    //                 git config user.name "tejas-manu"
    //                 BUILD_NUMBER=${BUILD_NUMBER}
    //                 sed -i "s|tejas1205/petclinic:.*|tejas1205/petclinic:${BUILD_NUMBER}|g" k8s/petclinic.yml
    //                 git add k8s/petclinic.yml
    //                 git commit -m "Update deployment image to version ${BUILD_NUMBER}"
    //                 git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
    //             '''
    //         }
    //     }
    // }
  }
}