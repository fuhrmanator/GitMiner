Class {
	#name : #GMClientImplementationPairTest,
	#superclass : #TestCase,
	#instVars : [
		'classes',
		'mooseModel',
		'aClient',
		'anImplementation'
	],
	#category : #'GitMiner-Tests'
}

{ #category : #running }
GMClientImplementationPairTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

	| mseFile mseStream |
	super setUp.
	mseFile := FileSystem disk workingDirectory / 'pharo-local'
		/ 'iceberg' / 'fuhrmanator' / 'GitMiner' / 'tests'
		/ 'FactoryVariants.mse'.
	mseStream := mseFile readStream.
	mooseModel := MooseModel importFromMSEStream: mseStream.
	classes := mooseModel allWithSubTypesOf: FamixTClass.
	aClient := (classes select: [:c | c mooseName = '<Default Package>::ClientNoFactoryMain']) first.
	anImplementation := (classes select: [:c | c mooseName = 'no_factory::ProductA' ]) first.

]

{ #category : #tests }
GMClientImplementationPairTest >> testAsString [
	"comment stating purpose of message"

	| pair |

	pair := GMClientImplementationPair from: aClient and: anImplementation.
	self assert: pair asString equals: (aClient sourceAnchor fileName) , '->' , (anImplementation sourceAnchor fileName).
]

{ #category : #tests }
GMClientImplementationPairTest >> testClient [
	"comment stating purpose of message"

	| pair |
	
	pair := GMClientImplementationPair from: aClient and: anImplementation.
	self assert: pair client equals: aClient.
]

{ #category : #tests }
GMClientImplementationPairTest >> testCreateFrom [
	"comment stating purpose of message"

	| pair |

	pair := GMClientImplementationPair from: aClient and: anImplementation.
	self assert: pair isNotNil.
	self deny: pair isClass.
]

{ #category : #tests }
GMClientImplementationPairTest >> testImplementation [
	"comment stating purpose of message"

	| pair |

	pair := GMClientImplementationPair from: aClient and: anImplementation.
	self assert: pair implementation equals: anImplementation.
]
