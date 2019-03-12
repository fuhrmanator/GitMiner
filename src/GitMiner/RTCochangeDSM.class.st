"
""Class to make a RTDSM for a GMCochangeMatrix (https://ieeexplore.ieee.org/document/6363462). 

A Moose class group and inspect the following.""

| mooseModel mseFileRef commitTransactions transactionsFileRef classes changeHistoryMatrix cochangeMatrix dsm |

mseFileRef := GMUtility navigateToFile: 'Choose an MSE file' extensions: 'mse'.
mooseModel := GMUtility loadMooseModelFromMSE: mseFileRef.

transactionsFileRef := GMUtility navigateToFile: 'Choose a *_commits_oids_UIDs_TR.csv file' extensions: 'csv'.
commitTransactions := GMUtility loadCommitTransactions: transactionsFileRef asFileReference.
 
classes := GMUtility mooseClassesForDependencyMining: mooseModel.
changeHistoryMatrix := GMUtility changeHistoryMatrixFromTransactions: commitTransactions classes: classes.
cochangeMatrix := GMUtility cochangeMatrixFromChangeHistory: changeHistoryMatrix forClasses: classes.

dsm := RTCochangeDSM new.
dsm objects: cochangeMatrix classes.
dsm cochangeMatrix: cochangeMatrix.
dsm rotation: 270.
^dsm
"
Class {
	#name : #RTCochangeDSM,
	#superclass : #RTAbstractDSM,
	#instVars : [
		'cochangeMatrix'
	],
	#category : #GitMiner
}

{ #category : #testing }
RTCochangeDSM >> assocChanges: assoc [
	"return the number of changes at the cell for the association"
	| i j classes |
	classes := self objects.
	i := classes indexOf: assoc key.
	j := classes indexOf: assoc value.
	^ self cochangeMatrix at: i at: j
]

{ #category : #accessing }
RTCochangeDSM >> cochangeMatrix [
	^ cochangeMatrix
]

{ #category : #accessing }
RTCochangeDSM >> cochangeMatrix: anObject [
	cochangeMatrix := anObject
]

{ #category : #initialization }
RTCochangeDSM >> initialize [
	super initialize.
	"classes := #yourself."
	self shape
		"put a red box if there's a client association (opposite of dependency)"
		if: [ :assoc | (self assocChanges: assoc) > 0 ] fillColor: Color red.
]

{ #category : #testing }
RTCochangeDSM >> isAssocClient: assoc [
	"flip key/value in this logic from isAssocDependent (to correct for clientTypes showing clients rather than dependencies)"
	| v |
	v := clients rtValue: assoc value.
	v = assoc key ifTrue: [ ^ true ].
	^ v isCollection
		ifTrue: [ v includes: assoc key ]
		ifFalse: [ false ]
]
