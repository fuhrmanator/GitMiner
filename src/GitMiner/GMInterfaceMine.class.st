"
I represent a mining activity regarding Interfaces (their clients and their implementations).
"
Class {
	#name : #GMInterfaceMine,
	#superclass : #GMAbstractMine,
	#instVars : [
		'implementations',
		'listOfResults'
	],
	#category : #'GitMiner-Mining'
}

{ #category : #'as yet unclassified' }
GMInterfaceMine >> clientsForImplementation: anImplementation [
	| interfacesForImplementation |
	"Find interfaces of the implementation"
	interfacesForImplementation := self
		interfacesForImplementation: anImplementation.
	"Find clients for all the interfaces"
	^ self clientsForInterfaces: interfacesForImplementation
]

{ #category : #'as yet unclassified' }
GMInterfaceMine >> clientsForInterfaces: theInterfaces [
	| clients |
	clients := Set new.
	theInterfaces
		do: [ :i | 
			| localClients |
			localClients := (self localClientsFrom: i)
				reject: [ :client | client sourceAnchor isNil ].
			clients addAll: localClients ].
	^ clients
]

{ #category : #'as yet unclassified' }
GMInterfaceMine >> famixClassFromCommittedClass: aCommittedClassFileNameString [
	"Find the moose class that corresponds to the filename in a commit"

	| mooseClasses mooseClass |
	mooseClasses := GMUtility mooseClassesForDependencyMining: mooseModel.
	mooseClass := mooseClasses
		select: [ :c | 
			c sourceAnchor isNotNil
				and: [ (GMUtility normalizedFileName: c sourceAnchor fileName) = aCommittedClassFileNameString ] ].
	^ mooseClass first "it's a group, return the first one"
]

{ #category : #'as yet unclassified' }
GMInterfaceMine >> famixClassesFromCommittedClasses: committedClassesCollection [ 
	"Find the Moose classes that correspond to the filenames (committed classes)"
	| famixClasses |
	famixClasses := committedClassesCollection collect: [ :cc | self famixClassFromCommittedClass: cc ]. 
	^famixClasses 
]

{ #category : #'as yet unclassified' }
GMInterfaceMine >> implementationsFromCommittedClasses: aCollection [ 

	| committedMooseClasses committedImplementations |
	committedMooseClasses := self famixClassesFromCommittedClasses: aCollection.
	"find out if these are implementations"
	committedImplementations := committedMooseClasses intersection: implementations.
	^ committedImplementations
]

{ #category : #initialization }
GMInterfaceMine >> initialize [
	super initialize.
	implementations := Set new.
	listOfResults := LinkedList new.
	implementations := Set new.
]

{ #category : #'As yet unclassified' }
GMInterfaceMine >> interfacesForImplementation: aFAMIXClass [ 
	^(((aFAMIXClass directSuperclasses) select: #isInterface) reject: #isStub) asSet
]

{ #category : #'private - testing' }
GMInterfaceMine >> listOfResults [
	^ listOfResults
]

{ #category : #loading }
GMInterfaceMine >> load [ 
	super load.
	self loadClientsAndImplementations.

	isLoaded := true
]

{ #category : #'as yet unclassified' }
GMInterfaceMine >> loadClientsAndImplementations [
	"Find the clients and implementations for each interface"

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
						collect: [ :clientType | clientType -> localImplementation ]	].
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
]

{ #category : #'client implementation analysis' }
GMInterfaceMine >> localClientsFrom: interface [
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
GMInterfaceMine >> makeEntryForProtectedGroup: isProtected client: client interface: interface implementation: imp [
	"makes an array element with the info"

	^ {client mooseName.
	GMUtility normalizedFileName: client sourceAnchor fileName.
	interface mooseName.	"this is sometimes a stub, so can't get source always"
	imp mooseName.
	GMUtility normalizedFileName: imp sourceAnchor fileName.
	isProtected	"protected"}
]
