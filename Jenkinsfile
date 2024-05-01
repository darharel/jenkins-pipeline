pipeline {
    environment {
        registry = "darharel/dhrepo"
        key = credentials("gitkp")
    }

    agent any

    stages {
        stage('Build Image') {
            steps {
                script {
                    echo 'Running Build image stage'
                    sh 'docker build -t $registry .'

                }
            }
        }
        stage('Test Image') {
            steps {
                script {
                    echo 'Running Tests stage'
                    sh 'docker rm -f weather_app'
                    sh 'docker run --name weather_app -d -p 5000:8000 $registry'
                    sh 'sleep 3'
                    sh 'python3 tests.py'
                }
            }
        }
        stage('Publish') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhubCred',
                    usernameVariable: 'DOCKERHUB_USER',
                    passwordVariable: 'DOCKERHUB_KEY'
                )]) {
                    sh 'docker login -u $DOCKERHUB_USER -p $DOCKERHUB_KEY'
                    sh 'docker push $registry'
                    sh 'docker logout'
                }

            }
        }
        stage('Deploy') {
              steps {
                   sh 'echo $key'
                   sh 'echo $key'
                   sh 'ssh-keyscan 172.31.16.45 >>  /home/ubuntu/.ssh/authorized_keys'
                   sh 'ssh -v -o UserKnownHostsFile=/home/ubuntu/.ssh/authorized_keys -i $key ec2-user@172.31.16.45 docker rm -f app'
                   sh 'ssh -v -o UserKnownHostsFile=/home/ubuntu/.ssh/authorized_keys -i $key ec2-user@172.31.16.45 docker run -d --name app -p 80:8000 $registry'
            }
        }
    }

    post {
        success {
            slackSend(channel: 'cicd', color: "good", message: "SUCCESS! Build:${BUILD_NUMBER} commit: ${GIT_COMMIT}")
        }
         failure {
            slackSend(channel: 'cicd', color: "danger", message: "FAILED! Build:${BUILD_NUMBER} commit: ${GIT_COMMIT}")
        }
    }
}
