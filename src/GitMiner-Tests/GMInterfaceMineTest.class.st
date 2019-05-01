Class {
	#name : #GMInterfaceMineTest,
	#superclass : #TestCase,
	#instVars : [
		'mseFile',
		'mooseModel',
		'classes',
		'aClient',
		'anImplementation',
		'anImplementationsClients'
	],
	#category : #'GitMiner-Tests'
}

{ #category : #'helper methods' }
GMInterfaceMineTest >> classFromMooseName: aString [ 
	"get the FAMIXclass that corresponds to the Moose Name"
	^(classes
		select: [ :c | c mooseName = aString ])
		first
]

{ #category : #running }
GMInterfaceMineTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

	| mseStream |
	super setUp.
	mseFile := FileSystem disk workingDirectory / 'pharo-local'
		/ 'iceberg' / 'fuhrmanator' / 'GitMiner' / 'tests'
		/ 'FactoryVariants.mse'.
	mseStream := mseFile readStream.
	mooseModel := MooseModel importFromMSEStream: mseStream.
	classes := mooseModel allWithSubTypesOf: FamixTClass.
	aClient := self
		classFromMooseName: '<Default Package>::ClientNoFactoryMain'.
	anImplementation := self classFromMooseName: 'no_factory::ProductA'.
	anImplementationsClients := Set
		withAll:
			{aClient.
			(self classFromMooseName: '<Default Package>::ClientOfFactoryMain').
			(self classFromMooseName: 'simple_factory::SimpleFactory')}
]

{ #category : #tests }
GMInterfaceMineTest >> testClientsForImplementation [
	| iMine frozenClams frozenClamsClients chicagoPizzaIngredientFactory chicagoPizzaIngredientFactoryClients |
	iMine := GMInterfaceMine fromMSE: mseFile.
	iMine load.
	self
		assert: (iMine clientsForImplementation: anImplementation)
		equals: anImplementationsClients.
	frozenClams := self
		classFromMooseName: 'headfirst::designpatterns::factory::pizzaaf::FrozenClams'.
	frozenClamsClients := Set
		withAll:
			{(self
				classFromMooseName: 'headfirst::designpatterns::factory::pizzaaf::PizzaIngredientFactory').
			(self
				classFromMooseName:
					'headfirst::designpatterns::factory::pizzaaf::ChicagoPizzaIngredientFactory').
			(self
				classFromMooseName:
					'headfirst::designpatterns::factory::pizzaaf::NYPizzaIngredientFactory').
			(self
				classFromMooseName: 'headfirst::designpatterns::factory::pizzaaf::Pizza')}.
	self
		assert: (iMine clientsForImplementation: frozenClams)
		equals: frozenClamsClients.
	"Special case with a client that's also an implementation"	
	chicagoPizzaIngredientFactory := self
		classFromMooseName: 'headfirst::designpatterns::factory::pizzaaf::ChicagoPizzaIngredientFactory'.
	chicagoPizzaIngredientFactoryClients := Set
		withAll:
			{(self
				classFromMooseName: 'headfirst::designpatterns::factory::pizzaaf::PepperoniPizza').
			(self
				classFromMooseName:
					'headfirst::designpatterns::factory::pizzaaf::CheesePizza').
			(self
				classFromMooseName:
					'headfirst::designpatterns::factory::pizzaaf::VeggiePizza').
			(self
				classFromMooseName:
					'headfirst::designpatterns::factory::pizzaaf::NYPizzaStore').
			(self
				classFromMooseName:
					'headfirst::designpatterns::factory::pizzaaf::ChicagoPizzaStore').
			(self
				classFromMooseName: 'headfirst::designpatterns::factory::pizzaaf::ClamPizza')}.
	self
		assert: (iMine clientsForImplementation: chicagoPizzaIngredientFactory)
		equals: chicagoPizzaIngredientFactoryClients
]

{ #category : #tests }
GMInterfaceMineTest >> testCreationFromMSE [
	"create a mine from an mseFile"
	| iMine  |
	iMine := GMInterfaceMine fromMSE: mseFile.
	self assert: iMine isNotNil.
	self assert: iMine mseFile equals: mseFile.
]

{ #category : #tests }
GMInterfaceMineTest >> testLoad [
	"create a mine from an mseFile"
	| iMine |
	self assert: mseFile exists.
	iMine := GMInterfaceMine fromMSE: mseFile.
	iMine load.
	self assert: iMine isLoaded.
	self assert: iMine interfaces size equals: 8.

]
