pipeline {
  agent any

  tools {
    maven 'maven3'
  }

  environment {
    // DOCKER_IMAGE = "tejas1205/petclinic:${BUILD_NUMBER}"
    ECR_REPOSITORY_URI = '318488421833.dkr.ecr.us-east-1.amazonaws.com/spring-boot/petclinic'
    DOCKER_IMAGE       = "${ECR_REPOSITORY_URI}:${BUILD_NUMBER}"
  }

  stages {
    
    stage('Pre-Build Cleanup') {
      steps {
        echo 'Stopping all running containers...'
        sh 'docker stop $(docker ps -a -q) || true'

        echo 'Removing all stopped containers...'
        sh 'docker rm $(docker ps -a -q) || true'

        // Add a delay here to give the Docker daemon time to free up resources
        echo 'Pausing for 5 seconds...'
        sh 'sleep 5'

        echo 'Removing all images...'
        sh 'docker rmi $(docker images -a -q) || true'
      }
    }

    stage('Checkout') {
      steps {
        checkout scm
      }
    }


    // stage('Build and Test') {
    //   agent {
    //     docker {
    //       image 'maven:3.9.6-eclipse-temurin-17'
    //       args '-v /var/run/docker.sock:/var/run/docker.sock'
    //     }
    //   }
      
    //   steps {
    //     sh 'mvn clean package'
    //   }
    // }


    // stage('Static Code Analysis') {
    //   agent {
    //     docker {
    //       image 'maven:3.9.6-eclipse-temurin-17'
    //       args '-v /var/run/docker.sock:/var/run/docker.sock'
    //     }
    //   }
      
    //   steps {
    //     echo 'Running SonarQube analysis...'
    //     withSonarQubeEnv('MySonarServer') {
    //       sh "mvn sonar:sonar \
    //           -Dsonar.projectKey=spring-petclinic-tejas \
    //           -Dsonar.host.url=http://172.31.39.168:9000/"
    //       }
    //   }
    // }



    stage('Build Docker Image') {
      steps {
        script {
          sh "docker build -t ${DOCKER_IMAGE} ."
          echo "Docker image built: ${DOCKER_IMAGE}"
        }
      }
    }


    stage('Trivia Scan') {
      steps {
        script {
          // sh 'trivy image --exit-code 1 --severity HIGH,CRITICAL tejas1205/petclinic:${BUILD_NUMBER}'
          sh "trivy image --severity HIGH,CRITICAL ${DOCKER_IMAGE}"
        }
      }
    }

    // stage('Publish to Nexus') {
    //   steps {
    //     echo 'Uploading artifacts to Nexus...'
    //     // Use withCredentials to securely access Nexus credentials from Jenkins
    //     withCredentials([usernamePassword(credentialsId: NEXUS_CREDENTIAL_ID, passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USER')]) {
    //       sh "mvn deploy -DaltDeploymentRepository=nexus::default::${NEXUS_URL} -DrepositoryId=nexus -Dnexus.username=${NEXUS_USER} -Dnexus.password=${NEXUS_PASSWORD}"
    //     }
    //   }
    // }

    stage('Push Docker Image') {
      steps {
        script {
            sh "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ECR_REPOSITORY_URI}"
            
            sh "docker build -t ${DOCKER_IMAGE} ."
            
            echo "Pushing Docker image to ECR: ${DOCKER_IMAGE}"
            sh "docker push ${DOCKER_IMAGE}"
        }
      }
    }

    stage('Run Application for Scan') {
      steps {
        script {
          echo "Starting application container for ZAP scan..."
          // The `docker run -d` command outputs the container ID, which we capture.
          def containerId = sh(returnStdout: true, script: "docker run -d -p 9090:8080 ${DOCKER_IMAGE}").trim()
          
          env.APP_CONTAINER_ID = containerId
          
          echo "Application container ID: ${APP_CONTAINER_ID}"
        }
      }
    }

    stage('Pulling ZAP Image') {
      steps {
        script {
          echo "Pulling ZAP Image from DockerHub..."

          sh 'docker pull zaproxy/zap-stable'
          sh 'docker run -dt --name owasp zaproxy/zap-stable /bin/bash'
        }
      }
    }

    stage('Check Application Health') {
      steps {
        script {
          def hostIp = sh(script: 'hostname -I | cut -d" " -f1', returnStdout: true).trim()
          def checkUrl = "http://${hostIp}:9090/actuator/health"
          def maxAttempts = 60
          def attempt = 0
          def httpCode

          while (attempt < maxAttempts) {
            echo "Attempt ${attempt + 1} of ${maxAttempts}: Checking service availability at ${checkUrl}..."
            
            httpCode = sh(
              script: "curl -s -o /dev/null -L -w '%{http_code}' ${checkUrl} || true",
              returnStdout: true
            ).trim()
            
            if (httpCode == "200") {
              echo "Service is up and running! Proceeding with ZAP scan."
              break
            } else {
              echo "Service not yet ready. Status code: ${httpCode}. Waiting 5 seconds..."
              sh "sleep 5"
              attempt++
            }
          }

          if (httpCode != "200") {
            echo "Error: Service failed to become ready after ${maxAttempts * 5} seconds."
            error("Application health check failed.")
          }
        }
      }
    }

    // stage('Check Application Health') {
    //   steps {
    //     script {
    //       echo "Waiting for the application to be up and running on port 9090..."
    //       def checkUrl = "http://localhost:9090/actuator/health"
    //       sh """
    //         URL="${checkUrl}"
    //         max_attempts=60
    //         attempt=0
    //         while [ \$attempt -lt \$max_attempts ]; do
    //             http_code=\$(curl -s -o /dev/null -L -w "%{http_code}" \$URL)
    //             if [ "\$http_code" -eq 200 ]; then
    //               echo "Application is up! Proceeding with ZAP scan."
    //               break
    //             else
    //               echo "App not ready. Status: \$http_code. Waiting 5s..."
    //               sleep 5
    //               attempt=\$((attempt + 1))
    //             fi
    //         done
    //         if [ "\$http_code" -ne 200 ]; then
    //            echo "Error: Application failed to become ready."
    //            exit 1
    //         fi
    //       """
    //     }
    //   }
    // }

    stage('Run ZAP Scan') {
      steps {
        script {
          echo "Creating directory..."
          sh 'docker exec owasp mkdir /zap/wrk'
        }
      }
    }


    stage('ZAP Baseline Scan') {
      steps {
        script {
          echo "Running ZAP Baseline Scan..."
          def zapUrl = "http://${hostIp}:9090"
          sh """
              docker exec owasp \
              zap-baseline.py \
              -t ${zapUrl} \
              -r zap_report.html \
              -I
            """
        }
      }
    }


    stage('Copy ZAP Report') {
      steps {
        script {
          echo "Archiving ZAP Report..."
          sh '''
              docker cp owasp:/zap/wrk/zap_report.html ${WORKSPACE}/zap_report.html
             '''
        }
      }
    }


    stage('Archive ZAP Report') {
      steps {
        script {
          echo "Archiving ZAP Report..."

          archiveArtifacts artifacts: 'zap_report.html', fingerprint: true
        }
      }
    }
  }

  post {
      always {
        echo 'Cleaning up...'

        sh '''
             docker stop owasp
             docker rm owasp
           '''
        
        sh 'docker rmi ${DOCKER_IMAGE} || true'
        sh 'docker rmi jenkins-with-zap:${BUILD_NUMBER} || true'

        sh 'docker rmi $(docker images -q) || true'

        cleanWs()
        echo 'Cleanup finished.'
    }
  }
}




    // stage('Update Manifests') {
    //   environment {
    //     GIT_REPO_NAME = "spring-petclinic-manifest"
    //     GIT_USER_NAME = "tejas-manu"
    //   }

    //   steps {
    //     script {
    //       def manifestRepoUrl = 'https://github.com/tejas-manu/spring-petclinic-manifest.git'
    //       def manifestRepoDir = 'manifests'

    //       dir(manifestRepoDir) {
    //         git branch: 'main', credentialsId: 'github', url: manifestRepoUrl

    //         withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
    //         sh '''
    //             git config user.email "tejasmanus.12@gmail.com"
    //             git config user.name "tejas-manu"

    //             sed -i "s|tejas1205/petclinic:.*|tejas1205/petclinic:${BUILD_NUMBER}|g" k8s/petclinic.yml
                                
    //             git add k8s/petclinic.yml
    //             git commit -m "Update deployment image to version ${BUILD_NUMBER}"
    //             git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/spring-petclinic-manifest HEAD:main
    //           '''
    //         }
    //       }
    //     }
    //   }
    // }


    // stage('ZAP Scan') {
    //   steps {
    //     script {
    //       echo "Waiting for ArgoCD to sync and application to be deployed..."
    //       def minikubeServiceUrl = "https://jaybird-valid-hornet.ngrok-free.app/actuator/health"
    //       echo "Health check URL: ${minikubeServiceUrl}"

    //       sh """
    //          URL="${minikubeServiceUrl}"
    //          max_attempts=60
    //          attempt=0
    //          while [ \$attempt -lt \$max_attempts ]; do
    //             echo "Attempt \$((attempt + 1)) of \$max_attempts: Checking service availability at \$URL..."
    //             http_code=\$(curl -s -o /dev/null -L -w "%{http_code}" \$URL)
    //             if [ "\$http_code" -eq 200 ]; then
    //               echo "Service is up and running! Proceeding with ZAP scan."
    //               break
    //             else
    //               echo "Service not yet ready. Status code: \$http_code. Waiting 5 seconds..."
    //               sleep 5
    //               attempt=\$((attempt + 1))
    //             fi
    //          done
    //          if [ "\$http_code" -ne 200 ]; then
    //             echo "Error: Service failed to become ready after \$((max_attempts * 5)) seconds."
    //             exit 1
    //          fi
    //          """
    //     }
    //   }
    // }


  //   stage('Pulling ZAP Image') {
  //     steps {
  //       script {
  //         echo "Pulling ZAP Image from DockerHub..."

  //         sh 'docker pull zaproxy/zap-stable'
  //         sh 'docker run -dt --name owasp zaproxy/zap-stable /bin/bash'
  //       }
  //     }
  //   }


  //   stage('Run ZAP Scan') {
  //     steps {
  //       script {
  //         echo "Creating directory..."
  //         sh 'docker exec owasp mkdir /zap/wrk'
  //       }
  //     }
  //   }


  //   stage('ZAP Baseline Scan') {
  //     steps {
  //       script {
  //         echo "Running ZAP Baseline Scan..."
  //         def zapUrl = "https://jaybird-valid-hornet.ngrok-free.app"
  //         sh """
  //             docker exec owasp \
  //             zap-baseline.py \
  //             -t ${zapUrl} \
  //             -r zap_report.html \
  //             -I
  //           """
  //       }
  //     }
  //   }


  //   stage('Copy ZAP Report') {
  //     steps {
  //       script {
  //         echo "Archiving ZAP Report..."
  //         sh '''
  //             docker cp owasp:/zap/wrk/zap_report.html ${WORKSPACE}/zap_report.html
  //            '''
  //       }
  //     }
  //   }


  //   stage('Archive ZAP Report') {
  //     steps {
  //       script {
  //         echo "Archiving ZAP Report..."

  //         archiveArtifacts artifacts: 'zap_report.html', fingerprint: true
  //       }
  //     }
  //   }
  // }
