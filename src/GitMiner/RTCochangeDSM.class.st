"
""Class to make a RTDSM for a GMCochangeMatrix (https://ieeexplore.ieee.org/document/6363462). 

A Moose class group and inspect the following.""

| mooseModel mseFileRef commitTransactions transactionsFileRef classes changeHistoryMatrix cochangeMatrix dsm |

""mseFileRef := GMUtility navigateToFile: 'Choose an MSE file' extensions: #('mse').""
mseFileRef := 'tmp/data_mining/FactoryVariants_master/HEAD.mse' asFileReference.

mooseModel := GMUtility loadMooseModelFromMSE: mseFileRef.

""transactionsFileRef := GMUtility navigateToFile: 'Choose a *_commits_oids_UIDs_TR.csv file' extensions: #('csv').""
transactionsFileRef := 'FactoryVariants_908c96e-END_commits_oids_UIDs_TR.csv' asFileReference.
commitTransactions := GMUtility loadCommitTransactions: transactionsFileRef asFileReference.
 
classes := GMUtility mooseClassesForDependencyMining: mooseModel.
changeHistoryMatrix := GMUtility changeHistoryMatrixFromTransactions: commitTransactions classes: classes.
cochangeMatrix := GMUtility cochangeMatrixFromChangeHistory: changeHistoryMatrix forClasses: classes.

dsm := RTCochangeDSM new.
dsm objects: classes.
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
	#category : #'GitMiner-Change-modeling'
}

{ #category : #examples }
RTCochangeDSM class >> example1 [
	<example>
	| mooseModel mseFileRef commitTransactions transactionsFileRef classes changeHistoryMatrix cochangeMatrix dsm |
	mseFileRef := GMUtility resourcesFileReference
		/ 'FactoryVariants_HEAD.mse'.
	mooseModel := GMUtility loadMooseModelFromMSE: mseFileRef.
	transactionsFileRef := GMUtility resourcesFileReference
		/
			'FactoryVariants_9f09084-END_WithMiningMetadata_selected_selected_TR.csv'.
	commitTransactions := GMUtility
		loadCommitTransactions: transactionsFileRef asFileReference.
	classes := GMUtility mooseClassesForDependencyMining: mooseModel.
	changeHistoryMatrix := GMUtility
		changeHistoryMatrixFromTransactions: commitTransactions
		classes: classes.
	cochangeMatrix := GMUtility
		cochangeMatrixFromChangeHistory: changeHistoryMatrix
		forClasses: classes.
	dsm := RTCochangeDSM new.
	dsm objects: classes.
	dsm cochangeMatrix: cochangeMatrix.
	dsm rotation: 270.
	dsm inspect
]

{ #category : #UI }
RTCochangeDSM >> addLabelsTop [
	"Override this method from RTAbstractDSM to make horizontal labels be left-aligned when rotated -90 (hack)"
	| es theModel lbl labels deltaY |
	es := self rowAt: 1.
	labels := OrderedCollection new.
	deltaY := Float fmax.
	es
		do:
			[ :e | 
			theModel := e model value.
			lbl := self labelShapeX elementOn: theModel.
			labels add: lbl.
			xinteraction setUpElement: lbl.
			view add: lbl.
			lbl rotateByDegrees: rotation.
			RTConstraint new
				fix: e;
				movable: lbl;
				outer;
				middle;
				top;
				move.
			deltaY := deltaY min: lbl position y ].
	"labels do: [ :l | 
		l translateTo: l position x @ deltaY ]."
]

{ #category : #testing }
RTCochangeDSM >> assocChanges: assoc [
	"return the number of changes at the cell for the association"
	| i j classes |
	classes := self cochangeMatrix classes.
	j := classes indexOf: assoc key.
	i := classes indexOf: assoc value.
	^ self cochangeMatrix cochangeMatrix at: i at: j
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
	self interaction
		addExclusiveInteraction:
			(RTPopup new
				text: [ :assoc | 
					assoc key asString , '->' , assoc value asString , ' ('
						, (self assocChanges: assoc) asString , ')' ]).
	self shape
		if: [ :assoc | (self assocChanges: assoc) > 0 ]
		fillColor: Color red
	"put a red box if there's a client association (opposite of dependency)"
]
