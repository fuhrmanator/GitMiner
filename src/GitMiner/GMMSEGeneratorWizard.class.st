Class {
	#name : #GMMSEGeneratorWizard,
	#superclass : #Object,
	#instVars : [
		'verveineJScriptPath',
		'mseDestinationPath',
		'javaSourcePath'
	],
	#category : #GitMiner
}

{ #category : #accessing }
GMMSEGeneratorWizard >> javaSourcePath [
	^ javaSourcePath
]

{ #category : #accessing }
GMMSEGeneratorWizard >> javaSourcePath: aString [
	javaSourcePath := aString
]

{ #category : #accessing }
GMMSEGeneratorWizard >> mseDestinationPath [
	^ mseDestinationPath
]

{ #category : #accessing }
GMMSEGeneratorWizard >> mseDestinationPath: anObject [
	mseDestinationPath := anObject
]

{ #category : #acccessing }
GMMSEGeneratorWizard >> verveineJScriptPath [
	verveineJScriptPath isNil
		ifTrue: [ verveineJScriptPath := GMUtility queryJavaToFamixCommand ].
	^ verveineJScriptPath
]

{ #category : #acccessing }
GMMSEGeneratorWizard >> verveineJScriptPath: pathString [
	verveineJScriptPath := pathString.
]
