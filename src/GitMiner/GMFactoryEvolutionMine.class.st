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

{ #category : #queries }
GMFactoryEvolutionMine >> assignmentsOfImplementations [
	| constructorsOfImplementations invokersOfConstructors assignmentsInInvokersOfConstructors |
	"e.g., new ArrayList();"
	constructorsOfImplementations := self constructors
		select: [ :m | 
			| constructeeImplementsNonMarkerInterfaceOrIsDirectSubclassOfAbstract |
			"0 halt."
			constructeeImplementsNonMarkerInterfaceOrIsDirectSubclassOfAbstract := m parentType
				withSuperclassHierarchy 	"withAllSuperclasses?"
				anySatisfy: [ :sc | 
					"self
						crLog: 'method ' , m mooseName , ' (', m kind , ') superclass ' , sc name , ' isInterface = ' , sc isInterface asString
						, ' isAbstract = ' , sc isAbstract asString." 
					sc isAbstract or: [sc isInterface and: [ sc methods isNotEmpty ]] ].
			constructeeImplementsNonMarkerInterfaceOrIsDirectSubclassOfAbstract ].
	"constructorsOfImplementations 
		do: [ :i | 
			self
				crLog:
					'method ' , i mooseName , ' (' , i kind , ') parentType: '
						, i parentType mooseName]."
	invokersOfConstructors := constructorsOfImplementations
		flatCollect: [ :c | c incomingInvocations collect: #sender ].
	assignmentsInInvokersOfConstructors := (invokersOfConstructors
		flatCollect: [ :invoker | 
			invoker sourceAnchor
				ifNotNil: [ invoker generateFastIfNotDoneAndBind.
					invoker fast
						toAnyScope:
							{FASTJavaAssignementExpression. FASTJavaVariableDeclarator
							"FASTJavaVarDeclStatement"} ] ]) asSet.
	"Not all assignments are calls to constructors!"
	"Return all assignments who have a '= new' in them "
	^ assignmentsInInvokersOfConstructors select: [ :a | 
		(a toScope: FASTJavaNewExpression ) isNotEmpty
		]
]

{ #category : #queries }
GMFactoryEvolutionMine >> assignmentsOfImplementationsWithUpCasting [
	| assignmentsOfImplementations assignmentsOfImplementationsWithUpCasting |
	assignmentsOfImplementations := self assignmentsOfImplementations.
	"For each assignment, return those whose type on the left is more abstract than the type on the right (upcasting)"
	assignmentsOfImplementationsWithUpCasting := assignmentsOfImplementations select: [ :a | 
		| variableType |
		"Left-hand side of assignment"
		0halt.
		variableType := a famixVariable declaredType.
		"Right hand side could have many expressions (or just one)"
		(a toScope: FASTJavaNewExpression ) allSatisfy: [ :newEx | 
			| newExpressionType isUpcasting |
			newExpressionType := newEx famix to first parentType.
			isUpcasting := newExpressionType superclassHierarchy includes: variableType.
			isUpcasting]
		].
	^ assignmentsOfImplementationsWithUpCasting
]

{ #category : #'as yet unclassified' }
GMFactoryEvolutionMine >> assignmentsOfImplementationsWithoutUpCasting [
	| assignmentsOfImplementations assignmentsOfImplementationsWithoutUpCasting |
	assignmentsOfImplementations := self assignmentsOfImplementations.
	^ assignmentsOfImplementations difference: self assignmentsOfImplementationsWithUpCasting 
]

{ #category : #queries }
GMFactoryEvolutionMine >> constructors [
	^ mooseModel allMethods select: #isConstructor
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
