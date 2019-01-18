"
I represent a transaction of a commit in version control.

I keep the list of files and I know the UID of the commit.

    Instance Variables
	committedFileNames:		<OrderedCollection>
	uid:		<String>
"
Class {
	#name : #GMCommitTransaction,
	#superclass : #Object,
	#instVars : [
		'uid',
		'committedFileNames'
	],
	#category : #GitMiner
}

{ #category : #initialization }
GMCommitTransaction class >> transactionFromRecord: record [
	"create a transaction object from a record read from a CSV file"

	^ self new
		uid: record first;
		committedFileNames: record allButFirst
]

{ #category : #accessing }
GMCommitTransaction >> committedFileNames [
	^ committedFileNames
]

{ #category : #accessing }
GMCommitTransaction >> committedFileNames: anObject [
	committedFileNames := anObject
]

{ #category : #accessing }
GMCommitTransaction >> renameAll: fromFileName to: toFileName [
	"attempts to rename any filenames in the committedFileNames list"

	| cFileNames |
	"fromFileName  = self committedFileNames first ifTrue:[0halt]."
	cFileNames := self committedFileNames copyReplaceAll: { fromFileName } with: {toFileName}.
	self committedFileNames: cFileNames.
	^cFileNames
	
]

{ #category : #accessing }
GMCommitTransaction >> uid [
	^ uid
]

{ #category : #accessing }
GMCommitTransaction >> uid: anObject [
	uid := anObject
]
