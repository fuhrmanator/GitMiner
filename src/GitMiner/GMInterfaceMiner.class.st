"
I represent services to mine MSE files for Interface-related information.

I extract useful information regarding interfaces (coupling to clients, implementations, etc.)

This class is based originally on scripts from Playground experiments.
"
Class {
	#name : #GMInterfaceMiner,
	#superclass : #Object,
	#category : #'GitMiner-Mining'
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
GMInterfaceMiner class >> makeEntryForProtectedGroup: isProtected client: client interface: interface implementation: imp [
	"makes an array element with the info"

	^ {client mooseName.
	GMUtility normalizedFileName: client sourceAnchor fileName.
	interface mooseName.	"this is sometimes a stub, so can't get source always"
	imp mooseName.
	GMUtility normalizedFileName: imp sourceAnchor fileName.
	isProtected	"protected"}
]

{ #category : #'client implementation analysis' }
GMInterfaceMiner class >> mineClientImplementationPairs: mseFileRef withPrefix: ifPrefix [
	| mseStream interfaces implementations listOfResults mooseModel |
	listOfResults := LinkedList new.
	implementations := Set new.
	mseStream := mseFileRef readStream.
	[ :job | 
	| count classes classesFile |
	job title: 'Loading MSE file: ' , mseFileRef fullPath fullName.
	mseStream
		ifNotNil: [ mooseModel := MooseModel importFromMSEStream: mseStream.
			mseStream close ]
		ifNil: [ self error: 'The MSE file ' , mseFileRef , ' is not valid.' ].

	"Find implementations and clients for each interface"
	"Limit interfaces to those starting with prefix"
	job title: 'Collecting interfaces'.
	classes := GMUtility mooseClassesForDependencyMining: mooseModel.
	classesFile := GMUtility writeClasses: classes file: mseFileRef.
	count := 0.
	interfaces := (classes
		select: [ :each | 
			job progress: count / classes size.
			each isInterface
				and: [ each numberOfMethods > 0
						and: [ ifPrefix isEmpty
								or: [ each container mooseName beginsWith: ifPrefix ] ] ] ])
		asSet ] asJob run.
	interfaces
		do: [ :interface | 
			| localClients localImplementations classesReferencingLocalImplementations allPairs unprotectedPairs protectedPairs |
			"Sub-interfaces are rejected because they are not implementations"
			"Stubs are rejected because they're not under control of the project"
			"AnonymouseClasses are rejected because they're inside a file (and won't ever be committed as a separate file)"
			localImplementations := interface directSubclasses
				reject: [ :cls | cls isInterface | cls isStub | cls isAnonymousClass ].
			implementations addAll: localImplementations.
			localClients := (self localClientsFrom: interface)
				reject: [ :client | client sourceAnchor isNil ].
			classesReferencingLocalImplementations := (localImplementations
				flatCollect: [ :imp | imp clientTypes ]) asSet.
			allPairs := localClients
				flatCollect: [ :localClient | 
					localImplementations
						collect: [ :implementation | localClient -> implementation ] ].
			unprotectedPairs := localImplementations
				flatCollect: [ :localImplementation | 
					"don't get clients that are not local"
					(localImplementation clientTypes intersection: localClients)
						collect: [ :clientType | clientType -> localImplementation ] ].
			protectedPairs := allPairs difference: unprotectedPairs.
			unprotectedPairs
				do: [ :pair | 
					listOfResults
						add:
							(self
								makeEntryForProtectedGroup: false
								client: pair key
								interface: interface
								implementation: pair value) ].
			protectedPairs
				do: [ :pair | 
					listOfResults
						add:
							(self
								makeEntryForProtectedGroup: true
								client: pair key
								interface: interface
								implementation: pair value) ] ]
		displayingProgress: 'Mining: Classifying interface clients'.
	^ {listOfResults.
	interfaces.
	implementations}
]
