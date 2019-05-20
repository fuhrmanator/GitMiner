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
GMFactoryEvolutionMine >> assignmentsOfImplementations [
	| constructorsOfImplementations invokersOfConstructors assignmentsInInvokersOfConstructors |
	"e.g., new ArrayList();"
	constructorsOfImplementations := self constructors
		select: [ :m | 
			| constructeeImplementsNonMarkerInterfaceOrIsSubclassOfAbstract |
			"0 halt."
			constructeeImplementsNonMarkerInterfaceOrIsSubclassOfAbstract := m parentType
				withSuperclassHierarchy 	"withAllSuperclasses?"
				anySatisfy: [ :sc | "Halt if: [ sc name = 'IProduct' ]." "self
						crLog: 'method ' , m mooseName , ' (', m kind , ') superclass ' , sc name , ' isInterface = ' , sc isInterface asString
						, ' isAbstract = ' , sc isAbstract asString." sc isAbstract or: [sc isInterface and: [ sc methods isNotEmpty ]] ].
			constructeeImplementsNonMarkerInterfaceOrIsSubclassOfAbstract ].
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
							{FASTJavaAssignementExpression.
							FASTJavaVarDeclStatement} ] ]) asSet.
	"Not all assignments are calls to constructors!"
	0halt.
	"Return all assignments who have a '= new' in them "
	^ assignmentsInInvokersOfConstructors select: [ :a | 
		(a toScope: FASTJavaNewExpression ) isNotEmpty
		]
]

{ #category : #'as yet unclassified' }
GMFactoryEvolutionMine >> assignmentsOfImplementationsWithNoInterface [
	| constructorsOfImplementations invokersOfConstructors assignmentsOfImplementations |
	"e.g., new ArrayList();"
	constructorsOfImplementations := mooseModel allMethods
		select: [ :m | 
			| isNonMarkerInterface |
			isNonMarkerInterface := m parentType withSuperclassHierarchy
				anySatisfy: [ :sc | sc isInterface and: [ sc methods isNotEmpty ] ].
			m isConstructor & isNonMarkerInterface ].
	invokersOfConstructors := constructorsOfImplementations
		flatCollect: [ :c | c incomingInvocations collect: #sender ].
	assignmentsOfImplementations := (invokersOfConstructors
		flatCollect: [ :invoker | 
			| results |
			invoker sourceAnchor
				ifNotNil: [ invoker generateFastIfNotDoneAndBind.
					results := invoker fast
						toAnyScope:
							{FASTJavaAssignementExpression
							". FASTJavaVariableDeclarator"}
					"results
						ifNotEmpty:
							[ :aScopeWithOneElement | ^ aScopeWithOneElement anyOne variable famixVariable ]" ] ])
		asSet
		groupedBy: [ :a | a variable famixVariable declaredType isInterface ].
	0 halt
]

{ #category : #'as yet unclassified' }
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
