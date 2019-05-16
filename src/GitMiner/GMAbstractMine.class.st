Class {
	#name : #GMAbstractMine,
	#superclass : #Object,
	#instVars : [
		'mseFile',
		'mooseModel',
		'interfaces',
		'isLoaded'
	],
	#category : #GitMiner
}

{ #category : #'as yet unclassified' }
GMAbstractMine class >> fromMSE: aFileReference [ 
	| mine |
	mine := self new.
	mine mseFile: aFileReference.
	^mine
]

{ #category : #initialization }
GMAbstractMine >> initialize [
	super initialize.
	implementations := Set new.
	interfaces := Set new.
	isLoaded := false.

]

{ #category : #accessing }
GMAbstractMine >> interfaces [
	^ interfaces
]

{ #category : #'private - testing' }
GMAbstractMine >> interfaces: theListOfTheInterface [
	"For tests"
	interfaces := theListOfTheInterface
]

{ #category : #accessing }
GMAbstractMine >> isLoaded [
	^isLoaded
]

{ #category : #loading }
GMAbstractMine >> load [
	| mseStream |
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
	"Set the rootFolder for Moose so it can find the sources"
	"Should be in directory below MSE file with the same name (minus .MSE)"
	mooseModel
		rootFolder: mseFile parent / mseFile basenameWithoutExtension
]

{ #category : #'as yet unclassified' }
GMAbstractMine >> mooseClassesForDependencyMining: aMooseModel [ 
	"Cyril F. helped immensely with crafting the class selection so as not to have strangeness in classes"
	^((aMooseModel allWithSubTypesOf: FamixTClass) reject: #isStub) reject: #isAnonymousClass
]

{ #category : #accessing }
GMAbstractMine >> mseFile [
	^mseFile
]

{ #category : #accessing }
GMAbstractMine >> mseFile: aFileReference [ 
	mseFile := aFileReference.
]

{ #category : #'as yet unclassified' }
GMAbstractMine >> sourceFolder: aFileReference [ 
	mooseModel rootFolder: aFileReference 
]
