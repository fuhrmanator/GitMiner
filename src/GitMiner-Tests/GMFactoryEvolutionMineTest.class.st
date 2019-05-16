"
A GMFactoryEvolutionMineTest is a test class for testing the behavior of GMFactoryEvolutionMine
"
Class {
	#name : #GMFactoryEvolutionMineTest,
	#superclass : #GMAbstractMineTest,
	#category : #'GitMiner-Tests'
}

{ #category : #running }
GMFactoryEvolutionMineTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

	super setUp.
	"The MSE string could be put into a test method and loaded that way so the tests can run in CI."
	"mseFile := FileSystem disk workingDirectory / 'pharo-local'
		/ 'iceberg' / 'fuhrmanator' / 'GitMiner' / 'tests'
		/ 'FactoryVariants.mse'."
	mseFile := '___FactoryVariants_HEAD.mse' asFileReference.
	mseFile
		ensureDelete;
		writeStreamDo:
				[ :stream | stream nextPutAll: GMInterfaceMineTest  mseFileFactoryVariantsHardCodedString ].
	mseStream := mseFile readStream.
	mooseModel := MooseModel importFromMSEStream: mseStream.
	classes := ((mooseModel allWithSubTypesOf: FamixTClass)
		reject: #isStub) reject: #isAnonymousClass.
	"For test cases"
"	aClient := self
		classFromMooseName: '<Default Package>::ClientNoFactoryMain'.
	anImplementation := self classFromMooseName: 'no_factory::ProductA'.
	anImplementationsClients := Set
		withAll:
			{aClient.
			(self classFromMooseName: '<Default Package>::ClientOfFactoryMain').
			(self classFromMooseName: '<Default Package>::ClientWithUnprotected').
			(self classFromMooseName: 'simple_factory::SimpleFactory')}"
]

{ #category : #'as yet unclassified' }
GMFactoryEvolutionMineTest >> testAssignmentsOfImplementationsWithNoInterface [
	| iMine |
	iMine := GMFactoryEvolutionMine fromMSE: mseFile.
	iMine load.
	self
		assert:
			(iMine
				assignmentsOfImplementationsWithNoInterface)
		notEmpty.
]
