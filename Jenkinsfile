pipeline {

    agent any
 
    parameters {

        string(name: 'SOURCE_USER', defaultValue: 'cdudi', description: 'Username of source VM')

        string(name: 'SOURCE_HOST', defaultValue: '10.128.0.29', description: 'Source VM IP')
 
        choice(name: 'DEST_HOST', choices: ['ALL', '10.128.0.24', '10.128.0.28'], description: 'Single target or ALL')

        string(name: 'DEST_USER', defaultValue: 'cdudi', description: 'Username on target VMs')

        string(name: 'DEST_PATH', defaultValue: '/home/cdudi/', description: 'Target path')

        string(name: 'FILE_NAME', defaultValue: '/home/cdudi/sfile.csv', description: 'File path on source VM')

    }
 
    environment {

        ALL_HOSTS = '10.128.0.24,10.128.0.28'

    }
 
    stages {

        stage('Checkout GitHub Repo') {

            steps {

                git branch: 'main', url: 'https://github.com/Dudi-Chiranjeevi/sptestus4.git'

            }

        }
 
        stage('Parallel SCP from Source to Destinations') {

            steps {

                script {

                    def targetHosts = (params.DEST_HOST.trim() == 'ALL') 

                                      ? env.ALL_HOSTS.split(',') 

                                      : [params.DEST_HOST.trim()]
 
                    def parallelSteps = [:]
 
                    for (host in targetHosts) {

                        def cleanHost = host.trim()

                        parallelSteps["Transfer to ${cleanHost}"] = {

                            pwsh """

                                mkdir -p logs

                                echo "===== Transfer Start to ${cleanHost} =====" >> logs/transfer_${cleanHost}.log

                                ./migrate.ps1 `

                                      -SourceUser "${params.SOURCE_USER}" `

                                      -SourceHost "${params.SOURCE_HOST}" `

                                      -DestinationUser "${params.DEST_USER}" `

                                      -DestinationHosts "${cleanHost}" `

                                      -CsvFilePath "${params.FILE_NAME}" `

                                      -TargetPath "${params.DEST_PATH}" >> logs/transfer_${cleanHost}.log 2>&1

                                echo "===== Transfer End to ${cleanHost} =====" >> logs/transfer_${cleanHost}.log

                            """

                        }

                    }
 
                    parallel parallelSteps

                }

            }

        }

    }
 
    post {

        always {

            archiveArtifacts artifacts: 'logs/*.log', fingerprint: true
 
            emailext(

                subject: "${currentBuild.currentResult}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",

                body: """<p>Job ${currentBuild.currentResult}</p>
<p>Job: ${env.JOB_NAME}<br/>

Build Number: ${env.BUILD_NUMBER}<br/>
<a href='${env.BUILD_URL}'>View Build</a></p>""",

                to: 'chiranjeevigen@gmail.com',

                from: 'chiranjeevidudi3005@gmail.com',

                attachmentsPattern: 'logs/*.log'

            )

        }

    }

}