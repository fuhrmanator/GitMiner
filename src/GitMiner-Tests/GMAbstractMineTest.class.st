Class {
	#name : #GMAbstractMineTest,
	#superclass : #TestCase,
	#instVars : [
		'mseFile',
		'mseStream',
		'mooseModel',
		'classes'
	],
	#category : #'GitMiner-Tests'
}

{ #category : #'helper methods' }
GMAbstractMineTest >> classFromMooseName: aString [ 
	"get the FAMIXclass that corresponds to the Moose Name"
	| matches |
	matches := classes
		select: [ :c | c mooseName = aString ].
	self assert: matches size equals: 1.
	^matches first
]

{ #category : #running }
GMAbstractMineTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

	super setUp.
	"The MSE string could be put into a test method and loaded that way so the tests can run in CI."
	"mseFile := FileSystem disk workingDirectory / 'pharo-local'
		/ 'iceberg' / 'fuhrmanator' / 'GitMiner' / 'tests'
		/ 'FactoryVariants.mse'."
	mseFile := '___FactoryVariants_HEAD.mse' asFileReference.
	mseFile
		ensureDelete;
		writeStreamDo: [ :stream | 
			stream
				nextPutAll: GMInterfaceMineTest mseFileFactoryVariantsHardCodedString ].
	mseStream := mseFile readStream.
	mooseModel := MooseModel importFromMSEStream: mseStream.
	classes := ((mooseModel allWithSubTypesOf: FamixTClass)
		reject: #isStub) reject: #isAnonymousClass
]

{ #category : #tests }
GMAbstractMineTest >> testCreationFromMSE [
	"create a mine from an mseFile"
	| iMine  |
	iMine := GMInterfaceMine fromMSE: mseFile.
	self assert: iMine isNotNil.
	self assert: iMine mseFile equals: mseFile.
]

{ #category : #tests }
GMAbstractMineTest >> testInterfaces [
	"create a mine from an mseFile"

	| iMine interfaceMooseNames |
	iMine := GMInterfaceMine fromMSE: mseFile.
	iMine load.
	"mooseIDs are (sadly) different in this test, so we only check equality with mooseName"
	interfaceMooseNames := iMine interfaces collect: #mooseName.
	self
		assert: interfaceMooseNames
		equals: ((Set withAll:
			{(self classFromMooseName: 'simple_factory::IProduct').
			(self
				classFromMooseName: 'headfirst::designpatterns::factory::pizzaaf::PizzaIngredientFactory').
			(self
				classFromMooseName: 'headfirst::designpatterns::factory::pizzaaf::Clams').
			(self
				classFromMooseName: 'headfirst::designpatterns::factory::pizzaaf::Dough').
			(self
				classFromMooseName: 'headfirst::designpatterns::factory::pizzaaf::Pepperoni').
			(self
				classFromMooseName: 'headfirst::designpatterns::factory::pizzaaf::Sauce').
			(self
				classFromMooseName: 'headfirst::designpatterns::factory::pizzaaf::Cheese').
			(self
				classFromMooseName: 'headfirst::designpatterns::factory::pizzaaf::Veggies')}) collect: #mooseName).
				
]

{ #category : #tests }
GMAbstractMineTest >> testIsLoaded [
	"comment stating purpose of message"

	| iMine |
	iMine := GMInterfaceMine fromMSE: mseFile.
	self deny: iMine isLoaded.
	iMine load.
	self assert: iMine isLoaded.

]

{ #category : #tests }
GMAbstractMineTest >> testLoad [
	"create a mine from an mseFile"
	| iMine |
	iMine := GMInterfaceMine fromMSE: mseFile.
	iMine load.
	self assert: iMine isLoaded.
	self assert: iMine interfaces size equals: 8.

]
