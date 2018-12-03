"
I represent services to mine MSE files for Interface-related information.

I extract useful information regarding interfaces (coupling to clients, implementations, etc.)

This class is based originally on scripts from Playground experiments.
"
Class {
	#name : #InterfaceMiner,
	#superclass : #Object,
	#category : #'Fuhrman-MooseHerder'
}

{ #category : #'client implementation analysis' }
InterfaceMiner class >> mineStructurallyCoupledClients: mseStream withPrefix: ifPrefix [
	"Load the MSE into Moose, then process it"

	"Generate an array of lines:
	Client, Interface, Implementation, Protected (true/false)
	"

	| interfaces listOfResults mooseModel |
	"Improve memory footprint by restricting elements of the model?"
	"	contextSelected := #(#Parameter #UnknownVariable #LocalVariable #Class #Invocation #AnnotationType #Package #AnnotationTypeAttribute #EnumValue #GlobalVariable #TypeAlias #Module #Method #Enum #Function #Reference #PrimitiveType #Inheritance #Access #ParameterType #Comment #ParameterizedType #ParameterizableClass #ImplicitVariable #Namespace).
"
	"	importingContext := FAMIXStandardImportingContext new.
	importingContext importAll: contextSelected."
	"List of Interfaces, Clients, etc. for output"
	listOfResults := LinkedList new.
	mseStream
		ifNotNil: [ "Transcript
				show: 'About to load Moose file ', mseStream localName;
				cr."
			mooseModel := MooseModel importFromMSEStream: mseStream.
			mseStream close
			"Transcript
				show: 'Moose file loaded.';
				cr" ].

	"Limit interfaces to those starting with prefix"
	interfaces := (mooseModel allClasses
		select: [ :each | 
			(ifPrefix isEmpty
				ifTrue: [ true ]
				ifFalse: [ each container mooseName beginsWith: ifPrefix ]) and: each isInterface ]) asSet.

	"Find implementations and clients for each interface"
	interfaces
		do: [ :interface | 
			| localClients localProtectedClients localUnprotectedClients localImplementations refLocalImplementations |
			"Sub-interfaces are rejected because they are not implementations"
			localImplementations := interface directSubclasses reject: [ :cls | cls isInterface ].
			"Keep track of all implementations"
			localClients := interface structuresWithDeclaredType
				collect: [ :struct | 
					(struct isMemberOf: FAMIXAttribute)
						ifTrue: [ struct parentType ]
						ifFalse: [ (struct isMemberOf: FAMIXParameter)
								ifTrue: [ struct parentBehaviouralEntity parentType ]
								ifFalse: [ (struct isMemberOf: FAMIXLocalVariable)
										ifTrue: [ struct parentBehaviouralEntity parentType ]
										ifFalse: [ Transcript show: '*** Unanticipated type: '.
											Transcript
												show: struct class;
												cr ] ] ] ].
			localClients := localClients asSet.
			refLocalImplementations := Set new.	"don't allow duplicates"

			"Classify protected and unprotected clients"
			localImplementations
				do:
					[ :implementation | refLocalImplementations := refLocalImplementations , implementation clientTypes ].
			localProtectedClients := localClients difference: refLocalImplementations.
			localUnprotectedClients := localClients intersection: refLocalImplementations.

			"Generate the protected client-implementation pairs"
			localProtectedClients
				do: [ :client | 
					localImplementations
						do: [ :imp | 
							listOfResults
								add:
									{client.
									interface.
									imp.
									true	"protected"} ] ].
			"Generate the unprotected client-implementation pairs"
			localUnprotectedClients
				do: [ :client | 
					localImplementations
						do: [ :imp | 
							listOfResults
								add:
									{client.
									interface.
									imp.
									false	"unprotected"} ] ] ].
	^ listOfResults
]
