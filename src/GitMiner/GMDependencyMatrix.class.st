Class {
	#name : #GMDependencyMatrix,
	#superclass : #Object,
	#instVars : [
		'classes',
		'matrix'
	],
	#category : #'GitMiner-Change-modeling'
}

{ #category : #'as yet unclassified' }
GMDependencyMatrix class >> withClasses: classes [
	| d |
	d := PMMatrix zerosRows: classes size cols: classes size.
	"d := Array2D rows: classes size columns: classes size."
	classes
		doWithIndex: [ :classJ :j | 
			| classJClients |
			classJClients := (classJ clientTypes reject: #isStub)
				reject: #isAnonymousClass.
			"clientTypes includes inheritance, so we can just put 1's in the array for each classJClient"
			classJClients
				do: [ :classI | 
					| i |
					"find index of classI in classes to find the column"
					i := classes indexOf: classI.
					self assert: i ~= 0.
					d at: i at: j put: 1 ] ].
	^ GMDependencyMatrix new
		matrix: d;
		classes: classes
]

{ #category : #accessing }
GMDependencyMatrix >> classes [
	^ classes
]

{ #category : #accessing }
GMDependencyMatrix >> classes: anObject [
	classes := anObject
]

{ #category : #accessing }
GMDependencyMatrix >> matrix [
	^ matrix
]

{ #category : #accessing }
GMDependencyMatrix >> matrix: anObject [
	matrix := anObject
]
