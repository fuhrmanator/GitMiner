Class {
	#name : #GMClientImplementationPairTest,
	#superclass : #TestCase,
	#instVars : [
		'classes',
		'mooseModel'
	],
	#category : #'GitMiner-Tests'
}

{ #category : #running }
GMClientImplementationPairTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

	| mseFile mseStream |
	mseFile := FileSystem disk workingDirectory / 'pharo-local'
		/ 'iceberg' / 'fuhrmanator' / 'GitMiner' / 'tests'
		/ 'FactoryVariants.mse'.
	mseStream := mseFile readStream.
	mooseModel := MooseModel importFromMSEStream: mseStream.
	classes := mooseModel allWithSubTypesOf: FamixTClass
]

{ #category : #tests }
GMClientImplementationPairTest >> testAsString [
	"comment stating purpose of message"

	| pair aClient implementation |

	aClient := (classes select: [:c | c mooseName = '<Default Package>::ClientNoFactoryMain']) first.
	implementation := (classes select: [:c | c mooseName = 'no_factory::ProductA' ]) first.
	
	pair := GMClientImplementationPair from: aClient and: implementation.
	self assert: pair asString equals: (aClient sourceAnchor fileName) , '->' , (implementation sourceAnchor fileName).
]

{ #category : #tests }
GMClientImplementationPairTest >> testClient [
	"comment stating purpose of message"

	| pair aClient implementation |

	aClient := (classes select: [:c | c mooseName = '<Default Package>::ClientNoFactoryMain']) first.
	implementation := (classes select: [:c | c mooseName = 'no_factory::ProductA' ]) first.
	
	pair := GMClientImplementationPair from: aClient and: implementation.
	self assert: pair client equals: aClient.
]

{ #category : #tests }
GMClientImplementationPairTest >> testCreateFrom [
	"comment stating purpose of message"

	| pair client implementation |

	client := (classes select: [:c | c mooseName = '<Default Package>::ClientNoFactoryMain']) first.
	implementation := (classes select: [:c | c mooseName = 'no_factory::ProductA' ]) first.
	
	pair := GMClientImplementationPair from: client and: implementation.
	self assert: pair isNotNil.
	self deny: pair isClass.
]

{ #category : #tests }
GMClientImplementationPairTest >> testImplementation [
	"comment stating purpose of message"

	| pair aClient implementation |

	aClient := (classes select: [:c | c mooseName = '<Default Package>::ClientNoFactoryMain']) first.
	implementation := (classes select: [:c | c mooseName = 'no_factory::ProductA' ]) first.
	
	pair := GMClientImplementationPair from: aClient and: implementation.
	self assert: pair implementation equals: implementation.
]
