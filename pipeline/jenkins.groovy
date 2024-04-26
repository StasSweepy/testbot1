pipeline {
    agent any

    parameters {
        choice(name: 'OS', choices: ['linux', 'darwin', 'windows'], description: 'OS')
        choice(name: 'ARCH', choices: ['amd64', 'arm', '386'], description: 'ARCH')
    }

    environment {
        REPO = 'https://github.com/StasSweepy/testbot1'
        GITHUB = credentials('github')
        BRANCH = 'main'
        TARGETARCH = "${params.ARCH}"
        TARGETOS = "${params.OS}"
    }

    stages {
        stage('Install Make') {
            steps {
                sh 'sudo apt-get update && sudo apt-get install -y make'
            }
        }

        stage('clone') {
            steps {
                echo 'Clone Repository'
                git branch: "${BRANCH}", url: "${REPO}"
            }
        }

        stage('image') {
            steps {
                echo "Building image started"
                sh "make image"
            }
        }

        stage('login to GHCR') {
            steps {
                withCredentials([string(credentialsId: 'your_token_credentials_id', variable: 'GITHUB_TOKEN')]) {
                    sh "login ghcr.io -u your_github_username -p $GITHUB_TOKEN"
        }
    }
}

        
        stage('push image') {
            steps {
              sh "make push"
            }
        } 
    }

    post {
        always {
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true)
        }
    }
}