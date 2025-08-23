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
                    git pull https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
                    sed -i "s|tejas1205/petclinic:.*|tejas1205/petclinic:${BUILD_NUMBER}|g" k8s/petclinic.yml
                    git add k8s/petclinic.yml
                    git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                    git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
                '''
            }
        }
    }
  }
}
