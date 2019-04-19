"
""I represent a query in GitHub's GraphQL API (REST). I depend on ZnClient.

-------""

""Get project list""
queryInstance := GMGitHubGraphQLQuery new token: 'GET_YOUR_OWN_TOKEN_FROM_GITHUB'.
searchQuery := 'language:java forks:>=500 sort:stars size:>=15000'.
projects := queryInstance getProjectDataForSearchQuery: searchQuery.

""Filter only projects with 95% Java""
strongJavaProjects := queryInstance strongJavaProjects: projects strength: 0.95.

""Check usage""
results := queryInstance doGraphQLQuery: 'query {  viewer {    login  }  rateLimit {    limit    cost    remaining    resetAt  }}'.

queryInstance writeProjects: strongJavaProjects toCSV: 'project_list_95pctJava.csv'.

strongJavaProjects first.
strongJavaProjects first values.

projectKeys := strongJavaProjects first keys.
projectValues := strongJavaProjects collect: [ :p | p values ].

""Forks and stargazers are sixth and seventh""
projectRank := [ :p | p sixth + p seventh ].

sortedProjectList := SortedCollection
         sortBlock: [ :p1 :p2 | (projectRank value: p2) <= (projectRank value: p1) ].

sortedProjectList addAll: projectValues.
sortedProjectList inspect.

queryInstance writeProjectsKeys: projectKeys values: sortedProjectList toCSV: 'ranked_Java_project_list.csv'.

""fourth is the project owner/name""
sortedProjectNames := (sortedProjectList collect: [:p | p fourth]) asArray.

""Print (^P) sortedProjectNames and copy/paste it into #hardCodedProjectList""

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
GMGitHubGraphQLQuery class >> hardCodedCrashingProjectList [
	"These are projects that crash when you try to parse them with JDT2Famix"
	^ #('google/guava' 'deeplearning4j/deeplearning4j' 'bazelbuild/bazel' 'prestodb/presto' 'dianping/cat' 'checkstyle/checkstyle' 'spring-projects/spring-security' 'firebase/FirebaseUI-Android' 'TommyLemon/Android-ZBLibrary' 'SonarSource/sonarqube' 'MinecraftForge/MinecraftForge' 'jiangqqlmj/FastDev4Android' 'Bukkit/Bukkit' 'geoserver/geoserver' 'shopizer-ecommerce/shopizer') asSet
]

{ #category : #queries }
GMGitHubGraphQLQuery class >> hardCodedExcludedProjectList [
	"These are projects that crash when you try to parse them with JDT2Famix"
	^ #('janishar/mit-deep-learning-book-pdf' "One java file, not a software project but a book.") asSet
]

{ #category : #queries }
GMGitHubGraphQLQuery class >> hardCodedProjectList [
	^ #('iluwatar/java-design-patterns' 'spring-projects/spring-boot' 'elastic/elasticsearch' 'spring-projects/spring-framework' 'ReactiveX/RxJava' 'apache/incubator-dubbo' 'kdn251/interviews' 'google/guava' 'PhilJay/MPAndroidChart' 'bumptech/glide' 'zxing/zxing' 'netty/netty' 'nostra13/Android-Universal-Image-Loader' 'alibaba/druid' 'scwang90/SmartRefreshLayout' 'CymChad/BaseRecyclerViewAdapterHelper' 'chrisbanes/PhotoView' 'mybatis/mybatis-3' 'google/ExoPlayer' 'jfeinstein10/SlidingMenu' 'hankcs/HanLP' 'signalapp/Signal-Android' 'macrozheng/mall' 'androidannotations/androidannotations' 'mikepenz/MaterialDrawer' 'prestodb/presto' 'CarGuo/GSYVideoPlayer' 'checkstyle/checkstyle' 'jeasonlzy/okhttp-OkGo' 'JakeWharton/ActionBarSherlock' 'vondear/RxTool' 'eclipse-vertx/vert.x' 'lipangit/JiaoZiVideoPlayer' 'dyc87112/SpringBoot-Learning' 'xuxueli/xxl-job' 'junit-team/junit4' 'dropwizard/dropwizard' 'mockito/mockito' 'YoKeyword/Fragmentation' 'aporter/coursera-android' 'Yalantis/uCrop' 'iBotPeaches/Apktool' 'lingochamp/FileDownloader' 'apache/incubator-druid' 'apache/incubator-shardingsphere' 'roughike/BottomBar' 'florent37/MaterialViewPager' 'MyCATApache/Mycat-Server' 'google/guice' 'Tencent/QMUI_Android' 'hongyangAndroid/okhttputils' 'apache/incubator-skywalking' 'Activiti/Activiti' 'stanfordnlp/CoreNLP' 'Netflix/SimianArmy' 'wyouflf/xUtils' 'hs-web/hsweb-framework' 'facebook/facebook-android-sdk' 'grpc/grpc-java' 'nhaarman/ListViewAnimations' 'naman14/Timber' 'apache/cassandra' 'java-decompiler/jd-gui' 'yixia/VitamioBundle' 'hackware1993/MagicIndicator' 'janishar/mit-deep-learning-book-pdf' 'NLPchina/ansj_seg' 'careercup/CtCI-6th-Edition' 'motianhuo/wechat' 'amlcurran/ShowcaseView' 'aa112901/remusic' 'alibaba/nacos' 'smuyyh/BookReader' 'Justson/AgentWeb' 'spring-projects/spring-security' 'Nightonke/BoomMenu' 'AsyncHttpClient/async-http-client' 'hibernate/hibernate-orm' 'chentao0707/SimplifyReader' 'gabrielemariotti/cardslib' 'processing/processing' 'apache/camel' 'DuGuQiuBai/Java' 'pardom-zz/ActiveAndroid' 'alibaba/jstorm' 'robolectric/robolectric' 'owncloud/android' 'jersey/jersey' 'openhab/openhab1-addons' 'DreaminginCodeZH/Douya' 'castorflex/SmoothProgressBar' 'apache/tomcat' 'bitcoinj/bitcoinj' 'HotBitmapGG/bilibili-android-client' 'aws/aws-sdk-java' 'Exrick/xmall' 'TommyLemon/Android-ZBLibrary' 'runelite/runelite' 'youlookwhat/CloudReader' 'looly/hutool' 'OpenTSDB/opentsdb' 'apache/hbase' 'gephi/gephi' 'nicolasgramlich/AndEngine' 'xcltapestry/XCL-Charts' 'MinecraftForge/MinecraftForge' 'pentaho/pentaho-kettle' 'siacs/Conversations' 'roncoo/roncoo-pay' 'apache/lucene-solr' 'hazelcast/hazelcast' 'psaravan/JamsMusicPlayer' 'wildfly/wildfly' 'survivingwithandroid/Surviving-with-android' 'knowm/XChange' 'brianfrankcooper/YCSB' 'qii/weiciyuan' 'eclipse/jetty.project' 'jiangqqlmj/FastDev4Android' 'ftctechnh/ftc_app' 'MovingBlocks/Terasology' 'kiegroup/drools' 'CrawlScript/WebCollector' 'guolindev/booksource' 'rovo89/XposedInstaller' 'cucumber/cucumber-jvm' 'openmrs/openmrs-core' 'openhab/openhab2-addons' 'bitcoin-wallet/bitcoin-wallet' 'Bukkit/Bukkit' 'apache/flume' 'apache/maven' 'liferay/liferay-plugins' 'spring-projects/spring-batch' 'apache/activemq' 'GoogleCloudPlatform/java-docs-samples' 'ysc/QuestionAnsweringSystem' 'aporter/coursera-android-labs' 'se-edu/addressbook-level4' 'essentials/Essentials' 'sphinx02/AppStarter')
]

{ #category : #queries }
GMGitHubGraphQLQuery class >> hardCodedVerveineJCrashingProjectList [
	"These are projects that crash when you try to parse them with JDT2Famix"
	^ #('apache/beam' 'aws/aws-sdk-java' 'apache/hive' 'apache/groovy') asSet
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
	Transcript
		show: 'About to batch queries for ''' , searchQuery , '''.';
		cr.
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
	Transcript
		show:
			'Query results say there are ' , projectCount asString
				, ' projects that match.';
		cr.
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
  "query": "query topRepos($query: String!) {\n  search(first: ', blockSize asString, ', query: $query, type: REPOSITORY) {\n    repositoryCount\n    pageInfo {\n      endCursor\n    }\n    nodes {\n      ... on Repository {\n        nameWithOwner \n        languages(first: 50, orderBy: {field: SIZE, direction: DESC}) {\n          totalSize\n          totalCount\n          edges {\n            size\n            node {\n              name\n            }\n          }\n        }\n        pullRequests (states:MERGED) {\n          totalCount\n        }\n        stargazers {\n          totalCount\t\n        }\n        forkCount\n        issues(states:CLOSED){ totalCount}\n      }\n    }\n  }\n}\n",
  "variables": {
    "query": "' , queryString , '"
  }
}'
]

{ #category : #queries }
GMGitHubGraphQLQuery >> makeFollowingBlockQuery: blockSize after: endCursorString queryString: queryString [ 
	^ '{
  "query": "query topRepos($query: String!) {\n  search(first: ', blockSize asString, ', after: \"' , endCursorString , '\", query: $query, type: REPOSITORY) {\n    repositoryCount\n    pageInfo {\n      endCursor\n    }\n    nodes {\n      ... on Repository {\n        nameWithOwner \n        languages(first: 50, orderBy: {field: SIZE, direction: DESC}) {\n          totalSize\n          totalCount\n          edges {\n            size\n            node {\n              name\n            }\n          }\n        }\n        pullRequests (states:MERGED) {\n          totalCount\n        }\n        stargazers {\n          totalCount\t\n        }\n        forkCount\n        issues(states:CLOSED){ totalCount}\n      }\n    }\n  }\n}\n",
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
		#stargazersCount->((p at: 'stargazers') at: 'totalCount') .
		#languagesTotalSize->((p at: 'languages') at: 'totalSize') .
		"The following relies on the fact that Java is the first language due to the search criteria being Java - perhaps not ideal"
		#languagesTotalJava->(((p at: 'languages') at: 'edges') first at: 'size' )		
	 } 
  ]) asOrderedCollection
]

{ #category : #queries }
GMGitHubGraphQLQuery >> strongJavaProjects: projects strength: threshold [
	"threshold is a number between 0 and 1 as to the ratio of Java code in the project"

	^ projects
		select: [ :p | 
			(p at: 'languagesTotalJava') asInteger
				/ (p at: 'languagesTotalSize') asInteger >= threshold ]
]

{ #category : #accessing }
GMGitHubGraphQLQuery >> token [
	^ token
]

{ #category : #accessing }
GMGitHubGraphQLQuery >> token: anObject [
	token := anObject
]

{ #category : #writing }
GMGitHubGraphQLQuery >> writeProjects: projects toCSV: csvFileName [
	"Save the crunched projects data to a CSV"

| projectKeys projectValues |
projectKeys := projects first keys.
projectValues := projects collect: [ :p | p values ].

FileStream
		forceNewFileNamed: csvFileName
		do: [ :csvStream | 
			(NeoCSVWriter on: csvStream)
				nextPut: projectKeys;
				nextPutAll: projectValues ].
]

{ #category : #writing }
GMGitHubGraphQLQuery >> writeProjectsKeys: projectKeys values: projectValues toCSV: csvFileName [
	"Save the crunched projects data to a CSV"

	FileStream
		forceNewFileNamed: csvFileName
		do: [ :csvStream | 
			(NeoCSVWriter on: csvStream)
				nextPut: projectKeys;
				nextPutAll: projectValues ]
]
