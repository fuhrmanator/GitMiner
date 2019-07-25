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

{ #category : #private }
GMAbstractMineTest >> performTest [
	"Use an empty logger during tests to not add any noise in logs."

	TinyCurrentLogger value: TinyLogger new during: [ super performTest ]
]

{ #category : #running }
GMAbstractMineTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

	| testRepoURL testRepoLocation tmpRoot |
	super setUp.
	"The MSE string could be put into a test method and loaded that way so the tests can run in CI."
	"mseFile := FileSystem disk workingDirectory / 'pharo-local'
		/ 'iceberg' / 'fuhrmanator' / 'GitMiner' / 'tests'
		/ 'FactoryVariants.mse'."
	"Clone the test repo, pull changes if it already exists"
	tmpRoot := FileLocator temp / 'GMTests'.
	mseFile := tmpRoot / 'FactoryVariants.mse'.
	testRepoURL := 'https://github.com/fuhrmanator/FactoryVariants'.
	testRepoLocation := tmpRoot / 'FactoryVariants'.
	"testRepoLocation deleteAll."
	testRepoLocation exists
		ifFalse: [ IceGitClone new
				location: testRepoLocation;
				url: testRepoURL;
				execute.
			"remove any MSE file as it's out of date"
			mseFile ensureDelete ]
		ifTrue:
			[ "pull changes" self flag: 'do a fetch/pull to get latest updates from remote' ].
	"regenerate the MSE if it doesn't exist"
	mseFile exists
		ifFalse: [ "regenerate the MSE, see GMUtility"
			self flag: 'automatically regenerate the MSE'.
			self
				error:
					'No MSE file found for ' , tmpRoot fullName
						,
							'. Please generate it again in a shell, e.g.: "cd /tmp/GMTests/FactoryVariants & /mnt/c/verveineJ/verveinej.sh -- -o ../FactoryVariants.mse -anchor assoc ."' ].
	"mseFile
		ensureDelete;
		writeStreamDo: [ :stream | 
			stream
				nextPutAll: GMInterfaceMineTest mseFileFactoryVariantsHardCodedString ]."
	mseStream := mseFile readStream.
	mooseModel := MooseModel importFromMSEStream: mseStream.
	"Hook the sources to the mooseModel"
	mooseModel rootFolder: testRepoLocation fullName.
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

{ #category : #tests }
GMAbstractMineTest >> testSourceFolder [
	"create a mine from an mseFile"
	| iMine  |
	iMine := GMInterfaceMine fromMSE: mseFile.
	iMine load.
	iMine sourceFolder: (mseFile parent / mseFile basenameWithoutExtension) fullName.
	self assert: iMine sourceFolder equals: '/tmp/GMTests/FactoryVariants_HEAD'.

]

{ #category : #tests }
GMAbstractMineTest >> testSourceFolderIsUseful [
	"create a mine from an mseFile"
	| iMine  |
	iMine := GMInterfaceMine fromMSE: mseFile.
	iMine load.
	iMine sourceFolder: (mseFile parent / mseFile basenameWithoutExtension) fullName.
	self assert: iMine sourceFolder equals: '/tmp/GMTests/FactoryVariants'.
	"see if source text is OK for the first implementation "
	self deny: iMine interfaces anyOne sourceText equals: ''.
]
