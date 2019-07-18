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

{ #category : #test }
GMMSEGeneratorWizardTest >> javaSourcePathForTesting [
	| path |
	"path := '/mnt/c/Users/fuhrm/Documents/GitHub/FactoryVariants' asFileReference."
	path := 'C:/Users/fuhrm/Documents/GitHub/FactoryVariants' asFileReference.
	path exists
		ifFalse: [ self
				error:
					'The path to the Java sources needs defining. It must be valid in a Bourne Shell. See https://fuhrmanator.github.io/2019/03/16/LibC-Pharo-experiments.html' ].
	^ path
]

{ #category : #test }
GMMSEGeneratorWizardTest >> mseDestinationPathForTesting [
	| path |
	"path := '/home/cfuhrman/FactoryVariants.mse' asFileReference."
	path := 'c:/users/fuhrm/Desktop/FactoryVariants.mse' asFileReference.
	path parent exists
		ifFalse: [ self
				error:
					'The path to the MSE output directory needs defining. It must be valid in a Bourne Shell. See https://fuhrmanator.github.io/2019/03/16/LibC-Pharo-experiments.html' ].
	^ path
]

{ #category : #running }
GMMSEGeneratorWizardTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."
	super setUp.
	wizard := GMMSEGeneratorWizard new.
]

{ #category : #test }
GMMSEGeneratorWizardTest >> testGenerateMSE [
	wizard
		verveineJScriptPath: self verveineJScriptPathForTesting;
		javaSourcePath: self javaSourcePathForTesting;
		mseDestinationPath: self mseDestinationPathForTesting.
	self mseDestinationPathForTesting ensureDelete.
	wizard generateMSE.
	self assert: wizard mseDestinationPath asFileReference exists
]

{ #category : #test }
GMMSEGeneratorWizardTest >> testJavaSourcePath [
	| path |
	path := '/mnt/myproject/src' asFileReference .
	wizard javaSourcePath: path.
	self assert: wizard javaSourcePath equals: path
]

{ #category : #test }
GMMSEGeneratorWizardTest >> testMseDestinationPath [
	| path |
	path := '/mnt/myproject/src' asFileReference .
	wizard mseDestinationPath: path.
	self assert: wizard mseDestinationPath equals: path
]

{ #category : #tests }
GMMSEGeneratorWizardTest >> testVerveineJScriptPath [
	"should return a file path that ends with verveinej.sh"
	| expectedPath path |
	expectedPath := self verveineJScriptPathForTesting.
	wizard verveineJScriptPath: expectedPath.
	path := wizard verveineJScriptPath.
	self assert: expectedPath equals: path.
]

{ #category : #test }
GMMSEGeneratorWizardTest >> verveineJScriptPathForTesting [
	| path |
"	path := '/mnt/c/Users/fuhrm/Documents/git_repos/VerveineJ/verveinej.sh' asFileReference."
	path := 'c:/Users/fuhrm/Documents/git_repos/VerveineJ/verveinej_bourne_shell.sh' asFileReference.
	path exists
		ifFalse: [ self
				error:
					'The path to the VerveineJ.sh script needs defining. It must be valid in a Bourne Shell. See https://fuhrmanator.github.io/2019/03/16/LibC-Pharo-experiments.html' ].
	^ path
]