#!groovy

// This pipeline's code is in https://github.com/the-mama-ai/jenkins-build-shared


mamaPythonK8sDeploy('excalidraw',
                    deployMode: 'helm',  
                    bypassUnitTestStage: false,
                    minimalCodeCoverage: 5,
                    deployDestinations: [
                        'main': ['demo01', 'excalidraw'],
                        'develop': ['demo01', 'excalidraw-dev'],
                        ])