pipelineJob('todo') {
    description('Sample todo list application for DevOps course')
    keepDependencies(false)
    disabled(false)
    
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('http://gogs.local:3000/owner/todo.git')
                    }
                    branches('*/*')
                    extensions {}
                }
            }
            scriptPath('Jenkinsfile')
            lightweight(true)
        }
    }
    
    triggers {
        // No triggers defined
    }
}
