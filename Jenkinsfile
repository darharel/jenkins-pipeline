pipeline {
    environment {
        registry = "darharel/dhrepo"
        EC2_IP = "172.31.16.45"
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
                    sh 'docker rm -f weather_app || true'
                    sh 'docker run --name weather_app -d -p 5000:8000 $registry'
                    sh 'sleep 3'
                    sh 'python3 tests.py'
                    sh 'docker stop weather_app'
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
                    sh '''
                        echo "$DOCKERHUB_KEY" | docker login -u "$DOCKERHUB_USER" --password-stdin
                        docker push $registry
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'gitkp',
                    keyFileVariable: 'SSH_KEY'
                )]) {
                    sh '''
                        ssh-keyscan $EC2_IP >> ~/.ssh/known_hosts
                        ssh -i $SSH_KEY ec2-user@$EC2_IP docker rm -f app || true
                        ssh -i $SSH_KEY ec2-user@$EC2_IP docker run -d --name app -p 80:8000 $registry
                    '''
                }
            }
        }
    }

    post {
        success {
            slackSend(channel: 'cicd', color: "good", message: "✅ SUCCESS! Build: ${BUILD_NUMBER}, Commit: ${GIT_COMMIT}")
        }
        failure {
            slackSend(channel: 'cicd', color: "danger", message: "❌ FAILED! Build: ${BUILD_NUMBER}, Commit: ${GIT_COMMIT}")
        }
    }
}
