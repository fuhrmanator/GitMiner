"
I represent an activity of mining for steps along the refactorings (evolution) to use of a simple (static) factory. 
"
Class {
	#name : #GMFactoryEvolutionMine,
	#superclass : #GMAbstractMine,
	#instVars : [
		'implementationInstantiationsNoInterface',
		'implementationInstantiationsWithInterface',
		'factoryMethodCalls'
	],
	#category : #GitMiner
}

{ #category : #'as yet unclassified' }
GMFactoryEvolutionMine >> assignmentsOfImplementationsWithNoInterface [
	^ Set new.
]

{ #category : #initialization }
GMFactoryEvolutionMine >> initialize [
	super initialize.
	implementationInstantiationsNoInterface := Set new.
	implementationInstantiationsWithInterface := Set new.
	factoryMethodCalls := Set new
]
