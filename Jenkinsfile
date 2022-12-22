 def scan_type
 def host
 def SendEmailNotification(String result) {
  
    // config 
    def to = emailextrecipients([
           requestor()
    ])
    
    // set variables
    def subject = "${env.JOB_NAME} - Build #${env.BUILD_NUMBER} ${result}"
    def content = '${JELLY_SCRIPT,template="html"}'

    // send email
    if(to != null && !to.isEmpty()) {
        env.ForEmailPlugin = env.WORKSPACE
        emailext mimeType: 'text/html',
        body: '${FILE, path="/var/lib/jenkins/workspace/springboot/report.html"}',
        subject: currentBuild.currentResult + " : " + env.JOB_NAME,
        to: to, attachLog: true
    }
}

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
	    
// 	    stage('Build'){

//             steps{

//                 sh 'mvn clean'
//             }

//        }
	    
// 	    stage('Test'){

//             steps{

//                 sh 'mvn test'
//             }

//        }

//        stage('SonarQube analysis') {

//             steps{

//                 withSonarQubeEnv('sonarqube-9.7.1') { 

//                           //sh "sudo rm ~/.m2/repository/org/owasp/dependency-check-data/7.0/jsrepository.json"

//                     sh "mvn test -Dtest=TestControllerTests  -DfailIfNoTests=false"

//                     sh "mvn clean install sonar:sonar -Dsonar.login=admin -Dsonar.password=sonar"

//                 }

//             }

//         }


// 	    stage('Build Docker Image') {
// 		    steps {
// 			    sh 'whoami'
// 			    sh 'sudo chmod 777 /var/run/docker.sock'
			    
// 			    sh 'sudo apt update'
//  			    sh 'sudo apt install software-properties-common'
// 			    sh 'sudo add-apt-repository ppa:cncf-buildpacks/pack-cli'
			    
//  				sh 'sudo  apt-get update'
//  				sh 'sudo apt-get install pack-cli'
			   
// 			    sh 'mvn spring-boot:build-image'
// 				sh 'docker tag docker.io/library/spring-boot-complete:0.0.1-SNAPSHOT gcr.io/tech-rnd-project/java'
			    
// 		    }
// 	    }
	    
// 	    stage("Push Docker Image") {
// 		    steps {
// 			    script {
// 				echo "Push Docker Image"
// 				sh 'gcloud auth configure-docker'
// 				sh "sudo docker push gcr.io/tech-rnd-project/java"
				
// 				sh 'curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl'

// 				sh "chmod +x kubectl"

// 				sh "sudo mv kubectl \$(which kubectl)"

				    
// 			    }
// 		    }
// 	    }
	    
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
	    
	    stage('Zap Installation') {
                    steps {
				    
			sh 'docker rm -f owasp'   
                        sh 'echo "Hello World"'
			sh '''
			    echo "Pulling up last OWASP ZAP container --> Start"
			    docker pull owasp/zap2docker-stable
			    
			    echo "Starting container --> Start"
			    docker run -dt --name owasp \
    			    owasp/zap2docker-stable \
    			    /bin/bash
			    
			    
			    echo "Creating Workspace Inside Docker"
			    docker exec owasp \
    			    mkdir /zap/wrk
			'''
			    }
		    }
	    stage('Scanning target on owasp container') {
             steps {
                 script {
		     sh 'sleep 10'
			sh 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True'
			 gcloud auth activate-service-account 460440866465-compute@developer.gserviceaccount.com \
          --key-file <(echo $(key)  | base64 -d)
          (echo $(key) | base64 -d) > $HOME/.config/gcloud/application_default_credentials.json  
			
			sh 'gcloud container clusters get-credentials network18-cluster --zone us-central1-a --project tech-rnd-project'
			sh 'kubectl get pods'	
			sh 'kubectl get service java-app > intake.txt'
			sh """
			
				awk '{print \$4}' intake.txt > extract.txt
                        """
			IP = sh (
        			script: 'grep -Eo "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" extract.txt > finalout.txt && ip=$(cat finalout.txt) && aa="http://${ip}" && echo $aa',
        			returnStdout: true
    			).trim()
    			echo "Git committer email: ${IP}"
		 
	      
	    	     
			 
                       scan_type = "${params.SCAN_TYPE}"
                       echo "----> scan_type: $scan_type"
			 
			
		       
			 
                       if(scan_type == "Baseline"){
                           sh """
                               docker exec owasp \
                               zap-baseline.py \
                               -t ${IP} \
                               -r report.html \
                               -I
                           """
                       }
                       else if(scan_type == "APIS"){
                           sh """
                               docker exec owasp \
                               zap-api-scan.py \
                               -t ${IP}\
                               -r report.html \
                               -I
                           """
                       }
                       else if(scan_type == "Full"){
                           sh """
                               docker exec owasp \
                               zap-full-scan.py \
                               -t ${IP}\
                               //-x report.html
                               -I
                            """
                           //-x report-$(date +%d-%b-%Y).xml
                       }
                       else{
                           echo "Something went wrong..."
                       }
			sh '''
				docker cp owasp:/zap/wrk/report.html ${WORKSPACE}/report.html
				echo ${WORKSPACE}
				docker stop owasp
                     	docker rm owasp
			'''
			SendEmailNotification("SUCCESSFUL")
				    
		  }
	     }
	}
	    
    }
	post{
        always{
            emailext to: "divyashetbhatkal@gmail.com",
            subject: "jenkins build:${currentBuild.currentResult}: ${env.JOB_NAME}",
            body: "${currentBuild.currentResult}: Job ${env.JOB_NAME}\nMore Info can be found here: ${env.BUILD_URL}"
        }	
    }
	
}
