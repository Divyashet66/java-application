pipeline {
  agent any

	tools {
		 maven 'Maven'
	}
	environment {
		PROJECT_ID = 'tech-rnd-project'
                CLUSTER_NAME = 'network18-cluster'
                LOCATION = 'us-central1-a'
                CREDENTIALS_ID = 'kubernetes'	
	}
	
    stages {
	    stage('Scm Checkout') {
		    steps {
			    	checkout scm
		    }
	    }
	    
	    stage('Build'){

            steps{

                sh 'mvn clean'

                

            }

       }

       stage('SonarQube analysis') {

            steps{

                withSonarQubeEnv('sonarqube-9.7.1') { 

                          //sh "sudo rm ~/.m2/repository/org/owasp/dependency-check-data/7.0/jsrepository.json"

                    sh "mvn test -Dtest=TestControllerTests  -DfailIfNoTests=false"

                    sh "mvn clean install sonar:sonar -Dsonar.login=admin -Dsonar.password=sonar"

                }

            }

        }

        stage('Quality'){

            steps{

                script{

                    sleep(10)

                    //qualitygate = waitForQualityGate()

                    //if (qualitygate.status != "OK") {

                      //  currentBuild.result = "FAILURE"

                        //slackSend (channel: '****', color: '#F01717', message: "$JOB_NAME, <$BUILD_URL|Build #$BUILD_NUMBER>: Code coverage threshold was not met! <http://****.com:9000/sonarqube/projects|Review in SonarQube>.")

                    //}

                

                    waitForQualityGate abortPipeline: true                  

                }

            }

       }

	    stage('Build Docker Image') {
		    steps {
			    sh 'whoami'
			    sh 'sudo chmod 777 /var/run/docker.sock'
			    
			    sh ' sudo apt update'
 			    sh 'sudo apt install software-properties-common -y'
			    

			    
				    
				sh 'sudo add-apt-repository ppa:cncf-buildpacks/pack-cli'
			    
 				 sh 'sudo  apt-get update'
 				  sh 'sudo apt-get install pack-cli'
			   
				  sh 'pack build java -t gcr.io/tech-rnd-project/java --builder cnbs/sample-builder:bionic'
			    
		    }
	    }
	    
	    stage("Push Docker Image") {
		    steps {
			    script {
				    echo "Push Docker Image"
				        sh 'gcloud auth configure-docker'
				        sh "sudo docker push gcr.io/tech-rnd-project/java"
				    
					sh 'curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl'

					sh "chmod +x kubectl"

					sh "sudo mv kubectl \$(which kubectl)"

				    
			    }
		    }
	    }
	    
	    stage('Deploy to K8s') {
		    steps{
			    echo "Deployment started ..."
			    sh 'ls -ltr'
			    sh 'pwd'
				
				echo "Start deployment of deployment.yaml"
				step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME, location: env.LOCATION, manifestPattern: 'k8', credentialsId: env.CREDENTIALS_ID, verifyDeployments: true])
			    	echo "Deployment Finished ..."
			    sh '''
			    '''
			    
		    }
	    }
    }
}
