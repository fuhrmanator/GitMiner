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

{ #category : #queries }
GMGitHubGraphQLQuery >> checkErrors: resultDic [ 
	(resultDic keys includes: 'errors') ifTrue: [ self error: ((resultDic at: 'errors' ) first at: 'message') ].
]

{ #category : #queries }
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

{ #category : #queries }
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

{ #category : #queries }
GMGitHubGraphQLQuery >> endCursorFromJSONDict: resultDic [ 
	^ (((resultDic at: 'data') at: 'search') at: 'pageInfo') at: 'endCursor' 
]

{ #category : #queries }
GMGitHubGraphQLQuery >> getProjectDataForSearchQuery: searchQuery [
	"Make multiple GitHub GraphQL queries to get an entire list of projects "

	| blockSize resultJSON resultDic builtQuery projectCount endCursor projects count |
	blockSize := 100.
	resultJSON := self doGraphQLQuery: 'query { viewer { login }}'.	"Log in"
	resultDic := NeoJSONReader fromString: resultJSON.
	self checkErrors: resultDic.

	"First query has no 'after' keyword, but follow-ups need to use the 'endCursor'"
	builtQuery := self
		makeFirstBlockQuery: blockSize
		queryString: searchQuery.
	resultJSON := self doGraphiQLQuery: builtQuery.
	resultDic := NeoJSONReader fromString: resultJSON.
	self checkErrors: resultDic.

	"working := FileSystem disk workingDirectory.
working / 'resultFromGraphiQL.json' writeStreamDo: [ :stream | stream nextPutAll: resultJSON ]."
	projectCount := self projectCountFromJSONDict: resultDic.
	endCursor := self endCursorFromJSONDict: resultDic.
	projects := self projectsFromJSONDict: resultDic.
	Transcript
		show: 'Got ' , projects size asString , ' new projects.';
		cr.
	count := blockSize.
	[ endCursor isNotNil ]
		whileTrue: [ | newProjects |
			Transcript
				show: 'Querying again for blocks after ' , count asString;
				cr.
			builtQuery := self
				makeFollowingBlockQuery: blockSize
				after: endCursor
				queryString: searchQuery.
			resultJSON := self doGraphiQLQuery: builtQuery.
			resultDic := NeoJSONReader fromString: resultJSON.
			self checkErrors: resultDic.
			endCursor := self endCursorFromJSONDict: resultDic.
			newProjects := self projectsFromJSONDict: resultDic.
			Transcript
				show: 'Got ' , newProjects size asString , ' new projects.';
				cr.
			projects := projects , newProjects.
			count := count + blockSize ].
	^ projects
]

{ #category : #queries }
GMGitHubGraphQLQuery >> makeFirstBlockQuery: blockSize queryString: queryString [ 
	^ '{
  "query": "query topRepos($query: String!) {\n  search(first: ', blockSize asString, ', query: $query, type: REPOSITORY) {\n    repositoryCount\n    pageInfo {\n      endCursor\n    }\n    nodes {\n      ... on Repository {\n        nameWithOwner \n        pullRequests (states:MERGED) {\n          totalCount\n        }\n        stargazers {\n          totalCount\t\n        }\n        forkCount\n        issues(states:CLOSED){ totalCount}\n      }\n    }\n  }\n}\n",
  "variables": {
    "query": "' , queryString , '"
  }
}'
]

{ #category : #queries }
GMGitHubGraphQLQuery >> makeFollowingBlockQuery: blockSize after: endCursorString queryString: queryString [ 
	^ '{
  "query": "query topRepos($query: String!) {\n  search(first: ', blockSize asString, ', after: \"' , endCursorString , '\", query: $query, type: REPOSITORY) {\n    repositoryCount\n    pageInfo {\n      endCursor\n    }\n    nodes {\n      ... on Repository {\n        nameWithOwner \n        pullRequests (states:MERGED) {\n          totalCount\n        }\n        stargazers {\n          totalCount\t\n        }\n        forkCount\n        issues(states:CLOSED){ totalCount}\n      }\n    }\n  }\n}\n",
  "variables": {
    "query": "' , queryString , '"
  }
}'
]

{ #category : #queries }
GMGitHubGraphQLQuery >> projectCountFromJSONDict: resultDic [ 
	^((resultDic at: 'data') at: 'search') at: 'repositoryCount'
]

{ #category : #queries }
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
