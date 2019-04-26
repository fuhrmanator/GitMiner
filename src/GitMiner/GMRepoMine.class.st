"
I represent a mining operation on a git repository.

I encapsulate information about a mining operation. I know how to filter commits by time, tags, OIDs and allow other filters.

My main collaborators are LGit* classes.

---- TODO

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	commitFilter:		<Object>
	fromTag:		<Object>
	pathToRepo:		<Object>
	toTag:		<Object>


    Implementation Points
"
Class {
	#name : #GMRepoMine,
	#superclass : #Object,
	#instVars : [
		'pathToRepo',
		'fromTag',
		'toTag',
		'commitFilter',
		'url',
		'rootForClone'
	],
	#category : #GitMiner
}

{ #category : #'as yet unclassified' }
GMRepoMine >> cloneRepo [
	"clone a repo of a project (if it doesn't already exist) and return its handle "

	| location |
	"Get project name from URL, accounting for cases where it ends in .git"
	"Clone repo locally if not already there"
	location := self rootForClone / self projectName.
	location exists
		ifFalse: [ | cloneCommand working cloneDir gitErrors result |
			working := FileSystem disk workingDirectory.
			cloneDir := self rootForClone.
			cloneDir ensureCreateDirectory.
			gitErrors := working / 'tmp' / 'errors_gitClone'.
			gitErrors ensureCreateFile.
			
			cloneCommand := 'cd "' , cloneDir fullName , '" && git clone '
				, url , ' 2>"' , gitErrors fullName , '"'.
			result := LibC uniqueInstance system: cloneCommand.
			result = 0
				ifFalse: [ GMUtility
						abortWithErrorMessageFromFileReference: gitErrors asFileReference
						title: 'Failed to execute: ' , cloneCommand ] ].
	^ location
]

{ #category : #accessing }
GMRepoMine >> commitFilter [
	^ commitFilter
]

{ #category : #accessing }
GMRepoMine >> commitFilter: anObject [
	commitFilter := anObject
]

{ #category : #accessing }
GMRepoMine >> fromTag [
	^ fromTag
]

{ #category : #accessing }
GMRepoMine >> fromTag: anObject [
	fromTag := anObject
]

{ #category : #'as yet unclassified' }
GMRepoMine >> gitHubProjectName [
	"get the owner + project name from a github URL"
	| ownerName |
	ownerName := (url splitOn: '/') nextToLast.
	^ ownerName , '.' , self projectName 
]

{ #category : #accessing }
GMRepoMine >> pathToRepo [
	^ pathToRepo
]

{ #category : #accessing }
GMRepoMine >> pathToRepo: anObject [
	pathToRepo := anObject
]

{ #category : #accessing }
GMRepoMine >> projectName [
	"get the project name for the RepoMine"

	| projectName |
	projectName := (url splitOn: '/') last.
	(projectName endsWith: '.git')
		ifTrue: [ projectName := projectName allButLast: '.git' size ].
	^ projectName
]

{ #category : #accessing }
GMRepoMine >> rootForClone [
	^ rootForClone
]

{ #category : #accessing }
GMRepoMine >> rootForClone: path [
	rootForClone := path
]

{ #category : #accessing }
GMRepoMine >> toTag [
	^ toTag
]

{ #category : #accessing }
GMRepoMine >> toTag: anObject [
	toTag := anObject
]

{ #category : #accessing }
GMRepoMine >> url [
	^ url
]

{ #category : #'as yet unclassified' }
GMRepoMine >> url: aString [ 
	url := aString.
]
