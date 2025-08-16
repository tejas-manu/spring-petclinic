pipeline {
  agent any

  tools {
    maven 'maven3'
  }

  environment {
    DOCKER_IMAGE = "tejas1205/petclinic:${BUILD_NUMBER}"
  }

  stages {
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
    //     agent {
    //         docker {
    //           image 'maven:3.9.6-eclipse-temurin-17'
    //           args '-v /var/run/docker.sock:/var/run/docker.sock'
    //         }
    //     }
    //     steps {
    //       echo 'Running SonarQube analysis...'
    //       withSonarQubeEnv('MySonarServer') {
    //         sh "mvn sonar:sonar \
    //             -Dsonar.projectKey=spring-petclinic-tejas \
    //             -Dsonar.host.url=http://18.232.72.149:9000/"
    //         }
    //     }
    // }

    // stage('Build Docker Image') {
    //   steps {
    //     script {
    //       sh 'docker build -t ${DOCKER_IMAGE} .'
    //       echo "Docker image built: ${DOCKER_IMAGE}"
    //     }
    //   }
    // }

    // stage('Trivia Scan') {
    //   steps {
    //     script {
    //       // sh 'trivy image --exit-code 1 --severity HIGH,CRITICAL tejas1205/petclinic:${BUILD_NUMBER}'
    //       sh 'trivy image --severity HIGH,CRITICAL tejas1205/petclinic:${BUILD_NUMBER}'
    //     }
    //   }
    // }

    // stage('Push Docker Image') {
    //   steps {
    //     script {
    //       echo "Pushing Docker image: ${DOCKER_IMAGE}"
    //       def dockerImage = docker.image("${DOCKER_IMAGE}")
    //       docker.withRegistry('https://index.docker.io/v1/', "docker-cred") {
    //             dockerImage.push()
    //       }
    //     }
    //   }
    // }



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
  

  stage('ZAP Scan') {
    steps {
      script {
        echo "Waiting for ArgoCD to sync and application to be deployed..."

        // The URL that will be used for the health check.
        // Make sure your application has a health endpoint, e.g., /actuator/health for Spring Boot
        def minikubeServiceUrl = "https://jaybird-valid-hornet.ngrok-free.app/actuator/health"
        
        echo "Health check URL: ${minikubeServiceUrl}"

        // Wait for a maximum of 5 minutes (300 seconds)
        sh """
          URL="${minikubeServiceUrl}"
          max_attempts=60
          attempt=0
          while [ \$attempt -lt \$max_attempts ]; do
            echo "Attempt \$((attempt + 1)) of \$max_attempts: Checking service availability at \$URL..."
            
            # Use curl to get the HTTP status code. The -L flag handles redirects.
            # -s (silent), -o /dev/null (output to nowhere), -w "%{http_code}" (write status code)
            http_code=\$(curl -s -o /dev/null -L -w "%{http_code}" \$URL)
            
            if [ "\$http_code" -eq 200 ]; then
              echo "Service is up and running! Proceeding with ZAP scan."
              break
            else
              echo "Service not yet ready. Status code: \$http_code. Waiting 5 seconds..."
              sleep 5
              attempt=\$((attempt + 1))
            fi
          done
          
          if [ \$http_code -ne 200 ]; then
            echo "Error: Service failed to become ready after \$((max_attempts * 5)) seconds."
            exit 1 // Fail the pipeline
          fi
        """

        def zapUrl = minikubeServiceUrl.replace("/actuator/health", "")
        echo "ZAP scanning URL: ${zapUrl}"

        def userId = sh(returnStdout: true, script: 'id -u').trim()
        def groupId = sh(returnStdout: true, script: 'id -g').trim()

        // Run ZAP as the Jenkins user
        sh "docker run --rm -v \$(pwd):/zap/wrk/:rw -w /zap/wrk/ --user ${userId}:${groupId} zaproxy/zap-stable zap-baseline.py -t ${zapUrl} -I -r zap_report.html"

        
        // Run ZAP baseline scan using the official Docker image
        // sh "docker run --rm -v \$(pwd):/zap/wrk/:rw zaproxy/zap-stable zap-baseline.py -t ${zapUrl} -I -r zap_report.html"

        // Archive the ZAP report for later inspection
        archiveArtifacts artifacts: 'zap_report.html', fingerprint: true
      }
    }
  }
}


  post {
      always {
        echo 'Cleaning up...'
        sh 'docker rmi ${DOCKER_IMAGE} || true'

        cleanWs()

        echo 'Cleanup finished.'
    }
  }
}