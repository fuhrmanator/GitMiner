Class {
	#name : #MSEGenerator,
	#superclass : #SpPresenter,
	#instVars : [
		'javaSourcePresenter',
		'parserPresenter',
		'destinationPresenter',
		'generateMSEButton',
		'selectSourceButton',
		'selectParserButton',
		'selectDestinationButton',
		'fileName',
		'wizard'
	],
	#category : #'GitMiner-GUI'
}

{ #category : #specs }
MSEGenerator class >> defaultSpec [
	^ SpBoxLayout newVertical
		add: '' withConstraints: [ :constraints | constraints height: 10 ];
		add:
			(SpBoxLayout newHorizontal
				add: #javaSourcePresenter;
				add:
					(SpBoxLayout newVertical
						add: #selectSourceButton
						withConstraints: [ :constraints | constraints height: 25 ])
					withConstraints: [ :constraints | constraints width: 25 ])
			withConstraints: [ :constraints | constraints height: 40 ];
		add:
			(SpBoxLayout newHorizontal
				add: #parserPresenter;
				add:
					(SpBoxLayout newVertical
						add: #selectParserButton
						withConstraints: [ :constraints | constraints height: 25 ])
					withConstraints: [ :constraints | constraints width: 25 ])
			withConstraints: [ :constraints | constraints height: 40 ];
		add:
			(SpBoxLayout newHorizontal
				add: #destinationPresenter;
				add:
					(SpBoxLayout newVertical
						add: #selectDestinationButton
						withConstraints: [ :constraints | constraints height: 25 ])
					withConstraints: [ :constraints | constraints width: 25 ])
			withConstraints: [ :constraints | constraints height: 40 ];
		add:
			(SpBoxLayout newHorizontal
				add: #fileName;
				add:
					(SpBoxLayout newVertical
						add: '.mse'
						withConstraints: [ :constraints | constraints height: 25 ])
					withConstraints: [ :constraints | constraints width: 30 ])
			withConstraints: [ :constraints | constraints height: 40 ];
		add: #generateMSEButton
			withConstraints: [ :constraints | constraints height: 40 ];
		yourself
]

{ #category : #examples }
MSEGenerator class >> open [
<example>
self new openWithSpec
]

{ #category : #action }
MSEGenerator >> generateMSE [
	wizard := GMMSEGeneratorWizard new.
	wizard
		javaSourcePath: javaSourcePresenter input text asFileReference;
		verveineJScriptPath: parserPresenter input text asFileReference;
		mseDestinationPath:
			destinationPresenter input text asFileReference / fileName input text
				, 'mse'.
	wizard generateMSE.
	self assert: wizard mseDestinationPath asFileReference exists
]

{ #category : #initialization }
MSEGenerator >> initialExtent [
	^ 600 @ 250
]

{ #category : #initialization }
MSEGenerator >> initializePresenter [
	javaSourcePresenter input
		whenTextChangedDo: [ self verifyPaths ].
	parserPresenter input
		whenTextChangedDo: [ self verifyPaths ].
	destinationPresenter input
		whenTextChangedDo: [ self verifyPaths ].
	fileName input whenTextChangedDo: [ self verifyPaths ].
	selectSourceButton action: [ self selectSource ].
	selectParserButton action: [ self selectParser ].
	selectDestinationButton action: [ self selectDestination ].
	generateMSEButton action: [ self generateMSE ]
]

{ #category : #initialization }
MSEGenerator >> initializeWidgets [
	javaSourcePresenter := self
		instantiate:
			(SpLabelledPresenter
				label: 'Java source path: '
				input: (self newTextInput autoAccept: true)).
	selectSourceButton := self newButton
		icon: (self iconNamed: 'glamorousOpen').
	parserPresenter := self
		instantiate:
			(SpLabelledPresenter
				label: 'Parser path: '
				input: (self newTextInput autoAccept: true)).
	selectParserButton := self newButton
		icon: (self iconNamed: 'glamorousOpen').
	destinationPresenter := self
		instantiate:
			(SpLabelledPresenter
				label: 'Destination path: '
				input: (self newTextInput autoAccept: true)).
	selectDestinationButton := self newButton
		icon: (self iconNamed: 'glamorousOpen').
	fileName := self
		instantiate:
			(SpLabelledPresenter
				label: 'File name: '
				input: (self newTextInput autoAccept: true)).
	generateMSEButton := self newButton label: 'Generate MSE file' ;disable.
	self focusOrder
		add: javaSourcePresenter;
		add: parserPresenter;
		add: destinationPresenter
]

{ #category : #initialization }
MSEGenerator >> initializeWindow: aWindowPresenter [
	aWindowPresenter
		title: self title;
		initialExtent: self initialExtent.
]

{ #category : #action }
MSEGenerator >> manageButton [
	javaSourcePresenter input text ifEmpty: [ ^ false ].
	parserPresenter input text ifEmpty: [ ^ false ].
	destinationPresenter input text ifEmpty: [ ^ false ].
	fileName input text ifEmpty: [ ^ false ].
	^ javaSourcePresenter input text asFileReference exists
		& parserPresenter input text asFileReference exists
		& destinationPresenter input text asFileReference exists
]

{ #category : #action }
MSEGenerator >> selectDestination [
	| reference lastPath |
	lastPath := destinationPresenter input text asFileReference.
	lastPath exists
		ifFalse: [ lastPath := FileLocator home ].
	reference := UIManager default
		chooseExistingFileReference: 'Select a destination'
		extensions: ''
		path: lastPath.
	reference
		ifNotNil: [ destinationPresenter input text: reference pathString ]
]

{ #category : #action }
MSEGenerator >> selectParser [
	| reference lastPath |
	lastPath := parserPresenter input text asFileReference.
	lastPath exists
		ifFalse: [ lastPath := FileLocator home ].
	reference := UIManager default
		chooseExistingFileReference: 'Select a parser'
		extensions: #('bat' 'sh')
		path: lastPath.
(	reference isNotNil and:[reference extension = 'bat' or:[reference extension = 'sh'] ])
		ifTrue: [ parserPresenter input text: reference pathString ]
]

{ #category : #action }
MSEGenerator >> selectSource [
	| reference lastPath |
	lastPath := javaSourcePresenter input text asFileReference.
	lastPath exists
		ifFalse: [ lastPath := FileLocator home ].
	reference := UIManager default
		chooseExistingFileReference: 'Select a Java source'
		extensions: ''
		path: lastPath.
	reference
		ifNotNil: [ javaSourcePresenter  input text: reference pathString ]
]

{ #category : #api }
MSEGenerator >> title [
^'MSE File Generator'
]

{ #category : #'as yet unclassified' }
MSEGenerator >> verifyPaths [
	| green red |
	green := Color red: 200 green: 255 blue: 200.
	red := Color red: 255 green: 200 blue: 200.
	generateMSEButton enabled: self manageButton.
	javaSourcePresenter input
		color:
			(javaSourcePresenter input text asFileReference exists
				ifTrue: [ green ]
				ifFalse: [ red ]).
	parserPresenter  input
		color:
			(parserPresenter input text asFileReference exists
				ifTrue: [ green ]
				ifFalse: [ red ]).
	destinationPresenter  input
		color:
			(destinationPresenter input text asFileReference exists
				ifTrue: [ green ]
				ifFalse: [ red ])
]
