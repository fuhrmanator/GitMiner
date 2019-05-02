Class {
	#name : #GMInterfaceMine,
	#superclass : #Object,
	#instVars : [
		'mseFile',
		'mooseModel',
		'listOfResults',
		'implementations',
		'interfaces',
		'isLoaded'
	],
	#category : #GitMiner
}

{ #category : #'as yet unclassified' }
GMInterfaceMine class >> fromMSE: aFileReference [ 
	| mine |
	mine := self new.
	mine mseFile: aFileReference.
	^mine
]

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

{ #category : #initialization }
GMInterfaceMine >> initialize [
	super initialize.
	isLoaded := false.
]

{ #category : #'as yet unclassified' }
GMInterfaceMine >> interfaces [
	^ interfaces
]

{ #category : #'As yet unclassified' }
GMInterfaceMine >> interfacesForImplementation: aFAMIXClass [ 
	^((aFAMIXClass superInheritances collect: #superclass) select: #isInterface) reject: #isStub.
]

{ #category : #'as yet unclassified' }
GMInterfaceMine >> isLoaded [
	^isLoaded
]

{ #category : #'as yet unclassified' }
GMInterfaceMine >> load [
	| mseStream |
	listOfResults := LinkedList new.
	implementations := Set new.
	mseStream := mseFile readStream.
	[ :job | 
	| count classes |
	job title: 'Loading MSE file: ' , mseFile fullPath fullName.
	mseStream
		ifNotNil: [ mooseModel := MooseModel importFromMSEStream: mseStream.
			mseStream close ]
		ifNil: [ self error: 'The MSE file ' , mseFile , ' is not valid.' ].

	"Find implementations and clients for each interface"
	job title: 'Collecting interfaces'.
	classes := self mooseClassesForDependencyMining: mooseModel.
	count := 0.
	interfaces := (classes
		select: [ :each | 
			count := count + 1.
			job progress: count / classes size.
			each isInterface and: [ each numberOfMethods > 0 ] ]) asSet ] asJob
		run.
	interfaces
		do: [ :interface | 
			| localClients localProtectedClients localUnprotectedClients localImplementations classesReferencingLocalImplementations |
			"Sub-interfaces are rejected because they are not implementations"
			"Stubs are rejected because they're not under control of the project"
			"AnonymouseClasses are rejected because they're inside a file (and won't ever be committed as a separate file)"
			localImplementations := interface directSubclasses
				reject: [ :cls | cls isInterface | cls isStub | cls isAnonymousClass ].
			implementations addAll: localImplementations.
			localClients := (self localClientsFrom: interface)
				reject: [ :client | client sourceAnchor isNil ].

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
										makeEntryForProtectedGroup: true
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
										makeEntryForProtectedGroup: false
										client: client
										interface: interface
										implementation: imp) ] ] ]
		displayingProgress: 'Mining: Classifying interface clients'.
	isLoaded := true
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
GMInterfaceMine >> makeEntryForProtectedGroup: isProtected client: client interface: interface implementation: imp [
	"makes an array element with the info"

	^ {client mooseName.
	GMUtility normalizedFileName: client sourceAnchor fileName.
	interface mooseName.	"this is sometimes a stub, so can't get source always"
	imp mooseName.
	GMUtility normalizedFileName: imp sourceAnchor fileName.
	isProtected	"protected"}
]

{ #category : #'as yet unclassified' }
GMInterfaceMine >> mooseClassesForDependencyMining: aMooseModel [ 
	"Cyril F. helped immensely with crafting the class selection so as not to have strangeness in classes"
	^((aMooseModel allWithSubTypesOf: FamixTClass) reject: #isStub) reject: #isAnonymousClass
]

{ #category : #'as yet unclassified' }
GMInterfaceMine >> mseFile [
	^mseFile
]

{ #category : #'as yet unclassified' }
GMInterfaceMine >> mseFile: aFileReference [ 
	mseFile := aFileReference.
]
