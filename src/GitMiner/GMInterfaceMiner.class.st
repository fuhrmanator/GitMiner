"
I represent services to mine MSE files for Interface-related information.

I extract useful information regarding interfaces (coupling to clients, implementations, etc.)

This class is based originally on scripts from Playground experiments.
"
Class {
	#name : #GMInterfaceMiner,
	#superclass : #Object,
	#category : #GitMiner
}

{ #category : #'client implementation analysis' }
GMInterfaceMiner class >> localClientsFrom: interface [
	| localClients |
	localClients := (interface structuresWithDeclaredType
		collect: [ :struct | 
			| classArray |
			"MooseQuery... struct atScope: FAMIXType. -- returns an Array, so just take first element"
			classArray := struct atScope: FAMIXType.
			"self assert: classArray size equals: 1."
			classArray first ]) asSet.
	^ localClients
]

{ #category : #'client implementation analysis' }
GMInterfaceMiner class >> mineClientImplementationPairs: mseFileRef withPrefix: ifPrefix [
	| mseStream interfaces listOfResults mooseModel |
	mseStream := mseFileRef readStream.
	listOfResults := LinkedList new.
	mseStream
		ifNotNil: [ mooseModel := MooseModel importFromMSEStream: mseStream.
			mseStream close ]
		ifNil: [ 0 halt ].

	"Find implementations and clients for each interface"
	"Limit interfaces to those starting with prefix"
	[ :job | 
	| count |
	count := 0.
	interfaces := (mooseModel allClasses
		select: [ :each | 
			job
				progress: count / mooseModel allClasses size;
				title: 'Collecting interfaces'.
			each isInterface
				& ((ifPrefix isEmpty) | (each container mooseName beginsWith: ifPrefix)) ]) asSet ]
		asJob run.
	interfaces
		do: [ :interface | 
			| localClients localProtectedClients localUnprotectedClients localImplementations classesReferencingLocalImplementations |
			"Sub-interfaces are rejected because they are not implementations"
			"Stubs are rejected because they're not under control of the project"
			localImplementations := interface directSubclasses
				reject: [ :cls | cls isInterface | cls isStub ].
			localClients := (self localClientsFrom: interface) reject: #isStub.

			"Classify protected and unprotected clients"
			classesReferencingLocalImplementations := (localImplementations
				flatCollect: [ :imp | imp clientTypes ]) asSet.

			"Remove the clients of the interface that reference its implementations"
			localProtectedClients := localClients
				difference: classesReferencingLocalImplementations.
			"Only take clients of the interface"
			localUnprotectedClients := localClients
				intersection: classesReferencingLocalImplementations.

			"Generate the protected client-implementation pairs"
			localProtectedClients
				do: [ :client | 
					localImplementations
						do: [ :imp | 
							listOfResults
								add:
									(self
										protectedGroup: true
										client: client
										interface: interface
										implementation: imp) ] ].
			"Generate the unprotected client-implementation pairs"
			localUnprotectedClients
				do: [ :client | 
					localImplementations
						do: [ :imp | 
							listOfResults
								add:
									(self
										protectedGroup: false
										client: client
										interface: interface
										implementation: imp) ] ] ]
		displayingProgress: 'Mining: Classifying interface clients'.
	^ listOfResults
]

{ #category : #'client implementation analysis' }
GMInterfaceMiner class >> protectedGroup: isProtected client: client interface: interface implementation: imp [
	"makes an array element with the info"

	^ {client mooseName.
	client sourceAnchor fileName.
	interface mooseName.	"this is sometimes a stub, so can't get source always"
	imp mooseName.
	imp sourceAnchor fileName.
	isProtected	"protected"}
]
