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
		'wizard',
		'feedbackMessage'
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
				withConstraints: [ :constraints | 
					constraints
						height: 40; width: 150 ];
		add: #feedbackMessage
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
	feedbackMessage text: ''.
	wizard := GMMSEGeneratorWizard new.
	wizard
		javaSourcePath: javaSourcePresenter input text asFileReference;
		verveineJScriptPath: parserPresenter input text asFileReference;
		mseDestinationPath:
			destinationPresenter input text asFileReference / fileName input text
				, 'mse'.
	feedbackMessage text: 'Generating MSE file... Please wait...'.
	wizard generateMSE.
	wizard mseDestinationPath asFileReference exists
		ifTrue: [ feedbackMessage text: 'MSE file successfully generated!' ]
		ifFalse: [ feedbackMessage text: 'MSE file NOT generated.' ]
]

{ #category : #initialization }
MSEGenerator >> initialExtent [
	^ 600 @ 250 + 40 + 10
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
				input:
					(self newTextInput
						autoAccept: true;
						placeholder: 'The path to a Java project for which to generate the MSE file')).
	selectSourceButton := self newButton
		icon: (self iconNamed: 'glamorousOpen').
	parserPresenter := self
		instantiate:
			(SpLabelledPresenter
				label: 'Parser path: '
				input:
					(self newTextInput
						autoAccept: true;
						placeholder: 'The path to a Java-to-MSE parser such as VerveineJ')).
	parserPresenter
		description:
			'See https://github.com/NicolasAnquetil/VerveineJ (verveinej.sh) for a parser.'.
	selectParserButton := self newButton
		icon: (self iconNamed: 'glamorousOpen').
	destinationPresenter := self
		instantiate:
			(SpLabelledPresenter
				label: 'Destination path: '
				input: (self newTextInput autoAccept: true;
						placeholder: 'The path where the MSE file will be created')).
	selectDestinationButton := self newButton
		icon: (self iconNamed: 'glamorousOpen').
	fileName := self
		instantiate:
			(SpLabelledPresenter
				label: 'File name: '
				input: (self newTextInput autoAccept: true;
						placeholder: 'The name of the MSE file (without the .mse extension)')).
	generateMSEButton := self newButton
		label: 'Generate MSE file';
		disable.
	feedbackMessage := self
		instantiate:
			(SpTextPresenter new
				text: '';
				disable).
	self focusOrder
		add: javaSourcePresenter;
		add: parserPresenter;
		add: destinationPresenter;
		add: fileName
]

{ #category : #initialization }
MSEGenerator >> initializeWindow: aWindowPresenter [
	aWindowPresenter
		title: self title;
		initialExtent: self initialExtent
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
	| green red newFeedbackMsgText |
	green := Color red: 240 green: 255 blue: 240.
	red := Color red: 255 green: 240 blue: 240.
	generateMSEButton enabled: self manageButton.
	newFeedbackMsgText := ''.
	javaSourcePresenter input
		color:
			(javaSourcePresenter input text asFileReference exists
				& javaSourcePresenter input text isNotEmpty
				ifTrue: [ green ]
				ifFalse: [ newFeedbackMsgText := newFeedbackMsgText , 'Java source path is invalid. '. red ]).
	parserPresenter input
		color:
			(parserPresenter input text asFileReference isFile
				ifTrue: [ green ]
				ifFalse: [ newFeedbackMsgText := newFeedbackMsgText , 'Parser path is invalid. '. red ]).
	destinationPresenter input
		color:
			(destinationPresenter input text asFileReference exists
				& destinationPresenter input text isNotEmpty
				ifTrue: [ green ]
				ifFalse: [ newFeedbackMsgText := newFeedbackMsgText , 'Destination path is invalid. '. red ]).
	feedbackMessage text: newFeedbackMsgText; color: (newFeedbackMsgText isEmpty ifTrue:[ Color white ] ifFalse:[ red]).

]
