pipeline {
    agent any
    environment {
        APP_NAME        = 'cicd-demo-app'
        DOCKER_IMAGE    = "NikoTorres97/${APP_NAME}"
        DOCKER_TAG      = "${env.GIT_COMMIT?.take(7) ?: env.BUILD_NUMBER}"
        K8S_NAMESPACE   = 'production'
        DOCKERHUB_CREDS = credentials('dockerhub-credentials')
    }
    options {
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }
    triggers { githubPush() }
    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.GIT_AUTHOR = sh(script: 'git log -1 --pretty=%an', returnStdout: true).trim()
                }
                echo "Commit: ${env.GIT_COMMIT_SHORT} | Author: ${env.GIT_AUTHOR}"
            }
        }
        stage('Test') {
            agent { docker { image 'node:20-alpine'; args '-u root' } }
            steps { sh 'npm ci'; sh 'npm test' }
        }
        stage('Build Docker Image') {
            steps {
                script { docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}", "--no-cache .") }
            }
        }
        stage('Publish to Registry') {
            steps {
                script {
                    docker.withRegistry('https://docker.io', 'dockerhub-credentials') {
                        def img = docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}")
                        img.push("${DOCKER_TAG}")
                        img.push('latest')
                        img.push("build-${env.BUILD_NUMBER}")
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-credentials', variable: 'KUBECONFIG')]) {
                    sh """
                        kubectl set image deployment/${APP_NAME} ${APP_NAME}=${DOCKER_IMAGE}:${DOCKER_TAG} -n ${K8S_NAMESPACE}
                        kubectl annotate deployment/${APP_NAME} kubernetes.io/change-cause="Build #${BUILD_NUMBER} - ${GIT_COMMIT_SHORT}" -n ${K8S_NAMESPACE} --overwrite
                    """
                }
            }
        }
        stage('Verify Deployment') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-credentials', variable: 'KUBECONFIG')]) {
                    sh """
                        kubectl rollout status deployment/${APP_NAME} -n ${K8S_NAMESPACE} --timeout=300s
                        kubectl get pods -l app=${APP_NAME} -n ${K8S_NAMESPACE} -o wide
                    """
                }
            }
        }
    }
    post {
        success { echo "Pipeline exitoso - ${DOCKER_IMAGE}:${DOCKER_TAG}" }
        failure { echo "Pipeline fallido - Build #${env.BUILD_NUMBER}" }
        always { sh "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true"; cleanWs() }
    }
}
