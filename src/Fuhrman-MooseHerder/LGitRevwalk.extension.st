Extension { #name : #LGitRevwalk }

{ #category : #'*Fuhrman-MooseHerder' }
LGitRevwalk >> pushRange: range [
	self withReturnHandlerDo: [ self revwalk_push_range: range ]
]
