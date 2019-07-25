Class {
	#name : #GMCochangeMatrix,
	#superclass : #Object,
	#instVars : [
		'classes',
		'cochangeMatrix'
	],
	#category : #'GitMiner-Change-modeling'
}

{ #category : #initializing }
GMCochangeMatrix class >> with: aPMMatrixAsHistory classes: aFAMIXClassGroup [ 
	^self new cochangeMatrix: aPMMatrixAsHistory * (aPMMatrixAsHistory transpose); classes: aFAMIXClassGroup
]

{ #category : #accessing }
GMCochangeMatrix >> classes [
	^ classes
]

{ #category : #accessing }
GMCochangeMatrix >> classes: anObject [
	classes := anObject
]

{ #category : #accessing }
GMCochangeMatrix >> cochangeMatrix [
	^ cochangeMatrix
]

{ #category : #accessing }
GMCochangeMatrix >> cochangeMatrix: anObject [
	cochangeMatrix := anObject
]
