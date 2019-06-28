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

{ #category : #tests }
GMMSEGeneratorWizardTest >> testVerveineJScriptPath [
	"should return a file path that ends with verveinej.sh"
	| path |
	path := wizard verveineJScriptPath.
	self assert: path asString endsWith: 'verveinej.sh'.
]
