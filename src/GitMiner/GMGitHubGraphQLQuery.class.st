"
I represent a query in GitHub's GraphQL API (REST). I depend on ZnClient.
"
Class {
	#name : #GMGitHubGraphQLQuery,
	#superclass : #Object,
	#instVars : [
		'token'
	],
	#category : #GitMiner
}

{ #category : #example }
GMGitHubGraphQLQuery class >> example [
	| query resultJSON queryInstance |
	query := 'query { viewer { login }}'.
	"see https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line"
	queryInstance := self new token: 'YOURTOKENFROMGITHUB'.
	resultJSON := queryInstance doGraphQLQuery: query.
	Transcript show: 'Login query result: ', resultJSON; cr.

	query := 'query { repository(owner:"isaacs", name:"github") {issues(states:OPEN) {totalCount}}}'.
	resultJSON := queryInstance doGraphQLQuery: query.
	Transcript show: 'Issue count query result: ', resultJSON; cr.
]

{ #category : #accessing }
GMGitHubGraphQLQuery >> doGraphQLQuery: graphQLquery [  
	| escaper | 
	"escape any double-quotes in the GraphQL query"
	escaper := [ :stringToEscape | stringToEscape copyWithRegex: '\"' matchesReplacedWith: '\"' ].	
	^ZnClient new
		url: 'https://api.github.com/graphql';
		headerAt: 'Authorization' put: 'bearer ', self token; 
		entity: (ZnEntity 
        with: '{"query": "' , (escaper value: graphQLquery )  , '"}'
        type: ZnMimeType applicationJson);
	post
]

{ #category : #accessing }
GMGitHubGraphQLQuery >> token [
	^ token
]

{ #category : #accessing }
GMGitHubGraphQLQuery >> token: anObject [
	token := anObject
]
