Class {
	#name : #GMClientImplementationPair,
	#superclass : #Object,
	#instVars : [
		'client',
		'implementation'
	],
	#category : #'GitMiner-Mining'
}

{ #category : #'as yet unclassified' }
GMClientImplementationPair class >> from: aFAMIXClassClient and: aFAMIXClassImplementation [
	| pair |
	pair := self new
		client: aFAMIXClassClient;
		implementation: aFAMIXClassImplementation.
	^ pair
]

{ #category : #converting }
GMClientImplementationPair >> asString [
 ^(client sourceAnchor fileName) , '->' , (implementation sourceAnchor fileName)
]

{ #category : #'as yet unclassified' }
GMClientImplementationPair >> client [
	^ client
]

{ #category : #'as yet unclassified' }
GMClientImplementationPair >> client: aFAMIXClass [ 
	client := aFAMIXClass.
]

{ #category : #'as yet unclassified' }
GMClientImplementationPair >> implementation [
	^ implementation
]

{ #category : #'as yet unclassified' }
GMClientImplementationPair >> implementation: aFAMIXClass [ 
	implementation := aFAMIXClass.
]
