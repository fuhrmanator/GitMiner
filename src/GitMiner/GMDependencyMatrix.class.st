Class {
	#name : #GMDependencyMatrix,
	#superclass : #Object,
	#instVars : [
		'classes',
		'matrix'
	],
	#category : #'GitMiner-Change-modeling'
}

{ #category : #accessing }
GMDependencyMatrix >> classes [
	^ classes
]

{ #category : #accessing }
GMDependencyMatrix >> classes: anObject [
	classes := anObject
]

{ #category : #accessing }
GMDependencyMatrix >> matrix [
	^ matrix
]

{ #category : #accessing }
GMDependencyMatrix >> matrix: anObject [
	matrix := anObject
]
