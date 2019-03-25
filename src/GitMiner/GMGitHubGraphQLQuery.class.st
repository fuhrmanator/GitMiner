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

{ #category : #'as yet unclassified' }
GMGitHubGraphQLQuery >> doGraphiQLQuery: graphiQLQueryString [ 
	"This method expects a query copied from the GraphiQL Tool (which includes variables) using 'Copy to clipboard' option, and already escapes the double-quotes properly."	
	^ZnClient new
		url: 'https://api.github.com/graphql';
		headerAt: 'Authorization' put: 'bearer ', self token; 
		entity: (ZnEntity 
        with: graphiQLQueryString
        type: ZnMimeType applicationJson);
	post
]

{ #category : #'as yet unclassified' }
GMGitHubGraphQLQuery >> endCursorFromJSONDict: resultDic [ 
	^ (((resultDic at: 'data') at: 'search') at: 'pageInfo') at: 'endCursor' 
]

{ #category : #'as yet unclassified' }
GMGitHubGraphQLQuery >> makeFirstBlockQuery: blockSize queryString: queryString [ 
	^ '{
  "query": "query topRepos($query: String!) {\n  search(first: ', blockSize asString, ', query: $query, type: REPOSITORY) {\n    repositoryCount\n    pageInfo {\n      endCursor\n    }\n    nodes {\n      ... on Repository {\n        nameWithOwner \n        pullRequests (states:MERGED) {\n          totalCount\n        }\n        stargazers {\n          totalCount\t\n        }\n        forkCount\n        issues(states:CLOSED){ totalCount}\n      }\n    }\n  }\n}\n",
  "variables": {
    "query": "' , queryString , '"
  }
}'
]

{ #category : #'as yet unclassified' }
GMGitHubGraphQLQuery >> makeFollowingBlockQuery: blockSize after: endCursorString queryString: queryString [ 
	^ '{
  "query": "query topRepos($query: String!) {\n  search(first: ', blockSize asString, ', after: \"' , endCursorString , '\", query: $query, type: REPOSITORY) {\n    repositoryCount\n    pageInfo {\n      endCursor\n    }\n    nodes {\n      ... on Repository {\n        nameWithOwner \n        pullRequests (states:MERGED) {\n          totalCount\n        }\n        stargazers {\n          totalCount\t\n        }\n        forkCount\n        issues(states:CLOSED){ totalCount}\n      }\n    }\n  }\n}\n",
  "variables": {
    "query": "' , queryString , '"
  }
}'
]

{ #category : #'as yet unclassified' }
GMGitHubGraphQLQuery >> projectCountFromJSONDict: resultDic [ 
	^((resultDic at: 'data') at: 'search') at: 'repositoryCount'
]

{ #category : #'as yet unclassified' }
GMGitHubGraphQLQuery >> projectsFromJSONDict: resultDic [ 
	| projectsFetchedCollection |
	projectsFetchedCollection := ((resultDic at: 'data') at: 'search') at: 'nodes'.
	^ (projectsFetchedCollection collect: [ :p | 
	 Dictionary newFrom: { 
		#nameWithOwner->(p at: 'nameWithOwner') . 
		#forkCount->(p at: 'forkCount') . 
		#closedIssuesCount->((p at: 'issues') at: 'totalCount') . 
		#mergePullRequestsCount->((p at: 'pullRequests') at: 'totalCount') . 
		#stargazersCount->((p at: 'stargazers') at: 'totalCount') 
	 } 
  ]) asOrderedCollection
]

{ #category : #accessing }
GMGitHubGraphQLQuery >> token [
	^ token
]

{ #category : #accessing }
GMGitHubGraphQLQuery >> token: anObject [
	token := anObject
]
