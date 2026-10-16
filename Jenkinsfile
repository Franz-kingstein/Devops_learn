// Declarative Jenkinsfile for DevOps IA-3 Flask app on Azure VM
// Runs on Ubuntu Jenkins controller (sh steps), Jenkins user = 'jenkins'
// Plugins required: SSH Agent (sshagent), JUnit, Timestamper

pipeline {
    agent any

    // Pipeline options: build retention, timestamps, timeouts
    options {
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '5'))
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    // Shared values used across stages
    environment {
        VM_IP          = "${env.VM_IP}"                 // Set in Jenkins env (Manage Jenkins > System)
        VM_USER        = "franz"                        // VM admin username (terraform admin_username)
        APP_DIR        = '/opt/app'                      // Deployment directory on the VM
        APP_VERSION    = "1.0.0-${env.BUILD_NUMBER}"     // Version injected into the app
        VENV_DIR       = '.venv'                         // Python venv inside workspace
        DEPLOY_REACHED = "false"                         // Track if Deploy stage was reached
    }

    stages {

        // ---------- Stage 1: Checkout ----------
        // Pull the code from GitHub into the Jenkins workspace.
        // 'checkout scm' reads the repo URL/branch from the job config.
        stage('Checkout') {
            steps {
                checkout scm
                sh 'echo "Checked out commit: $(git rev-parse --short HEAD)"'
            }
        }

        // ---------- Stage 2: Install & Lint ----------
        // Create an isolated Python virtual env so we never touch the
        // system Python. Install deps, then run flake8 style checks.
        // If flake8 finds issues it exits non-zero and the build fails.
        stage('Install & Lint') {
            steps {
                sh '''
                    python3 -m venv "$VENV_DIR"
                    . "$VENV_DIR/bin/activate"
                    pip install --upgrade pip
                    pip install -r app/requirements.txt
                    flake8 app --max-line-length=120
                '''
            }
        }

        // ---------- Stage 3: Test ----------
        // Run pytest inside the venv. JUnit XML is written so Jenkins
        // can render test results and trends on the job page.
        stage('Test') {
            steps {
                sh '''
                    . "$VENV_DIR/bin/activate"
                    mkdir -p reports
                    APP_VERSION="$APP_VERSION" pytest app/tests -v \
                        --junitxml=reports/pytest-results.xml
                '''
            }
            post {
                always {
                    // Publishes test results (pass/fail counts, history)
                    junit allowEmptyResults: true, testResults: 'reports/pytest-results.xml'
                }
            }
        }

        // ---------- Stage 4: Package ----------
        // Archive the app folder as a build artifact so we keep a record
        // of exactly what was tested. Useful for audits/rollback.
        stage('Package') {
            steps {
                sh '''
                    mkdir -p reports
                    APP_VERSION="$APP_VERSION" echo "$APP_VERSION" > app/VERSION
                '''
                archiveArtifacts artifacts: 'app/**', fingerprint: true,
                                 excludes: '**/__pycache__/**, **/*.pyc'
            }
        }

        // ---------- Stage 5: Terraform Validate ----------
        // Static validation only - NO apply/destroy here.
        // fmt -check fails if files are not formatted, init downloads
        // providers (no backend state), validate checks the config.
        stage('Terraform Validate') {
            steps {
                sh '''
                    cd terraform
                    terraform fmt -check -recursive
                    terraform init -backend=false -input=false
                    terraform validate
                '''
            }
        }

        // ---------- Stage 6: Deploy ----------
        // sshagent injects the SSH private key (credential id
        // 'azure-vm-ssh') for the duration of the block.
        // We scp deploy.sh to the VM and execute it.
        // deploy.sh does: clone/pull code, save previous commit,
        // rebuild containers with docker compose.
        stage('Deploy') {
            steps {
                // Mark that we've reached the Deploy stage (for rollback logic)
                sh 'echo "DEPLOY_REACHED=true" >> $WORKSPACE/.deploy_status'
                sshagent(credentials: ['azure-vm-ssh']) {
                    sh '''
                        scp -o StrictHostKeyChecking=accept-new \
                            -o UserKnownHostsFile="$WORKSPACE/.ssh_known_hosts" \
                            scripts/deploy.sh "$VM_USER@$VM_IP:/tmp/deploy.sh"

                        ssh -o StrictHostKeyChecking=accept-new \
                            -o UserKnownHostsFile="$WORKSPACE/.ssh_known_hosts" \
                            "$VM_USER@$VM_IP" \
                            "APP_VERSION=$APP_VERSION bash /tmp/deploy.sh"
                    '''
                }
            }
        }

        // ---------- Stage 7: Smoke Test ----------
        // Verify the app really responds after deploy.
        // Retry up to 5 times (containers may need a few seconds),
        // exit non-zero on first success, fail build if never healthy.
        stage('Smoke Test') {
            steps {
                sh '''
                    echo "Smoke testing http://$VM_IP/health ..."
                    attempt=1
                    while [ $attempt -le 5 ]; do
                        if curl -fs "http://$VM_IP/health"; then
                            echo ""
                            echo "Smoke test PASSED on attempt $attempt"
                            exit 0
                        fi
                        echo "Attempt $attempt failed, retrying in 10s..."
                        sleep 10
                        attempt=$((attempt + 1))
                    done
                    echo "Smoke test FAILED after 5 attempts"
                    exit 1
                '''
            }
        }
    }

    // ---------- Post-build Actions ----------
    post {
        failure {
            // Only rollback if Deploy stage was reached (check status file)
            script {
                def deployReached = fileExists('.deploy_status') &&
                    readFile('.deploy_status').contains('DEPLOY_REACHED=true')
                if (deployReached) {
                    echo "Deploy stage was reached! Rolling back on VM $VM_IP ..."
                    sshagent(credentials: ['azure-vm-ssh']) {
                        sh '''
                            scp -o StrictHostKeyChecking=accept-new \
                                -o UserKnownHostsFile="$WORKSPACE/.ssh_known_hosts" \
                                scripts/rollback.sh "$VM_USER@$VM_IP:/tmp/rollback.sh" || true

                            ssh -o StrictHostKeyChecking=accept-new \
                                -o UserKnownHostsFile="$WORKSPACE/.ssh_known_hosts" \
                                "$VM_USER@$VM_IP" "bash /tmp/rollback.sh" || true
                        '''
                    }
                } else {
                    echo "Deploy stage not reached - no rollback needed"
                }
            }
        }
        success {
            echo "Build succeeded!"
            echo "App URL:     http://$VM_IP"
            echo "Health URL:  http://$VM_IP/health"
            echo "Version:     $APP_VERSION"
        }
        always {
            // Clean workspace LAST so scripts/rollback.sh exists during failure handling
            cleanWs()
        }
    }
}