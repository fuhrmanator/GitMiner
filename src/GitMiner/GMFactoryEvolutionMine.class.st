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
	| constructorsOfImplementations invokersOfConstructors |
	"e.g., new ArrayList();"
	constructorsOfImplementations := mooseModel allMethods
		select: [ :m | 
			| isNonMarkerInterface |
			isNonMarkerInterface := m parentType withSuperclassHierarchy
				anySatisfy: [ :sc | sc isInterface and: [ sc methods isNotEmpty ] ].
			m isConstructor & isNonMarkerInterface ].
	invokersOfConstructors := constructorsOfImplementations
		flatCollect: [ :c | c incomingInvocations collect: #sender ].
	"self from sourceAnchor ifNotNil: [ (self from generateFastIfNotDoneAndBind). 
(self fast atAnyScope: {FASTJavaAssignementExpression . FASTJavaVariableDeclarator}) ifNotEmpty: [:aScopeWithOneElement | ^ aScopeWithOneElement anyOne variable famixVariable. ] ]."
	invokersOfConstructors
		do: [ :invoker | 
			| results |
			invoker sourceAnchor
				ifNotNil: [ invoker generateFastIfNotDoneAndBind.
					results := invoker fast
						toAnyScope:
							{FASTJavaAssignementExpression.
							FASTJavaVariableDeclarator}.
					0halt.
					results
						ifNotEmpty:
							[ :aScopeWithOneElement | ^ aScopeWithOneElement anyOne variable famixVariable ] ] ]
]

{ #category : #initialization }
GMFactoryEvolutionMine >> initialize [
	super initialize.
	implementationInstantiationsNoInterface := Set new.
	implementationInstantiationsWithInterface := Set new.
	factoryMethodCalls := Set new
]

{ #category : #loading }
GMFactoryEvolutionMine >> load [ 
	super load.
	"resetMetamodel"
	"since we're using Carrefour (FAST with Moose), we need to set the metamodel type"
	mooseModel metamodel: CRFMetamodelGenerator metamodel.

	isLoaded := true
]