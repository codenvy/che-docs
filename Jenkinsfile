pipeline {

  agent {
    kubernetes {
      label 'che-docs-pod'
      yaml """
apiVersion: v1
metadata:
  labels:
    run: che-docs-pod
  name: che-docs-pod
spec:
  containers:
    - name: jnlp
      volumeMounts:
      - mountPath: /home/jenkins/.ssh
        name: volume-known-hosts
      env:
      - name: "HOME"
        value: "/home/jenkins/agent"
    - name: che-docs
      image: quay.io/eclipse/che-docs
      command:
      - cat
      tty: true
  volumes:
  - configMap:
      name: known-hosts
    name: volume-known-hosts
"""
    }
  }

  environment {
    PROJECT_NAME = "che"
    PROJECT_BOT_NAME = "CHE Bot"
    CI = true
  }

  triggers { pollSCM('H/10 * * * *')

 }

  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
    checkoutToSubdirectory('che-docs')
    disableConcurrentBuilds()
    timeout(time: 15, unit: 'MINUTES')
  }

  stages {

    stage('Checkout www repo (master)') {
      when {
        branch 'master'
        beforeAgent true
      }
      steps {
        milestone 1
        container('jnlp') {
          dir('www') {
            sshagent(['git.eclipse.org-bot-ssh']) {
                sh '''
                    GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git clone ssh://genie.${PROJECT_NAME}@git.eclipse.org:29418/www.eclipse.org/${PROJECT_NAME}.git .
                    git checkout master
                '''
            }
          }
        }
        milestone 2
      }
    }

    stage('Build che-docs website') {
      steps {
        milestone 21
        container('che-docs') {
          dir('che-docs') {
                sh './tools/publication.sh'
            }
        }
        milestone 22
      }
    }

    stage('Push to www repo (master)') {
      when {
        branch 'master'
        beforeAgent true
      }
      steps {
        milestone 41
        sh 'ls -la'
        dir('www') {
            sshagent(['git.eclipse.org-bot-ssh']) {
                sh '''
                cd "${WEBSITE}"
                rm -rf docs/
                mkdir -p docs
                cp -Rvf ../che-docs/build/site/* docs/
                git add -A
                if ! git diff --cached --exit-code; then
                  echo "Changes have been detected, publishing to repo 'www.eclipse.org/${PROJECT_NAME}'"
                  git config --global user.email "${PROJECT_NAME}-bot@eclipse.org"
                  git config --global user.name "${PROJECT_BOT_NAME}"
                  export DOC_COMMIT_MSG=$(git log --oneline --format=%B -n 1 HEAD | tail -1)
                  git commit -s -m "[docs] ${DOC_COMMIT_MSG}"
                  git log --graph --abbrev-commit --date=relative -n 5
                  git push origin HEAD:master
                else
                  echo "No change have been detected since last build, nothing to publish"
                fi
                '''
            }
        }
        milestone 42
      }
    }

  }

  post {
    always {
      archiveArtifacts artifacts: 'che-docs/build/**', fingerprint: true
    }
  }

}


