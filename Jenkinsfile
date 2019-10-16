def buildParameterMap = [:]
buildParameterMap['appName'] = 'docker-jenkins-jnlp-slave'
buildParameterMap['buildStrategy'] = [
 '*': [ 'checkout', 'build', 'containerize'
 ]
]

buildAndDeployGeneric(buildParameterMap)

// vim: set ft=groovy:
