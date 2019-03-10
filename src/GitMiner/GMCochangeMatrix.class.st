Class {
	#name : #GMCochangeMatrix,
	#superclass : #Object,
	#instVars : [
		'classes',
		'cochangeMatrix'
	],
	#category : #GitMiner
}

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
