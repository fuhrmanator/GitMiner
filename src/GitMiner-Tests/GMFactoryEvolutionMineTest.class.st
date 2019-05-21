"
A GMFactoryEvolutionMineTest is a test class for testing the behavior of GMFactoryEvolutionMine
"
Class {
	#name : #GMFactoryEvolutionMineTest,
	#superclass : #GMAbstractMineTest,
	#category : #'GitMiner-Tests'
}

{ #category : #'tests - helper' }
GMFactoryEvolutionMineTest >> assignmentToStringForTestResultComparison: assignment [
	| tmpStr news |

	tmpStr := assignment variable sourceCode , ' ('
		, assignment variable famixVariable declaredType mooseName , ') = '
		, assignment expression sourceCode , ' ('.
	"Order is important, so sort it"
	news := (assignment toScope: FASTJavaNewExpression) sorted: [:a :b | a startPos > b startPos ].
	"Halt if: [news size > 1]."
	news
		doWithIndex: [ :newEx :i | 
			tmpStr := tmpStr , newEx famix to first parentType mooseName.
			i < news size
				ifTrue: [ tmpStr := tmpStr , ',' ] ].
	^ (tmpStr , ')') withSeparatorsCompacted "get rid of funny whitespace"
]

{ #category : #running }
GMFactoryEvolutionMineTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

	super setUp.

]

{ #category : #tests }
GMFactoryEvolutionMineTest >> testAssignmentsOfImplementations [

	| iMine assignmentsOfImplementations expectedAssignmentsSourceCode |
	iMine := GMFactoryEvolutionMine fromMSE: mseFile.
	iMine load.
	iMine sourceFolder: (mseFile parent / mseFile basenameWithoutExtension) fullName.

	assignmentsOfImplementations := iMine assignmentsOfImplementations.
	
	"Hard-coded expected results from the sample MSE file, should catch regressions."
	"Strings generated from the following code run on Raw of the assignmentsOfImplementations:"
	"assignmentsOfImplementations do: [ :a | self logCr: '''', (self assignmentToStringForTestResultComparison: a) ,''' .' ]."
	"Do not FORMAT the code of this method."
	expectedAssignmentsSourceCode := { 'veggies (headfirst::designpatterns::factory::pizzaaf::Veggies) = { new Garlic(), new Onion(), new Mushroom(), new RedPepper() } (headfirst::designpatterns::factory::pizzaaf::RedPepper,headfirst::designpatterns::factory::pizzaaf::Mushroom,headfirst::designpatterns::factory::pizzaaf::Onion,headfirst::designpatterns::factory::pizzaaf::Garlic)' .
'pizza (headfirst::designpatterns::factory::pizzaaf::Pizza) = new CheesePizza(ingredientFactory) (headfirst::designpatterns::factory::pizzaaf::CheesePizza)' .
'pizza (headfirst::designpatterns::factory::pizzafm::Pizza) = new ChicagoStyleCheesePizza() (headfirst::designpatterns::factory::pizzafm::ChicagoStyleCheesePizza)' .
'pizza (headfirst::designpatterns::factory::pizzas::Pizza) = new CheesePizza() (headfirst::designpatterns::factory::pizzas::CheesePizza)' .
'productA (simple_factory::IProduct) = new ProductA(1, 2) (no_factory::ProductA)' .
'veggies (headfirst::designpatterns::factory::pizzaaf::Veggies) = { new BlackOlives(), new Spinach(), new Eggplant() } (headfirst::designpatterns::factory::pizzaaf::Eggplant,headfirst::designpatterns::factory::pizzaaf::Spinach,headfirst::designpatterns::factory::pizzaaf::BlackOlives)' .
'pizza (headfirst::designpatterns::factory::pizzafm::Pizza) = new NYStyleCheesePizza() (headfirst::designpatterns::factory::pizzafm::NYStyleCheesePizza)' .
'product (static_factory::Product) = new ProductA() (static_factory::ProductA)' .
'pizza (headfirst::designpatterns::factory::pizzaaf::Pizza) = new ClamPizza(ingredientFactory) (headfirst::designpatterns::factory::pizzaaf::ClamPizza)' .
'pizza (headfirst::designpatterns::factory::pizzafm::Pizza) = new NYStyleVeggiePizza() (headfirst::designpatterns::factory::pizzafm::NYStyleVeggiePizza)' .
'pizza (headfirst::designpatterns::factory::pizzaaf::Pizza) = new PepperoniPizza(ingredientFactory) (headfirst::designpatterns::factory::pizzaaf::PepperoniPizza)' .
'nyStore (headfirst::designpatterns::factory::pizzaaf::PizzaStore) = new NYPizzaStore() (headfirst::designpatterns::factory::pizzaaf::NYPizzaStore)' .
'pizza (headfirst::designpatterns::factory::pizzaaf::Pizza) = new VeggiePizza(ingredientFactory) (headfirst::designpatterns::factory::pizzaaf::VeggiePizza)' .
'pizza (headfirst::designpatterns::factory::pizzafm::Pizza) = new NYStyleClamPizza() (headfirst::designpatterns::factory::pizzafm::NYStyleClamPizza)' .
'productA (no_factory::ProductA) = new ProductA(1, 2) (no_factory::ProductA)' .
'pizza (headfirst::designpatterns::factory::pizzaaf::Pizza) = new PepperoniPizza(ingredientFactory) (headfirst::designpatterns::factory::pizzaaf::PepperoniPizza)' .
'product (simple_factory::IProduct) = new ProductC() (simple_factory::ProductC)' .
'product (simple_factory::IProduct) = new ProductB() (simple_factory::ProductB)' .
'pizza (headfirst::designpatterns::factory::pizzafm::Pizza) = new NYStylePepperoniPizza() (headfirst::designpatterns::factory::pizzafm::NYStylePepperoniPizza)' .
'product (static_factory::Product) = new ProductB() (static_factory::ProductB)' .
'productA (simple_factory::IProduct) = new no_factory.ProductA(1, 2) (no_factory::ProductA)' .
'productB (simple_factory::IProduct) = new ProductB() (no_factory::ProductB)' .
'pizza (headfirst::designpatterns::factory::pizzafm::Pizza) = new ChicagoStylePepperoniPizza() (headfirst::designpatterns::factory::pizzafm::ChicagoStylePepperoniPizza)' .
'product (static_factory::Product) = new ProductC() (static_factory::ProductC)' .
'productC (simple_factory::IProduct) = new ProductC() (no_factory::ProductC)' .
'chicagoStore (headfirst::designpatterns::factory::pizzafm::PizzaStore) = new ChicagoPizzaStore() (headfirst::designpatterns::factory::pizzafm::ChicagoPizzaStore)' .
'chicagoStore (headfirst::designpatterns::factory::pizzaaf::PizzaStore) = new ChicagoPizzaStore() (headfirst::designpatterns::factory::pizzaaf::ChicagoPizzaStore)' .
'pizza (headfirst::designpatterns::factory::pizzafm::Pizza) = new ChicagoStyleVeggiePizza() (headfirst::designpatterns::factory::pizzafm::ChicagoStyleVeggiePizza)' .
'pizza (headfirst::designpatterns::factory::pizzas::Pizza) = new ClamPizza() (headfirst::designpatterns::factory::pizzas::ClamPizza)' .
'ingredientFactory (headfirst::designpatterns::factory::pizzaaf::PizzaIngredientFactory) = new ChicagoPizzaIngredientFactory() (headfirst::designpatterns::factory::pizzaaf::ChicagoPizzaIngredientFactory)' .
'pizza (headfirst::designpatterns::factory::pizzaaf::Pizza) = new VeggiePizza(ingredientFactory) (headfirst::designpatterns::factory::pizzaaf::VeggiePizza)' .
'pizza (headfirst::designpatterns::factory::pizzaaf::Pizza) = new ClamPizza(ingredientFactory) (headfirst::designpatterns::factory::pizzaaf::ClamPizza)' .
'pizza (headfirst::designpatterns::factory::pizzas::Pizza) = new VeggiePizza() (headfirst::designpatterns::factory::pizzas::VeggiePizza)' .
'pizza (headfirst::designpatterns::factory::pizzaaf::Pizza) = new CheesePizza(ingredientFactory) (headfirst::designpatterns::factory::pizzaaf::CheesePizza)' .
'pizza (headfirst::designpatterns::factory::pizzas::Pizza) = new PepperoniPizza() (headfirst::designpatterns::factory::pizzas::PepperoniPizza)' .
'product (simple_factory::IProduct) = new ProductA(2) (simple_factory::ProductA)' .
'pizza (headfirst::designpatterns::factory::pizzafm::Pizza) = new ChicagoStyleClamPizza() (headfirst::designpatterns::factory::pizzafm::ChicagoStyleClamPizza)' .
'nyStore (headfirst::designpatterns::factory::pizzafm::PizzaStore) = new NYPizzaStore() (headfirst::designpatterns::factory::pizzafm::NYPizzaStore)' .
'ingredientFactory (headfirst::designpatterns::factory::pizzaaf::PizzaIngredientFactory) = new NYPizzaIngredientFactory() (headfirst::designpatterns::factory::pizzaaf::NYPizzaIngredientFactory)' .
  }.

	self assert: assignmentsOfImplementations notEmpty.
		
	expectedAssignmentsSourceCode do: [ :eaCode | 
		"self crLog: eaCode. self crLog: '---'." 
		self assert: (assignmentsOfImplementations anySatisfy: [ :a | |resultCode | resultCode := self assignmentToStringForTestResultComparison: a. 
			"self crLog: resultCode. self crLog: ' ==>' , (resultCode = eaCode) asString." 
			(resultCode = eaCode) ]) ]
]

{ #category : #tests }
GMFactoryEvolutionMineTest >> testAssignmentsOfImplementationsWithUpcasting [
	| iMine assignmentsOfImplementationsWithUpcasting expectedAssignmentsSourceCode |
	iMine := GMFactoryEvolutionMine fromMSE: mseFile.
	iMine load.
	iMine sourceFolder: (mseFile parent / mseFile basenameWithoutExtension) fullName.

	assignmentsOfImplementationsWithUpcasting := iMine assignmentsOfImplementationsWithUpCasting.

	"Hard-coded expected results from the sample MSE file, should catch regressions."
	"Strings generated from the following code run on Raw of the assignmentsOfImplementations:"
	"assignmentsOfImplementationsWithUpcasting do: [ :a | self logCr: '''', (self assignmentToStringForTestResultComparison: a) ,''' .' ]."
	"Do not FORMAT the code of this method."

expectedAssignmentsSourceCode := { 'veggies (headfirst::designpatterns::factory::pizzaaf::Veggies) = { new Garlic(), new Onion(), new Mushroom(), new RedPepper() } (headfirst::designpatterns::factory::pizzaaf::RedPepper,headfirst::designpatterns::factory::pizzaaf::Mushroom,headfirst::designpatterns::factory::pizzaaf::Onion,headfirst::designpatterns::factory::pizzaaf::Garlic)' .
'pizza (headfirst::designpatterns::factory::pizzas::Pizza) = new CheesePizza() (headfirst::designpatterns::factory::pizzas::CheesePizza)' .
'product (static_factory::Product) = new ProductB() (static_factory::ProductB)' .
'pizza (headfirst::designpatterns::factory::pizzaaf::Pizza) = new PepperoniPizza(ingredientFactory) (headfirst::designpatterns::factory::pizzaaf::PepperoniPizza)' .
'nyStore (headfirst::designpatterns::factory::pizzaaf::PizzaStore) = new NYPizzaStore() (headfirst::designpatterns::factory::pizzaaf::NYPizzaStore)' .
'pizza (headfirst::designpatterns::factory::pizzas::Pizza) = new ClamPizza() (headfirst::designpatterns::factory::pizzas::ClamPizza)' .
'pizza (headfirst::designpatterns::factory::pizzaaf::Pizza) = new PepperoniPizza(ingredientFactory) (headfirst::designpatterns::factory::pizzaaf::PepperoniPizza)' .
'pizza (headfirst::designpatterns::factory::pizzaaf::Pizza) = new CheesePizza(ingredientFactory) (headfirst::designpatterns::factory::pizzaaf::CheesePizza)' .
'product (static_factory::Product) = new ProductC() (static_factory::ProductC)' .
'pizza (headfirst::designpatterns::factory::pizzafm::Pizza) = new NYStyleCheesePizza() (headfirst::designpatterns::factory::pizzafm::NYStyleCheesePizza)' .
'pizza (headfirst::designpatterns::factory::pizzas::Pizza) = new VeggiePizza() (headfirst::designpatterns::factory::pizzas::VeggiePizza)' .
'pizza (headfirst::designpatterns::factory::pizzafm::Pizza) = new ChicagoStyleVeggiePizza() (headfirst::designpatterns::factory::pizzafm::ChicagoStyleVeggiePizza)' .
'product (simple_factory::IProduct) = new ProductB() (simple_factory::ProductB)' .
'pizza (headfirst::designpatterns::factory::pizzaaf::Pizza) = new CheesePizza(ingredientFactory) (headfirst::designpatterns::factory::pizzaaf::CheesePizza)' .
'pizza (headfirst::designpatterns::factory::pizzafm::Pizza) = new ChicagoStyleCheesePizza() (headfirst::designpatterns::factory::pizzafm::ChicagoStyleCheesePizza)' .
'pizza (headfirst::designpatterns::factory::pizzafm::Pizza) = new NYStyleVeggiePizza() (headfirst::designpatterns::factory::pizzafm::NYStyleVeggiePizza)' .
'productC (simple_factory::IProduct) = new ProductC() (no_factory::ProductC)' .
'ingredientFactory (headfirst::designpatterns::factory::pizzaaf::PizzaIngredientFactory) = new NYPizzaIngredientFactory() (headfirst::designpatterns::factory::pizzaaf::NYPizzaIngredientFactory)' .
'chicagoStore (headfirst::designpatterns::factory::pizzaaf::PizzaStore) = new ChicagoPizzaStore() (headfirst::designpatterns::factory::pizzaaf::ChicagoPizzaStore)' .
'chicagoStore (headfirst::designpatterns::factory::pizzafm::PizzaStore) = new ChicagoPizzaStore() (headfirst::designpatterns::factory::pizzafm::ChicagoPizzaStore)' .
'pizza (headfirst::designpatterns::factory::pizzaaf::Pizza) = new VeggiePizza(ingredientFactory) (headfirst::designpatterns::factory::pizzaaf::VeggiePizza)' .
'productB (simple_factory::IProduct) = new ProductB() (no_factory::ProductB)' .
'pizza (headfirst::designpatterns::factory::pizzafm::Pizza) = new ChicagoStylePepperoniPizza() (headfirst::designpatterns::factory::pizzafm::ChicagoStylePepperoniPizza)' .
'nyStore (headfirst::designpatterns::factory::pizzafm::PizzaStore) = new NYPizzaStore() (headfirst::designpatterns::factory::pizzafm::NYPizzaStore)' .
'pizza (headfirst::designpatterns::factory::pizzas::Pizza) = new PepperoniPizza() (headfirst::designpatterns::factory::pizzas::PepperoniPizza)' .
'pizza (headfirst::designpatterns::factory::pizzafm::Pizza) = new NYStyleClamPizza() (headfirst::designpatterns::factory::pizzafm::NYStyleClamPizza)' .
'ingredientFactory (headfirst::designpatterns::factory::pizzaaf::PizzaIngredientFactory) = new ChicagoPizzaIngredientFactory() (headfirst::designpatterns::factory::pizzaaf::ChicagoPizzaIngredientFactory)' .
'product (static_factory::Product) = new ProductA() (static_factory::ProductA)' .
'productA (simple_factory::IProduct) = new ProductA(1, 2) (no_factory::ProductA)' .
'veggies (headfirst::designpatterns::factory::pizzaaf::Veggies) = { new BlackOlives(), new Spinach(), new Eggplant() } (headfirst::designpatterns::factory::pizzaaf::Eggplant,headfirst::designpatterns::factory::pizzaaf::Spinach,headfirst::designpatterns::factory::pizzaaf::BlackOlives)' .
'product (simple_factory::IProduct) = new ProductA(2) (simple_factory::ProductA)' .
'product (simple_factory::IProduct) = new ProductC() (simple_factory::ProductC)' .
'pizza (headfirst::designpatterns::factory::pizzaaf::Pizza) = new ClamPizza(ingredientFactory) (headfirst::designpatterns::factory::pizzaaf::ClamPizza)' .
'pizza (headfirst::designpatterns::factory::pizzafm::Pizza) = new NYStylePepperoniPizza() (headfirst::designpatterns::factory::pizzafm::NYStylePepperoniPizza)' .
'productA (simple_factory::IProduct) = new no_factory.ProductA(1, 2) (no_factory::ProductA)' .
'pizza (headfirst::designpatterns::factory::pizzafm::Pizza) = new ChicagoStyleClamPizza() (headfirst::designpatterns::factory::pizzafm::ChicagoStyleClamPizza)' .
'pizza (headfirst::designpatterns::factory::pizzaaf::Pizza) = new ClamPizza(ingredientFactory) (headfirst::designpatterns::factory::pizzaaf::ClamPizza)' .
'pizza (headfirst::designpatterns::factory::pizzaaf::Pizza) = new VeggiePizza(ingredientFactory) (headfirst::designpatterns::factory::pizzaaf::VeggiePizza)'
  }.
	self
		assert:  assignmentsOfImplementationsWithUpcasting notEmpty.

	expectedAssignmentsSourceCode do: [ :eaCode | 
		"self crLog: eaCode. self crLog: '---'." 
		self assert: (assignmentsOfImplementationsWithUpcasting anySatisfy: [ :a | |resultCode | resultCode := self assignmentToStringForTestResultComparison: a. 
			"self crLog: resultCode. self crLog: ' ==>' , (resultCode = eaCode) asString." 
			(resultCode = eaCode) ]) ]
]

{ #category : #tests }
GMFactoryEvolutionMineTest >> testAssignmentsOfImplementationsWithoutUpcasting [
	| iMine assignmentsOfImplementationsWithoutUpcasting expectedAssignmentsSourceCode |
	iMine := GMFactoryEvolutionMine fromMSE: mseFile.
	iMine load.
	iMine sourceFolder: (mseFile parent / mseFile basenameWithoutExtension) fullName.

	assignmentsOfImplementationsWithoutUpcasting := iMine assignmentsOfImplementationsWithoutUpCasting.

	"Hard-coded expected results from the sample MSE file, should catch regressions."
	"Strings generated from the following code run on Raw of the assignmentsOfImplementations:"
	"assignmentsOfImplementationsWithoutUpcasting do: [ :a | self logCr: '''', (self assignmentToStringForTestResultComparison: a) ,''' .' ]."
	"Do not FORMAT the code of this method."

expectedAssignmentsSourceCode := { 'productA (no_factory::ProductA) = new ProductA(1, 2) (no_factory::ProductA)' }.
	self
		assert:  assignmentsOfImplementationsWithoutUpcasting notEmpty.

	expectedAssignmentsSourceCode do: [ :eaCode | 
		"self crLog: eaCode. self crLog: '---'." 
		self assert: (assignmentsOfImplementationsWithoutUpcasting anySatisfy: [ :a | |resultCode | resultCode := self assignmentToStringForTestResultComparison: a. 
			"self crLog: resultCode. self crLog: ' ==>' , (resultCode = eaCode) asString." 
			(resultCode = eaCode) ]) ]
]

{ #category : #tests }
GMFactoryEvolutionMineTest >> testConstructors [
	| iMine constructors |
	iMine := GMFactoryEvolutionMine fromMSE: mseFile.
	iMine load.
	iMine sourceFolder: (mseFile parent / mseFile basenameWithoutExtension) fullName.	
	constructors := iMine constructors.
	
	self assert: constructors anyOne isConstructor.
	self assert: constructors anyOne isMethod.
]
