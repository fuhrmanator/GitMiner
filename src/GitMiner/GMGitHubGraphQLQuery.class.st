"
I represent a query in GitHub's GraphQL API (REST). I depend on ZnClient.

-------

""Get project list""
queryInstance := GMGitHubGraphQLQuery new token: 'GET_YOUR_OWN_TOKEN_FROM'.
searchQuery := 'language:java forks:>=500 sort:stars size:>=15000'.
projects := queryInstance getProjectDataForSearchQuery: searchQuery.

results := queryInstance doGraphQLQuery: 'query {  viewer {    login  }  rateLimit {    limit    cost    remaining    resetAt  }}'.

queryInstance writeProjects: projects toCSV: 'project_list.csv'.

projectKeys := projects first keys.
projectValues := projects collect: [ :p | p values ].

projectRank := [ :p | p fourth + p fifth ].

sortedProjectList := SortedCollection
         sortBlock: [ :p1 :p2 | (projectRank value: p2) <= (projectRank value: p1) ].

sortedProjectList addAll: projectValues.
sortedProjectList inspect.

queryInstance writeProjectsKeys: projectKeys values: sortedProjectList toCSV: 'ranked_project_list.csv'

sortedProjectNames := (sortedProjectList collect: [:p | p third]) asArray.
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
GMGitHubGraphQLQuery >> hardCodedProjectList [
	"list of projects as an Array, hard-coded from the output of a query that takes a long time to generate."
"Comment out guava because it crashes JDT2Famix"
"Comment out deeplearning4j because it crashes JDT2Famix"
"Comment out bazel because it crashes JDT2Famix"
"Comment out prestodb because it crashes JDT2Famix"
"Comment out dianping/cat because it crashes JDT2Famix" 
	^ #('iluwatar/java-design-patterns' 'spring-projects/spring-boot' 'elastic/elasticsearch' 'spring-projects/spring-framework' 'ReactiveX/RxJava' 'apache/incubator-dubbo' 'kdn251/interviews' 'square/okhttp' "'google/guava'" 'PhilJay/MPAndroidChart' 'eugenp/tutorials' 'bumptech/glide' 'Blankj/AndroidUtilCode' 'zxing/zxing' 'airbnb/lottie-android' 'netty/netty' 'proxyee-down-org/proxyee-down' 'square/leakcanary' 'nostra13/Android-Universal-Image-Loader' 'alibaba/druid' 'libgdx/libgdx' 'scwang90/SmartRefreshLayout' 'CymChad/BaseRecyclerViewAdapterHelper' 'shuzheng/zheng' 'facebook/fresco' 'chrisbanes/PhotoView' 'SeleniumHQ/selenium' 'apache/kafka' 'jenkinsci/jenkins' 'ctripcorp/apollo' 'jfeinstein10/SlidingMenu' 'google/ExoPlayer' 'mybatis/mybatis-3' 'DrKLO/Telegram' 'arduino/Arduino' "'deeplearning4j/deeplearning4j'" 'hankcs/HanLP' 'b3log/symphony' 'apache/hadoop' 'signalapp/Signal-Android' 'aosp-mirror/platform_frameworks_base' "'bazelbuild/bazel'" 'androidannotations/androidannotations' 'openzipkin/zipkin' 'macrozheng/mall' 'apache/flink' 'mikepenz/MaterialDrawer' 'react-native-community/lottie-react-native' 'realm/realm-java' "'prestodb/presto'" "'dianping/cat'" 'CarGuo/GSYVideoPlayer' "'checkstyle/checkstyle'" 'jeasonlzy/okhttp-OkGo' 'code4craft/webmagic' 'JakeWharton/ActionBarSherlock' 'vondear/RxTool' 'naver/pinpoint' 'eclipse-vertx/vert.x' 'nathanmarz/storm' 'lipangit/JiaoZiVideoPlayer' 'wasabeef/recyclerview-animators' 'alibaba/ARouter' 'Tencent/VasSonic' 'firebase/quickstart-android' 'xuxueli/xxl-job' 'junit-team/junit4' 'dropwizard/dropwizard' 'aporter/coursera-android' 'dyc87112/SpringBoot-Learning' 'mockito/mockito' 'YoKeyword/Fragmentation' 'AppIntro/AppIntro' 'Yalantis/uCrop' 'lingochamp/FileDownloader' 'iBotPeaches/Apktool' 'apache/zookeeper' 'roughike/BottomBar' 'apache/incubator-druid' 'apache/incubator-shardingsphere' 'apache/storm' 'florent37/MaterialViewPager' 'b3log/solo' 'MyCATApache/Mycat-Server' 'google/guice' 'rzwitserloot/lombok' 'hongyangAndroid/okhttputils' 'Tencent/QMUI_Android' 'wasabeef/glide-transformations' 'Activiti/Activiti' 'codecentric/spring-boot-admin' 'commonsguy/cw-omnibus' 'apache/incubator-skywalking' 'apereo/cas' 'alibaba/atlas' 'stanfordnlp/CoreNLP' 'Netflix/SimianArmy' 'daniulive/SmarterStreaming' 'adambard/learnxinyminutes-docs' 'wyouflf/xUtils' 'neo4j/neo4j' 'facebook/facebook-android-sdk' 'hs-web/hsweb-framework' 'nhaarman/ListViewAnimations' 'grpc/grpc-java' 'naman14/Timber' 'apache/cassandra' 'asLody/VirtualApp' 'OpenRefine/OpenRefine' 'yixia/VitamioBundle' 'qiurunze123/miaosha' 'NLPchina/ansj_seg' 'elasticjob/elastic-job-lite' 'hackware1993/MagicIndicator' 'janishar/mit-deep-learning-book-pdf' 'antlr/antlr4' 'careercup/CtCI-6th-Edition' 'motianhuo/wechat' 'amlcurran/ShowcaseView' 'aa112901/remusic' 'Qihoo360/RePlugin' 'smuyyh/BookReader' 'zaproxy/zaproxy' 'Nightonke/BoomMenu' 'alibaba/nacos' 'spring-projects/spring-security' 'k9mail/k-9' 'AsyncHttpClient/async-http-client' 'chentao0707/SimplifyReader' 'hibernate/hibernate-orm' 'linlinjava/litemall' 'apache/zeppelin' 'gabrielemariotti/cardslib' 'bigbluebutton/bigbluebutton' 'Alluxio/alluxio' 'processing/processing' 'thinkaurelius/titan' 'izzyleung/ZhihuDailyPurify' 'java-native-access/jna' 'apache/camel' 'pardom-zz/ActiveAndroid' 'alibaba/jstorm' 'DuGuQiuBai/Java' 'robolectric/robolectric' 'owncloud/android' 'jersey/jersey' 'sohutv/cachecloud' 'keycloak/keycloak' 'h2oai/h2o-3' 'wuhaoyu1990/MagicCamera' 'openhab/openhab1-addons' 'DreaminginCodeZH/Douya' 'castorflex/SmoothProgressBar' 'TechEmpower/FrameworkBenchmarks' 'mybatis/generator' 'purplecabbage/phonegap-plugins' 'apache/tomcat' 'HotBitmapGG/bilibili-android-client' 'bitcoinj/bitcoinj' 'Angel-ML/angel' 'aws/aws-sdk-java' 'spring-cloud/spring-cloud-netflix' 'apache/hive' 'firebase/FirebaseUI-Android' 'Exrick/xmall' 'youlookwhat/CloudReader' 'runelite/runelite' 'OpenTSDB/opentsdb' 'TommyLemon/Android-ZBLibrary' 'looly/hutool' 'springfox/springfox' 'apache/hbase' 'SonarSource/sonarqube' 'nicolasgramlich/AndEngine' 'gephi/gephi' 'xcltapestry/XCL-Charts' 'MinecraftForge/MinecraftForge' 'apache/beam' 'apache/groovy' 'siacs/Conversations' 'roncoo/roncoo-pay' 'pentaho/pentaho-kettle' 'apache/lucene-solr' 'hazelcast/hazelcast' 'psaravan/JamsMusicPlayer' 'wildfly/wildfly' 'survivingwithandroid/Surviving-with-android' 'knowm/XChange' 'qii/weiciyuan' 'apache/cordova-android' 'brianfrankcooper/YCSB' 'Wizcorp/phonegap-facebook-plugin' 'eclipse/jetty.project' 'jiangqqlmj/FastDev4Android' 'ftctechnh/ftc_app' 'MovingBlocks/Terasology' 'liferay/liferay-portal' 'vert-x3/vertx-examples' 'apache/shiro' 'CrawlScript/WebCollector' 'kiegroup/drools' 'rovo89/XposedInstaller' 'apache/ignite' 'guolindev/booksource' 'katzer/cordova-plugin-local-notifications' 'cucumber/cucumber-jvm' 'azkaban/azkaban' 'mongodb/mongo-java-driver' 'NLPIR-team/NLPIR' 'phonegap/phonegap-plugin-push' 'openmrs/openmrs-core' 'wordpress-mobile/WordPress-Android' 'apache/nutch' 'openhab/openhab2-addons' 'bitcoin-wallet/bitcoin-wallet' 'Bukkit/Bukkit' 'deeplearning4j/dl4j-examples' 'igniterealtime/Openfire' 'xubinux/xbin-store' 'apache/flume' 'liquibase/liquibase' 'xuhuisheng/lemon' 'apache/maven' 'liferay/liferay-plugins' 'geoserver/geoserver' 'TEAMMATES/teammates' 'apache/nifi' 'baichengzhou/SpringMVC-Mybatis-Shiro-redis-0.2' 'apache/activemq' 'spring-projects/spring-batch' 'GoogleCloudPlatform/java-docs-samples' 'shopizer-ecommerce/shopizer' 'ysc/QuestionAnsweringSystem' 'apache/ambari' 'xamarin/recipes' 'aporter/coursera-android-labs' 'jboss-developer/jboss-eap-quickstarts' 'CyanogenMod/android_frameworks_base' 'mit-cml/appinventor-sources' 'wildfly/quickstart' 'se-edu/addressbook-level4' 'essentials/Essentials' 'sphinx02/AppStarter' 'rakeshcusat/Code4Reference' 'abstrakraft/android_build')
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
