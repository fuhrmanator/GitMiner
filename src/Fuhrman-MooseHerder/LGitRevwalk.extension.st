Extension { #name : #LGitRevwalk }

{ #category : #'*Fuhrman-MooseHerder' }
LGitRevwalk >> hideGlob: glob [
	self withReturnHandlerDo: [ self revwalk_hide_glob: glob ]
]

{ #category : #'*Fuhrman-MooseHerder' }
LGitRevwalk >> pushGlob: glob [
	self withReturnHandlerDo: [ self revwalk_push_glob: glob ]
]

{ #category : #'*Fuhrman-MooseHerder' }
LGitRevwalk >> pushRange: range [
	self withReturnHandlerDo: [ self revwalk_push_range: range ]
]

{ #category : #'*Fuhrman-MooseHerder' }
LGitRevwalk >> revwalk_hide_glob: glob [
	^ self
		call: #(LGitReturnCodeEnum git_revwalk_hide_glob #(self , String glob))
		options: #()
]

{ #category : #'*Fuhrman-MooseHerder' }
LGitRevwalk >> revwalk_push_glob: glob [
	^ self
		call: #(LGitReturnCodeEnum git_revwalk_push_glob #(self , String glob))
		options: #()
]

{ #category : #'*Fuhrman-MooseHerder' }
LGitRevwalk >> revwalk_push_range: range [
	^ self
		call: #(LGitReturnCodeEnum git_revwalk_push_range #(self , String range))
		options: #()
]
