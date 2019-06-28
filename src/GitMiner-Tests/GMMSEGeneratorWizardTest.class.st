"
A GMMSEGeneratorWizardTest is a test class for testing the behavior of GMMSEGeneratorWizard
"
Class {
	#name : #GMMSEGeneratorWizardTest,
	#superclass : #TestCase,
	#instVars : [
		'wizard'
	],
	#category : #'GitMiner-Tests'
}

{ #category : #running }
GMMSEGeneratorWizardTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."
	super setUp.
	wizard := GMMSEGeneratorWizard new.
]

{ #category : #test }
GMMSEGeneratorWizardTest >> testGenerateMSE [
	wizard
		verveineJScriptPath: '/mnt/c/Users/fuhrm/Documents/git_repos/VerveineJ/verveinej.sh';
		javaSourcePath: '/mnt/c/Users/fuhrm/Documents/GitHub/FactoryVariants';
		mseDestinationPath:
			'/mnt/c/Users/fuhrm/Documents/GitHub/FactoryVariants/FactoryVariants.mse'.
	wizard generateMSE.
	self assert: wizard mseDestinationPath asFileReference exists.
]

{ #category : #test }
GMMSEGeneratorWizardTest >> testJavaSourcePath [
	| path |
	path := '/mnt/myproject/src'.
	wizard javaSourcePath: path.
	self assert: wizard javaSourcePath equals: path
]

{ #category : #test }
GMMSEGeneratorWizardTest >> testMseDestinationPath [
	| path |
	path := '/mnt/myproject/src'.
	wizard mseDestinationPath: path.
	self assert: wizard mseDestinationPath equals: path
]

{ #category : #tests }
GMMSEGeneratorWizardTest >> testVerveineJScriptPath [
	"should return a file path that ends with verveinej.sh"
	| path |
	path := wizard verveineJScriptPath.
	self assert: (path asString endsWith: 'verveinej.sh').
]
