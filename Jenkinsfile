pipeline {
    agent any

    environment {
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        AWS_DEFAULT_REGION = 'ap-south-1'
    }

    stages {
        stage('Checkout Infra') {
            steps {
                git url: 'https://github.com/nawin34/fullstack-aws.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('.') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Checkout Backend') {
            steps {
                git url: 'https://github.com/nawin34/fullstack-springboot.git'
            }
        }

        stage('Run Backend Tests') {
            steps {
                sh './mvnw test'
            }
        }

        stage('Build Backend') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Deploy Backend to EC2') {
            steps {
                sshagent(['ec2-key']) {
                    sh '''
                    scp -o StrictHostKeyChecking=no target/*.jar ec2-user@<ec2-ip>:/home/ec2-user/app.jar
                    ssh -o StrictHostKeyChecking=no ec2-user@<ec2-ip> "pkill -f 'java' || true"
                    ssh -o StrictHostKeyChecking=no ec2-user@<ec2-ip> "nohup java -jar app.jar > app.log 2>&1 &"
                    '''
                }
            }
        }

        stage('Checkout Frontend') {
            steps {
                git url: 'https://github.com/nawin34/fullstack-react.git'
            }
        }

        stage('Build Frontend') {
            steps {
                sh '''
                npm install
                npm run build
                '''
            }
        }

        stage('Upload to S3') {
            steps {
                withAWS(credentials: 'aws-cli-creds') {
                    sh '''
                    aws s3 sync dist/ s3://akki-react-frontend-2025/ --delete
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Backend + Frontend CI/CD pipeline completed successfully.'
        }
        failure {
            echo '❌ Something went wrong. Check the logs.'
        }
    }
}
