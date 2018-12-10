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
InterfaceMiner class >> mineClientImplementationPairs: mseStream withPrefix: ifPrefix [
	| interfaces listOfResults mooseModel |

	listOfResults := LinkedList new.
	mseStream
		ifNotNil: [ 
			mooseModel := MooseModel importFromMSEStream: mseStream.
			mseStream close].

	"Limit interfaces to those starting with prefix"
	interfaces := (mooseModel allClasses
		select: [ :each | 
			(ifPrefix isEmpty
				ifTrue: [ true ]
				ifFalse: [ each container mooseName beginsWith: ifPrefix ]) and: each isInterface ]) asSet.

	"Find implementations and clients for each interface"
	interfaces
		do: [ :interface | 
			| localClients localProtectedClients localUnprotectedClients localImplementations classesReferencingLocalImplementations |
			"Sub-interfaces are rejected because they are not implementations"
			localImplementations := interface directSubclasses reject: [ :cls | cls isInterface ].
			"Keep track of all implementations"
			localClients := ( interface structuresWithDeclaredType
				collect: [ :struct | "struct atScope: FAMIXType."
					(struct isMemberOf: FAMIXAttribute)
						ifTrue: [ struct parentType ]
						ifFalse: [ (struct isMemberOf: FAMIXParameter)
								ifTrue: [ struct parentBehaviouralEntity parentType ]
								ifFalse: [ (struct isMemberOf: FAMIXLocalVariable)
										ifTrue: [ struct parentBehaviouralEntity parentType ]
										ifFalse: [ Transcript show: '*** Unanticipated type: '.
											Transcript
												show: struct class;
												cr ] ] ] ] ) asSet.
			"localClients := localClients asSet."
			classesReferencingLocalImplementations := Set new.	"don't allow duplicates"

			"Classify protected and unprotected clients"
			localImplementations
				do:
					[ :implementation | classesReferencingLocalImplementations := classesReferencingLocalImplementations , implementation clientTypes ].

			"Consider only clients and implementations that have source code (not from an API only)"
			localClients reject: #isStub.
			localImplementations reject: #isStub.

			"Remove the clients of the interface that reference its implementations"
			localProtectedClients := localClients difference: classesReferencingLocalImplementations.
			"Only take clients of the interface"
			localUnprotectedClients := localClients intersection: classesReferencingLocalImplementations. 
			
			"Generate the protected client-implementation pairs"
			localProtectedClients
				do: [ :client | 
					localImplementations
						do: [ :imp | 
							listOfResults
								add:
									{client mooseName .
									interface mooseName.
									imp mooseName.
									true	"protected"} ] ].
			"Generate the unprotected client-implementation pairs"
			localUnprotectedClients
				do: [ :client | 
					localImplementations
						do: [ :imp | 
							listOfResults
								add:
									{client mooseName .
									interface mooseName.
									imp mooseName.
									false	"unprotected"} ] ] ].
	^ listOfResults
]
