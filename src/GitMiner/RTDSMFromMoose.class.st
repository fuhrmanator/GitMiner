"
""Class to make a RTDSM from Moose Models. 
One problem is that clientTypes shows dependencies in the opposite direction. So, we redfined the behavior of the RTDSM in this class to show associations correctly.

Load a MSE into Moose and inspect the following.""

| mooseModel dependencyMatrix dsm |
mooseModel := MooseModel root first.
dependencyMatrix := GMUtility dependencyMatrixFromMooseModel: mooseModel.	

dsm := RTDSMFromMoose new.
dsm objects: dependencyMatrix classes.
dsm clients: [:class | class clientTypes reject: #isStub].
dsm rotation: 270.
^dsm
"
Class {
	#name : #RTDSMFromMoose,
	#superclass : #RTAbstractDSM,
	#instVars : [
		'clients'
	],
	#category : #GitMiner
}

{ #category : #accessing }
RTDSMFromMoose >> clients [
	^ clients
]

{ #category : #accessing }
RTDSMFromMoose >> clients: aOneArgBlock [
	clients := aOneArgBlock
]

{ #category : #initialization }
RTDSMFromMoose >> initialize [
	super initialize.
	clients := #yourself.
	self shape
		"put a red box if there's a client association (opposite of dependency)"
		if: [ :assoc | self isAssocClient: assoc ] fillColor: Color red.
]

{ #category : #testing }
RTDSMFromMoose >> isAssocClient: assoc [
	"flip key/value in this logic from isAssocDependent (to correct for clientTypes showing clients rather than dependencies)"
	| v |
	v := clients rtValue: assoc value.
	v = assoc key ifTrue: [ ^ true ].
	^ v isCollection
		ifTrue: [ v includes: assoc key ]
		ifFalse: [ false ]
]
