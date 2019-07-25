Extension { #name : #PMMatrix }

{ #category : #'*GitMiner' }
PMMatrix >> principalDiagonal [
	"https://en.wikipedia.org/wiki/Diagonal#Matrices for definitions"
	| diag |
	"Check for square"
	self isSquare ifFalse: [ self error: 'Diagonal is not defined for a matrix that is not square.' ].
	diag := PMVector new: self rows size.
	(1 to: diag size) do: [ :i | diag at: i put: (self at:i at: i) ].
	^ diag
]
