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
	#name : #RepoMine,
	#superclass : #Object,
	#instVars : [
		'pathToRepo',
		'fromTag',
		'toTag',
		'commitFilter'
	],
	#category : #'Fuhrman-MooseHerder'
}

{ #category : #accessing }
RepoMine >> commitFilter [
	^ commitFilter
]

{ #category : #accessing }
RepoMine >> commitFilter: anObject [
	commitFilter := anObject
]

{ #category : #accessing }
RepoMine >> fromTag [
	^ fromTag
]

{ #category : #accessing }
RepoMine >> fromTag: anObject [
	fromTag := anObject
]

{ #category : #accessing }
RepoMine >> pathToRepo [
	^ pathToRepo
]

{ #category : #accessing }
RepoMine >> pathToRepo: anObject [
	pathToRepo := anObject
]

{ #category : #accessing }
RepoMine >> toTag [
	^ toTag
]

{ #category : #accessing }
RepoMine >> toTag: anObject [
	toTag := anObject
]
