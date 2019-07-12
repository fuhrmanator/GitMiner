Class {
	#name : #MSEGenerator,
	#superclass : #SpPresenter,
	#instVars : [
		'javaSourcePath',
		'verveineJScriptPath',
		'mseDestinationPath',
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
				add: #javaSourcePath;
				add:
					(SpBoxLayout newVertical
						add: #selectSourceButton
						withConstraints: [ :constraints | constraints height: 25 ])
					withConstraints: [ :constraints | constraints width: 25 ])
			withConstraints: [ :constraints | constraints height: 40 ];
		add:
			(SpBoxLayout newHorizontal
				add: #verveineJScriptPath;
				add:
					(SpBoxLayout newVertical
						add: #selectParserButton
						withConstraints: [ :constraints | constraints height: 25 ])
					withConstraints: [ :constraints | constraints width: 25 ])
			withConstraints: [ :constraints | constraints height: 40 ];
		add:
			(SpBoxLayout newHorizontal
				add: #mseDestinationPath;
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
	javaSourcePath input accept.
	verveineJScriptPath input accept.
	mseDestinationPath input accept.
	fileName input accept.
	wizard := GMMSEGeneratorWizard new.
	wizard
		javaSourcePath: javaSourcePath input text;
		verveineJScriptPath: verveineJScriptPath input text;
		mseDestinationPath: mseDestinationPath input text, '/' , fileName input text , '.mse'.
		self halt.
	wizard generateMSE.
	self assert: wizard mseDestinationPath asFileReference exists.
]

{ #category : #initialization }
MSEGenerator >> initialExtent [
	^ 600 @ 250
]

{ #category : #initialization }
MSEGenerator >> initializePresenter [
	selectSourceButton action: [ self selectSource ].
	selectParserButton action: [ self selectParser ].
	selectDestinationButton action: [ self selectDestination ].
	generateMSEButton action: [ self  generateMSE]
]

{ #category : #initialization }
MSEGenerator >> initializeWidgets [
	javaSourcePath := self
		instantiate:
		(SpLabelledPresenter
		label: 'Java source path: '
		input: self newTextInput).
	selectSourceButton := self newButton
		icon: (self iconNamed: 'glamorousOpen').
	verveineJScriptPath := self
		instantiate: (SpLabelledPresenter label: 'Parser path: ' input: self newTextInput).
	selectParserButton := self newButton
		icon: (self iconNamed: 'glamorousOpen').
	mseDestinationPath := self
		instantiate:
			(SpLabelledPresenter
				label: 'Destination path: '
				input: self newTextInput).
	selectDestinationButton := self newButton
		icon: (self iconNamed: 'glamorousOpen').
	fileName := self
		instantiate: (SpLabelledPresenter label: 'File name: ' input: self newTextInput).
	generateMSEButton := self newButton label: 'Generate MSE file'.
	self focusOrder
		add: javaSourcePath;
		add: verveineJScriptPath;
		add: mseDestinationPath
]

{ #category : #initialization }
MSEGenerator >> initializeWindow: aWindowPresenter [
	aWindowPresenter
		title: self title;
		initialExtent: self initialExtent.
]

{ #category : #action }
MSEGenerator >> selectDestination [
	| reference |
	reference := UIManager default
		chooseExistingFileReference: 'Select a Java source'
		extensions: ''
		path: FileLocator home.
	reference
		ifNotNil: [ mseDestinationPath input text: reference pathString ]
]

{ #category : #action }
MSEGenerator >> selectParser [
	| reference |
	reference := UIManager default
		chooseExistingFileReference: 'Select a parser'
		extensions: #('bat' 'sh')
		path: FileLocator home.
	reference
		ifNotNil: [ verveineJScriptPath input text: reference pathString ]
]

{ #category : #action }
MSEGenerator >> selectSource [
	| reference |
	reference := UIManager default
		chooseExistingFileReference: 'Select a Java source'
		extensions: ''
		path: FileLocator home.
	reference
		ifNotNil: [ javaSourcePath input text: reference pathString ]
]

{ #category : #api }
MSEGenerator >> title [
^'MSE File Generator'
]
