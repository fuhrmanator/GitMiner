Class {
	#name : #GMInterfaceMine,
	#superclass : #Object,
	#instVars : [
		'mseFile'
	],
	#category : #GitMiner
}

{ #category : #'as yet unclassified' }
GMInterfaceMine class >> fromMSE: aFileReference [ 
	| mine |
	mine := self new.
	mine mseFile: aFileReference.
	^mine
]

{ #category : #'as yet unclassified' }
GMInterfaceMine >> mseFile [
	^mseFile
]

{ #category : #'as yet unclassified' }
GMInterfaceMine >> mseFile: aFileReference [ 
	mseFile := aFileReference.
]
