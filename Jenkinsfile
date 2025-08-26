pipeline {
  agent any

  tools {
    maven 'maven3'
  }

  environment {
    ECR_REPOSITORY_URI = '318488421833.dkr.ecr.us-east-1.amazonaws.com/spring-boot/petclinic'
    DOCKER_IMAGE       = "${ECR_REPOSITORY_URI}:${BUILD_NUMBER}"

    NEXUS_URL = 'http://172.31.39.168:8081'
    NEXUS_REPO = 'petclinic-maven-releases-group'

    

    AWS_DEFAULT_REGION = 'us-east-1'
    EB_APP_NAME = 'petclinic'
    EB_ENV_NAME = 'petclinic-env-1'
    S3_BUCKET = 'my-petclinic-deployment-bucket'
    
    JAR_FILE_NAME = "spring-petclinic-3.4.0-SNAPSHOT.jar"
    VERSION_LABEL = "build-${env.BUILD_NUMBER}"
    ZIP_FILE_PATH = "petclinic-deployment-${env.BUILD_NUMBER}.zip"
  }

  stages {
    
    stage('Pre-Build Cleanup') {
      steps {
        echo 'Stopping all running containers...'
        sh 'docker stop $(docker ps -a -q) || true'

        echo 'Removing all stopped containers...'
        sh 'docker rm $(docker ps -a -q) || true'

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


    stage('Build and Test') {
      agent {
        docker {
          image 'maven:3.9.6-eclipse-temurin-17'
          args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
      }
      
      steps {
        sh 'mvn clean package'

        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
      }
    }


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



    // stage('Build Docker Image') {
    //   steps {
    //     script {
    //       sh "docker build -t ${DOCKER_IMAGE} ."
    //       echo "Docker image built: ${DOCKER_IMAGE}"
    //     }
    //   }
    // }


    // stage('Trivia Scan') {
    //   steps {
    //     script {
    //       // sh 'trivy image --exit-code 1 --severity HIGH,CRITICAL ${DOCKER_IMAGE}'
    //       sh "trivy image --severity HIGH,CRITICAL ${DOCKER_IMAGE}"
    //     }
    //   }
    // }


    stage('Publish to Nexus') {
      // agent {
      //   docker {
      //     image 'maven:3.9.6-eclipse-temurin-17'
      //     args '-v /var/run/docker.sock:/var/run/docker.sock'
      //   }
      // }

      steps {
        script {
          // Unarchive the JAR file from the build
          unarchive mapping: ['target/spring-petclinic-3.4.0-SNAPSHOT.jar': 'spring-petclinic-3.4.0-SNAPSHOT.jar']

          // We use a withCredentials block to get the Nexus credentials
          withCredentials([usernamePassword(credentialsId: 'nexus-credentials', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASSWORD')]) {
              // ... (The rest of the script to create settings.xml and deploy) ...
              def mavenSettings = """<?xml version='1.0' encoding='UTF-8'?>
                  <settings xmlns='http://maven.apache.org/SETTINGS/1.0.0'
                      xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
                      xsi:schemaLocation='http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd'>
                      <servers>
                          <server>
                              <id>petclinic-maven-releases</id>
                              <username>\$NEXUS_USER</username>
                              <password>\$NEXUS_PASSWORD</password>
                          </server>
                          <server>
                              <id>petclinic-maven-releases-snapshot</id>
                              <username>\$NEXUS_USER</username>
                              <password>\$NEXUS_PASSWORD</password>
                          </server>
                      </servers>
                  </settings>
              """
              writeFile(file: "settings.xml", text: mavenSettings)
              
              try {
                  echo "Deploying artifact to Nexus..."
                  sh "mvn deploy:deploy-file -Dfile=spring-petclinic-3.4.0-SNAPSHOT.jar -DrepositoryId=petclinic-maven-releases-snapshot -Durl=http://172.31.39.168:8081/repository/petclinic-maven-releases-snapshot/ -s settings.xml"
              } finally {
                  sh 'rm settings.xml'
              }
          }
        }
      }
    }


    // // stage('Publish to Nexus') {
    // //   steps {
    // //     echo 'Uploading artifacts to Nexus...'
    // //     // Use withCredentials to securely access Nexus credentials from Jenkins
    // //     withCredentials([usernamePassword(credentialsId: NEXUS_CREDENTIAL_ID, passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USER')]) {
    // //       sh "mvn deploy -DaltDeploymentRepository=nexus::default::${NEXUS_URL} -DrepositoryId=nexus -Dnexus.username=${NEXUS_USER} -Dnexus.password=${NEXUS_PASSWORD}"
    // //     }
    // //   }
    // // }

    // stage('Push Docker Image') {
    //   steps {
    //     script {
    //         sh "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ECR_REPOSITORY_URI}"
            
    //         // sh "docker build -t ${DOCKER_IMAGE} ."
            
    //         echo "Pushing Docker image to ECR: ${DOCKER_IMAGE}"
    //         sh "docker push ${DOCKER_IMAGE}"
    //     }
    //   }
    // }

    // stage('Run Application for Scan') {
    //   steps {
    //     script {
    //       echo "Starting application container for ZAP scan..."
    //       def containerId = sh(returnStdout: true, script: "docker run -d -p 9090:8080 ${DOCKER_IMAGE}").trim()
          
    //       env.APP_CONTAINER_ID = containerId
          
    //       echo "Application container ID: ${APP_CONTAINER_ID}"
    //     }
    //   }
    // }

    // stage('Pulling ZAP Image') {
    //   steps {
    //     script {
    //       echo "Pulling ZAP Image from DockerHub..."

    //       sh 'docker pull zaproxy/zap-stable'
    //       sh 'docker run -dt --name owasp zaproxy/zap-stable /bin/bash'
    //     }
    //   }
    // }

    // stage('Check Application Health') {
    //   steps {
    //     script {
    //       env.hostIp = sh(script: 'hostname -I | cut -d" " -f1', returnStdout: true).trim()
    //       def checkUrl = "http://${hostIp}:9090/actuator/health"
    //       def maxAttempts = 60
    //       def attempt = 0
    //       def httpCode

    //       while (attempt < maxAttempts) {
    //         echo "Attempt ${attempt + 1} of ${maxAttempts}: Checking service availability at ${checkUrl}..."
            
    //         httpCode = sh(
    //           script: "curl -s -o /dev/null -L -w '%{http_code}' ${checkUrl} || true",
    //           returnStdout: true
    //         ).trim()
            
    //         if (httpCode == "200") {
    //           echo "Service is up and running! Proceeding with ZAP scan."
    //           break
    //         } else {
    //           echo "Service not yet ready. Status code: ${httpCode}. Waiting 5 seconds..."
    //           sh "sleep 5"
    //           attempt++
    //         }
    //       }

    //       if (httpCode != "200") {
    //         echo "Error: Service failed to become ready after ${maxAttempts * 5} seconds."
    //         error("Application health check failed.")
    //       }
    //     }
    //   }
    // }

    // stage('Creating ZAP Directory to store report') {
    //   steps {
    //     script {
    //       echo "Creating directory..."
    //       sh 'docker exec owasp mkdir /zap/wrk'
    //     }
    //   }
    // }


    // stage('ZAP Baseline Scan') {
    //   steps {
    //     script {
    //       echo "Running ZAP Baseline Scan..."
    //       def zapUrl = "http://${hostIp}:9090"

    //       echo "Running ZAP Baseline Scan...${zapUrl}"
    //       sh """
    //           docker exec owasp \
    //           zap-baseline.py \
    //           -t ${zapUrl} \
    //           -r zap_report.html \
    //           -I
    //         """
    //     }
    //   }
    // }


    // stage('Copy ZAP Report') {
    //   steps {
    //     script {
    //       echo "Archiving ZAP Report..."
    //       sh '''
    //           docker cp owasp:/zap/wrk/zap_report.html ${WORKSPACE}/zap_report.html
    //          '''
    //     }
    //   }
    // }


    // stage('Archive ZAP Report') {
    //   steps {
    //     script {
    //       echo "Archiving ZAP Report..."

    //       archiveArtifacts artifacts: 'zap_report.html', fingerprint: true
    //     }
    //   }
    // }


    // stage('Deploy to Elastic Beanstalk') {
    //   steps {
    //     script {
    //         echo "Starting deployment to Elastic Beanstalk..."

    //         unarchive mapping: ['target/spring-petclinic-3.4.0-SNAPSHOT.jar': 'app.jar']

    //         echo "Packaging JAR into a deployment bundle..."
    //         sh "zip -j ${ZIP_FILE_PATH} app.jar"

    //         echo "Uploading deployment bundle to S3..."
    //         sh "aws s3 cp ${ZIP_FILE_PATH} s3://${S3_BUCKET}/${ZIP_FILE_PATH}"
            
    //         echo "Creating new application version in Elastic Beanstalk..."
    //         sh "aws elasticbeanstalk create-application-version --application-name ${EB_APP_NAME} --version-label ${VERSION_LABEL} --source-bundle S3Bucket=${S3_BUCKET},S3Key=${ZIP_FILE_PATH}"

    //         echo "Updating Elastic Beanstalk environment..."
    //         sh "aws elasticbeanstalk update-environment --environment-name ${EB_ENV_NAME} --version-label ${VERSION_LABEL}"
            
    //         echo "Deployment to Elastic Beanstalk initiated successfully!"
    //     }
    //   }
    // }



    // stage('Deploy to EC2 via SSM') {
    //   steps {
    //     script {
    //         // Use the existing environment variables
    //         def ec2InstanceId = 'i-036b27fe576a906d4' // Still need to get this from somewhere
    //         def imageTag = env.BUILD_NUMBER
    //         def fullImageUri = "${env.DOCKER_IMAGE}"
    //         def dockerContainerName = 'my-petclinic-app'
    //         def containerPort = '8080'
    //         def hostPort = '8080' // Or '9090' from our previous discussion

    //         def json_input = """
    //         {
    //           "InstanceIds": [
    //             "${ec2InstanceId}"
    //           ],
    //           "DocumentName": "AWS-RunShellScript",
    //           "Parameters": {
    //             "commands": [
    //               "aws ecr get-login-password --region ${env.AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${env.ECR_REPOSITORY_URI}",
    //               "docker stop ${dockerContainerName} || true",
    //               "docker rm ${dockerContainerName} || true",
    //               "docker stop \$(docker ps -a -q) || true",
    //               "docker rm \$(docker ps -a -q) || true",
    //               "docker rmi \$(docker images -a -q) || true",
    //               "docker pull ${fullImageUri}",
    //               "docker run -d -p ${hostPort}:${containerPort} --name ${dockerContainerName} ${fullImageUri}"
    //             ]
    //           }
    //         }
    //         """
            
    //         // Write the JSON to a temporary file
    //         writeFile(file: 'ssm-commands.json', text: json_input)

    //         // 2. Send the command and capture the CommandId
    //         def commandOutput = sh(
    //             script: "aws ssm send-command --cli-input-json file://ssm-commands.json --region us-east-1",
    //             returnStdout: true
    //         )
    //         def commandId = new groovy.json.JsonSlurper().parseText(commandOutput).Command.CommandId
    //         echo "SSM Command sent with ID: ${commandId}"

    //         // 3. Poll for the command status
    //         def commandStatus = "Pending"
    //         def maxAttempts = 20
    //         def attempts = 0
    //         def invocationOutput

    //         while ((commandStatus == "Pending" || commandStatus == "InProgress") && attempts < maxAttempts) {
    //             echo "Waiting for command ${commandId} to complete. Status: ${commandStatus}..."
    //             sleep 10
                
    //             invocationOutput = sh(
    //                 script: "aws ssm get-command-invocation --command-id ${commandId} --instance-id ${ec2InstanceId} --region us-east-1",
    //                 returnStdout: true
    //             )
    //             commandStatus = new groovy.json.JsonSlurper().parseText(invocationOutput).Status
    //             attempts++
    //         }

    //         // 3. Check the final status and output
    //         if (commandStatus == "Success") {
    //             echo "SSM command completed successfully!"
    //         } else {
    //             echo "SSM command failed. Final status: ${commandStatus}"
    //             error("SSM deployment failed. Check the SSM console for more details.")
    //         }

    //         // Clean up the temporary file
    //         sh 'rm ssm-commands.json'
    //     }
    //   }
    // }

    // stage('Output Application Endpoint') {
    //   steps {
    //     script {
    //         def ec2InstanceId = 'i-036b27fe576a906d4' // The ID of your target EC2 instance
    //         def applicationPort = '8080' // The host port you are using

    //         echo "Retrieving the public IP address of the EC2 instance..."
    //         sleep 10 
            
    //         // Use the aws ec2 describe-instances command to get the public IP address
    //         def ipAddress = sh(
    //             script: "aws ec2 describe-instances --instance-ids ${ec2InstanceId} --query 'Reservations[0].Instances[0].PublicIpAddress' --output text",
    //             returnStdout: true
    //         ).trim()
            
    //         def endpointUrl = "http://${ipAddress}:${applicationPort}"
            
    //         echo "****************************************************************"
    //         echo "Application has been successfully deployed!"
    //         echo "You can access it at: ${endpointUrl}"
    //         echo "****************************************************************"
    //     }
    //   }
    // }


    // stage('Output Elastic Beanstalk Endpoint') {
    //   steps {
    //     script {
    //         def ebAppName = 'petclinic'
    //         def ebEnvName = 'petclinic-env-1'

    //         echo "Retrieving the Elastic Beanstalk endpoint..."

    //         // Get the CNAME of the environment
    //         def cname = sh(
    //             script: "aws elasticbeanstalk describe-environments --application-name ${ebAppName} --environment-names ${ebEnvName} --query 'Environments[0].CNAME' --output text",
    //             returnStdout: true
    //         ).trim()
            
    //         def endpointUrl = "http://${cname}"
            
    //         echo "****************************************************************"
    //         echo "Deployment to Elastic Beanstalk completed!"
    //         echo "You can access your application at: ${endpointUrl}"
    //         echo "****************************************************************"
    //     }
    //   }
    // }
  }
  



  post {
      always {
        echo 'Cleaning up...'

        echo "Cleaning up temporary deployment files..."
        sh "rm -f ${ZIP_FILE_PATH}"

        echo 'Stopping all running containers...'
        sh 'docker stop $(docker ps -a -q) || true'

        echo 'Removing all stopped containers...'
        sh 'docker rm $(docker ps -a -q) || true'

        echo 'Pausing for 5 seconds...'
        sh 'sleep 5'

        echo 'Removing all images...'
        sh 'docker rmi $(docker images -a -q) || true'

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
