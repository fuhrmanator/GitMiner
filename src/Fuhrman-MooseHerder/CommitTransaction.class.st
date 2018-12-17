"
I represent a transaction of a commit in version control.

I keep the list of files and I know the UID of the commit.

    Instance Variables
	committedFileNames:		<OrderedCollection>
	uid:		<String>
"
Class {
	#name : #CommitTransaction,
	#superclass : #Object,
	#instVars : [
		'uid',
		'committedFileNames'
	],
	#category : #'Fuhrman-MooseHerder'
}

{ #category : #initialization }
CommitTransaction class >> transactionFromRecord: record [
	"create a transaction object from a record read from a CSV file"

	^ self new
		uid: record first;
		committedFileNames: record allButFirst
]

{ #category : #accessing }
CommitTransaction >> committedFileNames [
	^ committedFileNames
]

{ #category : #accessing }
CommitTransaction >> committedFileNames: anObject [
	committedFileNames := anObject
]

{ #category : #accessing }
CommitTransaction >> renameAll: fromFileName to: toFileName [
	"attempts to rename any filenames in the committedFileNames list"

	| cFileNames |
	"fromFileName  = self committedFileNames first ifTrue:[0halt]."
	cFileNames := self committedFileNames copyReplaceAll: { fromFileName } with: {toFileName}.
	self committedFileNames: cFileNames.
	^cFileNames
	
]

{ #category : #accessing }
CommitTransaction >> uid [
	^ uid
]

{ #category : #accessing }
CommitTransaction >> uid: anObject [
	uid := anObject
]
