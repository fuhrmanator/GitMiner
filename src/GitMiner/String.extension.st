Extension { #name : #String }

{ #category : #'*GitMiner' }
String >> compareWithInsensitiveEqualElement: aString [
	"implementation to allow for consistent sorting with case-insensitive strings"

	self = aString
		ifTrue: [ ^ true ].
	self
		doWithIndex: [ :char :ind | 
			char = (aString at: ind)
				ifFalse: [ ^ (char isLowercase) ] ]
]
