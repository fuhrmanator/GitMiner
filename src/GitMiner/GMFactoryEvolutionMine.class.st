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
			constructeeImplementsNonMarkerInterfaceOrIsDirectSubclassOfAbstract := m
				parentType withSuperclassHierarchy
				anySatisfy: [ :sc | "self
						crLog: 'method ' , m mooseName , ' (', m kind , ') superclass ' , sc name , ' isInterface = ' , sc isInterface asString
						, ' isAbstract = ' , sc isAbstract asString." sc isAbstract or: [ sc isInterface and: [ sc methods isNotEmpty ] ] ].	"withAllSuperclasses?"
			constructeeImplementsNonMarkerInterfaceOrIsDirectSubclassOfAbstract ].
	"constructorsOfImplementations 
		do: [ :i | 
			self
				crLog:
					'method ' , i mooseName , ' (' , i kind , ') parentType: '
						, i parentType mooseName]."
	invokersOfConstructors := constructorsOfImplementations
		flatCollect: [ :c | c incomingInvocations collect: #sender ].
	"Code that takes time - show a progress bar"
	[ :job | 
	| count s didParseFail |
	job title: 'Finding assignments in invokers of constructors'.
	count := 0.
	s := invokersOfConstructors size.
	assignmentsInInvokersOfConstructors := (invokersOfConstructors
		collect: [ :invoker | 
			count := count + 1.
			job progress: count / s.
			didParseFail := false.
			invoker sourceAnchor
				ifNotNil: [ [ invoker generateFastIfNotDoneAndBind ]
						on: SmaCCParserError, MessageNotUnderstood, SubscriptOutOfBounds 
						do: [ :exception | 
							didParseFail := true.
							'--> Exception while parsing Invoker''s source:' record.
							exception record.
							(invoker sourceText) record.
							'<--' record
							 ].
					didParseFail
						ifFalse: [ "('Processing invoker ' , invoker asString) record."
							invoker fast sourceText
								ifNotNil: [ "invoker fast sourceText record."
									((invoker fast
										toAnyScope:
											{FASTJavaAssignementExpression.
											FASTJavaVariableDeclarator
											"FASTJavaVarDeclStatement"})
										ifNil: [ 
													('---> Warning: fast query returned no results for invoker '
														, invoker asString , ':') record.
											(invoker sourceText) record.
											'<---' record.
											OrderedCollection new ]) asSet.
										"invoker fast: nil." "Garbage collect?" ]
								ifNil: [ ('---> Warning: fast sourceText was nil for invoker '
												, invoker asString , ':') record.
									(invoker sourceText) record.
									'<---' record.
									"0halt."
									OrderedCollection new ] ] ]
				ifNil: [ ('---> Warning: sourceAnchor was nil for invoker ' , invoker asString
								, ':') record.
					'<---' record.
								"0halt."
					OrderedCollection new ] ]) flattened asSet ] asJob run.

	"Not all assignments are calls to constructors!"
	"Return all assignments who have a '= new' in them "
	^ assignmentsInInvokersOfConstructors
		select: [ :a | a isNotNil and: [(a toScope: FASTJavaNewExpression) isNotEmpty] ]
]

{ #category : #queries }
GMFactoryEvolutionMine >> assignmentsOfImplementationsWithUpCasting [
	| assignmentsOfImplementations assignmentsOfImplementationsWithUpCasting |
	assignmentsOfImplementations := self assignmentsOfImplementations.
	"For each assignment, return those whose type on the left is more abstract than the type on the right (upcasting)"
	assignmentsOfImplementationsWithUpCasting := assignmentsOfImplementations
		select: [ :a | 
			| variableType |
			"Left-hand side of assignment"
			a famixVariable
				ifNil:
					[ 'assignmentsOfImplementationsWithUpCasting: Warning: Left-hand side has nil famixVariable: '
						record.
					a sourceCode record ]
				ifNotNil: [ variableType := a famixVariable declaredType ].
			"Right hand side could have many expressions (or just one)"
			"Exclude NewClass expressions"
			(((a toScope: FASTJavaNewExpression) reject: #isNewAnonymousClass)
				"reject and log invalid expressions"
				reject: [ :newEx | 
					newEx famix isNil
						ifTrue:
							[ 'assignmentsOfImplementationsWithUpCasting: Warning: Right-hand side has nil famix: '
								record.
							newEx sourceCode record.
							true ]
						ifFalse: [ false ] ])
				allSatisfy: [ :newEx | 
					| newExpressionType isUpcasting |
					newExpressionType := newEx famix to first parentType.
					isUpcasting := newExpressionType superclassHierarchy
						includes: variableType.
					isUpcasting ] ].
	^ assignmentsOfImplementationsWithUpCasting
]

{ #category : #'as yet unclassified' }
GMFactoryEvolutionMine >> assignmentsOfImplementationsWithoutUpCasting [
	| assignmentsOfImplementations assignmentsOfImplementationsWithoutUpCasting |
	(assignmentsOfImplementations := self assignmentsOfImplementations)
		ifNotNil: [ ^ assignmentsOfImplementations
				difference: self assignmentsOfImplementationsWithUpCasting ]
		ifNil: [ ^ nil ]
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
