"
Usage: mooseminer [--help] <mse file>
	--help                   list this help message
	--quit    if specified, the image exits without saving after mining
	--save    if specified, save the image after mining
	--ifilter=<prefix>  only select interfaces starting with this prefix
	--uml     if specified, generate a PlantUML class file (experimental)  
	<mse file>          an existing MSE (Famix) file to load in Moose

Documentation:
A CommandLineHandler that processes (mines) a FAMIX model loaded in from an MSE file and generates output in a .CSV file. 
"
Class {
	#name : #GMMooseMinerCommandLineHandler,
	#superclass : #PharoCommandLineHandler,
	#instVars : [
		'unprotectedClientDictionary',
		'protectedClientDictionary'
	],
	#category : #GitMiner
}

{ #category : #accessing }
GMMooseMinerCommandLineHandler class >> commandName [
	^ 'mooseminer'
]

{ #category : #accessing }
GMMooseMinerCommandLineHandler class >> description [
	^ 'My Directly evaluates passed in one line scripts'
]

{ #category : #'handler selection' }
GMMooseMinerCommandLineHandler class >> isResponsibleFor: commandLineArguments [
	"directly handle top-level -e and --evaluate options"
	commandLineArguments withFirstArgument: [ :arg| 
		(#('-e' '--evaluate') includes: arg)
			ifTrue: [ ^ true ]].
	
	^ commandLineArguments includesSubCommand: self commandName
]

{ #category : #'writing CSV files' }
GMMooseMinerCommandLineHandler class >> writeClientImplementationPairs: myIFList [
	"CSV with 4 columns: Client, Interface, Implementation, Protectedness"
	FileStream
		forceNewFileNamed: 'ClientInterfaceImplementationProtectedness.csv'
		do: [ :csvStream | 
			myIFList
				do: [ :e | 
					| interface imps allClients |
					"Interface"
					interface := e at: 1.

					"Implementations"
					imps := e at: 4.

					"Protected clients and Unprotected clients"
					allClients := (e at: 2) union: (e at: 3).

					"Write pairs of clients and implementations, stating if the relationship is protected or not"
					allClients
						do: [ :client | 
							imps
								do: [ :imp | 
									| isProtected |
									isProtected := imp clientTypes includes: client.
									"Write the CSV line"
									csvStream
										ascii;
										nextPut: $";
										nextPutAll: client mooseName;
										nextPut: $";
										nextPut: $,;
										nextPut: $";
										nextPutAll: interface mooseName;
										nextPut: $";
										nextPut: $,;
										nextPut: $";
										nextPutAll: imp mooseName;
										nextPut: $";
										nextPut: $,.
									isProtected
										ifTrue: [ csvStream nextPut: $1 ]
										ifFalse: [ csvStream nextPut: $0 ].
									csvStream nextPut: Character cr ] ] ] ].

]

{ #category : #'writing CSV files' }
GMMooseMinerCommandLineHandler class >> writeInterfaces: interfaces [
	" Generate a CSV with interfaces"
	FileStream
		forceNewFileNamed: 'Interfaces.csv'
		do: [ :csvStream | 
			interfaces
				do: [ :interface | 
					csvStream
						ascii;
						nextPutAll: interface mooseName;
						cr ] ].


]

{ #category : #'writing CSV files' }
GMMooseMinerCommandLineHandler class >> writePlantUMLOutput: myIFList [
	| plantUMLFile |
	"PlantUML output"
	plantUMLFile := 'modelUML.puml'.
	FileStream
		forceNewFileNamed: plantUMLFile
		do: [ :stream | 
			stream
				nextPutAll: '@startuml';
				cr.
			stream
				nextPutAll: 'skinparam style strictuml';
				cr.
			stream
				nextPutAll: 'hide empty members';
				cr.
			stream
				nextPutAll: 'skinparam backgroundColor transparent';
				cr.
			stream
				nextPutAll: 'skinparam classBorderColor transparent';
				cr.
			stream
				nextPutAll: 'skinparam classArrowColor lightgreen';
				cr.
			stream
				nextPutAll: 'left to right direction';
				cr.
			stream
				nextPutAll: 'scale 0.1';
				cr.
			stream
				nextPutAll: 'set namespaceSeparator ::';
				cr.
			stream
				nextPutAll: '''This file generated from Pharo/Smalltalk, C. Fuhrman, École de technologie supérieure';
				cr.
			myIFList
				do: [ :e | 
					| ifName imps |
					"Interface"
					ifName := (e at: 1) mooseName.
					stream
						nextPutAll: 'package "VZ.' , ifName , '" #dddddd {';
						cr.
					stream
						nextPutAll: 'interface "' , ifName , '" #lightblue';
						cr.
					"Implementations"
					imps := e at: 4.
					imps
						do: [ :sImp | 
							stream
								nextPutAll: 'class "' , sImp mooseName , '" #yellow {';
								cr.
							stream
								nextPutAll: 'LOC:' , sImp numberOfLinesOfCode asString;
								cr.
							stream
								nextPutAll: '}';
								cr.
							stream
								nextPutAll: '"' , sImp mooseName , '" .[#lightblue].|> "' , ifName , '"';
								cr ].
					stream
						nextPutAll: '}';
						cr.	"close Variability zone package"
					"Protected clients"
					(e at: 2)
						do: [ :sClient | 
							stream
								nextPutAll: 'class "' , sClient mooseName , '" #lightgreen {';
								cr.
							stream
								nextPutAll: 'LOC:' , sClient numberOfLinesOfCode asString;
								cr.
							stream
								nextPutAll: '}';
								cr.
							stream
								nextPutAll: '"' , sClient mooseName , '"' , ' --> ' , '"' , ifName , '"';
								cr ].
					"Unprotected clients"
					(e at: 3)
						do: [ :sClient | 
							stream
								nextPutAll: 'class "' , sClient mooseName , '" #pink {';
								cr.
							stream
								nextPutAll: 'LOC:' , sClient numberOfLinesOfCode asString;
								cr.
							stream
								nextPutAll: '}';
								cr.
							stream
								nextPutAll: '"' , sClient mooseName , '"' , ' --> ' , '"' , ifName , '"';
								cr.
							"Link to implementation(s)"
							imps
								do: [ :imp | 
									(imp clientTypes includes: sClient)
										ifTrue: [ stream
												nextPutAll: '"' , sClient mooseName , '"' , ' -[bold,#red]-> ' , '"' , imp mooseName , '"';
												cr ] ] ] ].
			stream
				nextPutAll: '@enduml';
				cr ]
]

{ #category : #activation }
GMMooseMinerCommandLineHandler >> activate [
	self activateHelp
		ifTrue: [  ^ self ].
		
	self arguments 
		ifEmpty: [ ^ self ]. "Like an error if no arguments..."

   self mineArguments.
			
	(self hasOption: 'save')
		ifTrue: [ 
			^ Smalltalk 
				snapshot: true 
				andQuit: (self hasOption: 'quit') not ].
	
	(self hasOption: 'quit')
		ifFalse: [ self quit ]
]

{ #category : #commands }
GMMooseMinerCommandLineHandler >> addProtectedLink: sClient wrt: interface [
	"Add a protected link to the interface to the client dictionary"

	| clients clientDic pLinksSet |
	clientDic := protectedClientDictionary.	"instance variable"
	clients := clientDic keys.
	"create existing pLinksSet if needed"
	pLinksSet := (clients includes: sClient)
		ifTrue: [ clientDic at: sClient ]
		ifFalse: [ Set new ].
	"add the link"
	pLinksSet add: interface.
	"Transcript
		show: 'addProtectedLink: pLinksSet ';
		show: pLinksSet;
		cr."
	clientDic at: sClient put: pLinksSet.
	^ pLinksSet
]

{ #category : #commands }
GMMooseMinerCommandLineHandler >> addUnprotectedLink: sClient wrt: interface becauseOf: implementation [
	"Add a protected link to the interface to the client dictionary"

	| clients clientDic uLinksSet |
	clientDic := unprotectedClientDictionary.	"instance variable"
	clients := clientDic keys.
	"create existing pLinksSet if needed"
	uLinksSet := (clients includes: sClient)
		ifTrue: [ clientDic at: sClient ]
		ifFalse: [ Set new ].
	"add the link"
	uLinksSet
		add:
			{interface.
			implementation}.
	"Transcript
		show: 'addProtectedLink: pLinksSet ';
		show: uLinksSet;
		cr."
	clientDic at: sClient put: uLinksSet.
	^ uLinksSet
]

{ #category : #activation }
GMMooseMinerCommandLineHandler >> argumentString [
	| arguments skipArguments |
	
	"Now this is ugly... Coral would be nice here! Basically we strip skipArguments if, and only if they appear at the beginning of arguments"
	skipArguments := #( '--quit' '--save' '--uml').

	arguments := (skipArguments includes: self arguments first)
		ifFalse: [ self arguments ]
		ifTrue: [
			(self arguments size >= 2 and: [ skipArguments includes: self arguments second ])
				ifTrue: [ self arguments allButFirst: 2 ]
				ifFalse: [ self arguments allButFirst ]].
		
	^ arguments joinUsing: Character space.
]

{ #category : #commands }
GMMooseMinerCommandLineHandler >> classifyClients: myIFList [
	"convert the IF list into a client Map structure"

	|  |

	""
	myIFList
		do: [ :e | 
			| interface imps |
			"Interface"
			interface := (e at: 1).
"			Transcript show: 'classifyClients: Processing interface ', interface mooseName; cr."
			"Implementations"
			imps := e at: 4.
			"Protected clients"
			(e at: 2) do: [ :sClient | 
				"add interface to the clientDictionary"
"				Transcript show: 'classifyClients: adding pClient ', sClient mooseName; cr."
				self addProtectedLink: sClient wrt: interface.
				"blah := sClient mooseName" ].	
			"Unprotected clients"
			(e at: 3)
				do: [ :sClient | 
					imps
						do: [ :imp | 
							(imp clientTypes includes: sClient)
								ifTrue: [ 
"									Transcript show: 'classifyClients: adding uClient ', sClient mooseName, ' because of link to ', imp mooseName; cr."
									self addUnprotectedLink: sClient wrt: interface becauseOf:imp ] ]
					 ]	].
]

{ #category : #activation }
GMMooseMinerCommandLineHandler >> evaluateArguments [
	| argumentString |
	argumentString :=  self argumentString.
	argumentString ifEmpty: [ ^ self ].
	self evaluate: argumentString
]

{ #category : #commands }
GMMooseMinerCommandLineHandler >> mine: mseStream withUML: plantUMLOut withPrefix: ifPrefix [
	"Load the MSE into Moose, then process it (this is hard-coded here)"

	| interfaces clients protectedClients unprotectedClients implementations myIFList mooseModel sharedSet |
	"Improve memory footprint by restricting elements of the model?"
	"	contextSelected := #(#Parameter #UnknownVariable #LocalVariable #Class #Invocation #AnnotationType #Package #AnnotationTypeAttribute #EnumValue #GlobalVariable #TypeAlias #Module #Method #Enum #Function #Reference #PrimitiveType #Inheritance #Access #ParameterType #Comment #ParameterizedType #ParameterizableClass #ImplicitVariable #Namespace).
"
	"	importingContext := FAMIXStandardImportingContext new.
	importingContext importAll: contextSelected."
	"List of Interfaces, Clients, etc. for output"
	myIFList := LinkedList new.
	implementations := Set new.
	clients := Set new.
	protectedClients := Set new.
	unprotectedClients := Set new.
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
			implementations := implementations , localImplementations.
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
			clients := clients , localClients.	"Collect all clients"
			refLocalImplementations := Set new.	"don't allow duplicates"

			"Classify protected and unprotected clients"
			localImplementations do: [ :implementation | refLocalImplementations := refLocalImplementations , implementation clientTypes ].
			localProtectedClients := localClients difference: refLocalImplementations.
			localUnprotectedClients := localClients intersection: refLocalImplementations.
			localUnprotectedClients isEmpty not
				ifTrue: [ unprotectedClients := unprotectedClients , localUnprotectedClients ].

			"Save the interface entry in the list"
			myIFList
				add:
					{interface.
					localProtectedClients.
					localUnprotectedClients.
					localImplementations asSet} ].
	protectedClients := clients difference: unprotectedClients.
	"Assertion that protectedClients and unprotectedClients are distinct"
	sharedSet := protectedClients intersection: unprotectedClients.
	sharedSet isEmpty not
		ifTrue: [ Transcript
				show: 'Warning: Intersection of protected and unprotected clients is not empty. Here are the shared elements:';
				show: sharedSet;
				cr ].
	GMMooseMinerCommandLineHandler writeClientImplementationPairs: myIFList.
	GMMooseMinerCommandLineHandler writeInterfaces: interfaces.

	"Separate dictionaries for each type of clients"
	self classifyClients: myIFList.
	self writeClients.

	"PlantUML output"
	plantUMLOut
		ifTrue: [ self writePlantUMLClients.
			GMMooseMinerCommandLineHandler writePlantUMLOutput: myIFList ]
]

{ #category : #commands }
GMMooseMinerCommandLineHandler >> mineArguments [
	"Verify there's an MSE file in arguments and then process it"

	| mseFiles resolvedMseFile ifPrefix |

	"parse the prefix if present"
	ifPrefix := (self hasOption: 'ifilter') 
           ifTrue: [self optionAt: 'ifilter']  " could fail if nothing specified?"
           ifFalse: [ '' ].

	"find the file name in the arguments"
   mseFiles := self commandLine arguments select: [ :arg|
		arg endsWith: '.mse' ]. 
	
	"Only take the first one, make sure it's valid"
	resolvedMseFile := FileSystem disk resolve: mseFiles first.

   "Init the instance variable?"
	protectedClientDictionary := Dictionary new.
	unprotectedClientDictionary := Dictionary new.

   self mine: (FileStream readOnlyFileNamed: resolvedMseFile) 
        withUML: (self hasOption: 'uml') 
        withPrefix: ifPrefix
]

{ #category : #'writing CSV files' }
GMMooseMinerCommandLineHandler >> writeClients [
  	|   |
	" Generate a CSV with protected clients and their interfaces"
	FileStream
		forceNewFileNamed: 'ProtectedClients.csv'
		do: [ :csvStream | 
			protectedClientDictionary
				keysDo: [ :client | 
					| pLinks |
					csvStream
						ascii;
						nextPut: $";
						nextPutAll: client mooseName;
						nextPut: $";
						nextPut: $,;
						nextPutAll: client numberOfLinesOfCode asString;
						nextPut: $,.
					"Set of interfaces to which this client has a protected status"
					pLinks := protectedClientDictionary at: client.
					pLinks
						do: [ :pIF | 
							csvStream
								ascii;
								nextPutAll: pIF mooseName;
								space ].
					csvStream cr ] ].

	" Generate a CSV with protected clients and their interfaces"
	FileStream
		forceNewFileNamed: 'UnprotectedClients.csv'
		do: [ :csvStream | 
			unprotectedClientDictionary
				keysDo: [ :client | 
					| uLinks |
					csvStream
						ascii;
						nextPut: $";
						nextPutAll: client mooseName;
						nextPut: $";
						nextPut: $,;
						nextPutAll: client numberOfLinesOfCode asString;
						nextPut: $,.
					"Set of interfaces to which this client has a protected status"
					uLinks := unprotectedClientDictionary at: client.
					uLinks
						do: [ :uIFImpArray | 
							csvStream
								ascii;
								nextPutAll: (uIFImpArray at: 1) mooseName;
								nextPut: $+;
								nextPutAll: (uIFImpArray at: 2) mooseName;
								space ].
					csvStream cr ] ].


]

{ #category : #'writing CSV files' }
GMMooseMinerCommandLineHandler >> writePlantUMLClients [
	"Generate a PlantUML file showing clients and their interfaces"

	| clientSet pClients uClients writtenInterfaces writtenImplementations |
	"Set of all clients, protected and unprotected"
	pClients := protectedClientDictionary keys.
	uClients := unprotectedClientDictionary keys.
	clientSet := pClients union: uClients.
	"Don't add interfaces more than once to the PlantUML output"
	writtenInterfaces := Set new.
	writtenImplementations := Set new.
	FileStream
		forceNewFileNamed: 'Clients.puml'
		do: [ :stream | 
			stream
				nextPutAll: '@startuml';
				cr.
			stream
				nextPutAll: 'skinparam style strictuml';
				cr.
			stream
				nextPutAll: 'hide empty members';
				cr.
			stream
				nextPutAll: 'skinparam backgroundColor transparent';
				cr.
			stream
				nextPutAll: 'skinparam classBorderColor transparent';
				cr.
			stream
				nextPutAll: 'skinparam classArrowColor lightgreen';
				cr.
			stream
				nextPutAll: 'left to right direction';
				cr.
			stream
				nextPutAll: 'scale 0.1';
				cr.
			stream
				nextPutAll: 'set namespaceSeparator ::';
				cr.
			stream
				nextPutAll: '''This file generated from Pharo/Smalltalk, C. Fuhrman, École de technologie supérieure';
				cr.
			clientSet
				do: [ :client | 
					| clientColor interfaces unprotLinks |
					(pClients includes: client)
						ifTrue: [ (uClients includes: client)
								ifTrue: [ clientColor := '#lightgreen-pink' ]
								ifFalse: [ clientColor := '#lightgreen' ] ]
						ifFalse: [ clientColor := '#pink' ].
					stream
						nextPutAll: 'class "';
						nextPutAll: client mooseName;
						nextPutAll: '" ';
						nextPutAll: clientColor;
						cr.
					"Output the interfaces that the client links to"
					(pClients includes: client)
						ifTrue: [ interfaces := protectedClientDictionary at: client.
							interfaces
								do: [ :interface | 
									(writtenInterfaces includes: interface)
										ifFalse: [ writtenInterfaces add: interface.
											stream
												nextPutAll: 'interface "';
												nextPutAll: interface mooseName;
												nextPutAll: '" <<interface>> #lightblue';
												cr ].
									stream
										nextPutAll: '"';
										nextPutAll: client mooseName;
										nextPutAll: '" --> "';
										nextPutAll: interface mooseName;
										nextPutAll: '"';
										"Link to the interface from the client"
											cr ] ].
					(uClients includes: client)
						ifTrue: [ unprotLinks := unprotectedClientDictionary at: client.
							unprotLinks
								do: [ :link | 
									| interface implementation tempLink |
									interface := link at: 1.
									implementation := link at: 2.
									(writtenInterfaces includes: interface)
										ifFalse: [ writtenInterfaces add: interface.
											stream
												nextPutAll: 'interface "';
												nextPutAll: interface mooseName;
												nextPutAll: '" <<interface>> #lightblue';
												cr ].
									"Link to the interface from the client"
									stream
										nextPutAll: '"';
										nextPutAll: client mooseName;
										nextPutAll: '" -[#orange]-> "';
										nextPutAll: interface mooseName;
										nextPutAll: '"';
										cr.
									"Implementation of the interface"
									tempLink := interface mooseName , implementation mooseName.
									(writtenImplementations includes: tempLink)
										ifFalse: [ writtenImplementations add: tempLink.
											stream
												nextPutAll: 'class "';
												nextPutAll: implementation mooseName;
												nextPutAll: '" #yellow';
												cr.
											stream
												nextPutAll: '"';
												nextPutAll: implementation mooseName;
												nextPutAll: '" -[dashed,#blue]-|> "';
												nextPutAll: interface mooseName;
												nextPutAll: '"';
												cr ].
									"Link to the implementation from the client"
									stream
										nextPutAll: '"';
										nextPutAll: client mooseName;
										nextPutAll: '" -[bold,#red]-> "';
										nextPutAll: implementation mooseName;
										nextPutAll: '"';
										cr ] ] ].
			stream
				nextPutAll: '@enduml';
				cr ]
]
