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

	^ #('elastic/elasticsearch' 'spring-projects/spring-boot' 'spring-projects/spring-framework' 'iluwatar/java-design-patterns' 'ReactiveX/RxJava' 'apache/incubator-dubbo' 'square/okhttp' 'kdn251/interviews' "'google/guava'" 'PhilJay/MPAndroidChart' 'eugenp/tutorials' 'bumptech/glide' 'netty/netty' 'zxing/zxing' 'Blankj/AndroidUtilCode' 'airbnb/lottie-android' 'proxyee-down-org/proxyee-down' 'square/leakcanary' 'libgdx/libgdx' 'SeleniumHQ/selenium' 'nostra13/Android-Universal-Image-Loader' 'alibaba/druid' 'CymChad/BaseRecyclerViewAdapterHelper' 'arduino/Arduino' 'deeplearning4j/deeplearning4j' 'google/ExoPlayer' 'facebook/fresco' 'scwang90/SmartRefreshLayout' 'signalapp/Signal-Android' 'jenkinsci/jenkins' 'prestodb/presto' 'shuzheng/zheng' 'apache/kafka' 'chrisbanes/PhotoView' 'ctripcorp/apollo' 'neo4j/neo4j' 'eclipse/che' 'bazelbuild/bazel' 'mybatis/mybatis-3' 'realm/realm-java' 'hazelcast/hazelcast' 'jfeinstein10/SlidingMenu' 'DrKLO/Telegram' 'naver/pinpoint' 'b3log/symphony' 'hankcs/HanLP' 'androidannotations/androidannotations' 'checkstyle/checkstyle' 'apache/incubator-druid' 'mikepenz/MaterialDrawer' 'openzipkin/zipkin' 'apache/hadoop' 'aosp-mirror/platform_frameworks_base' 'dbeaver/dbeaver' 'Alluxio/alluxio' 'CarGuo/GSYVideoPlayer' 'dianping/cat' 'apache/flink' 'eclipse-vertx/vert.x' 'lipangit/JiaoZiVideoPlayer' 'dropwizard/dropwizard' 'react-native-community/lottie-react-native' 'bigbluebutton/bigbluebutton' 'macrozheng/mall' 'JakeWharton/ActionBarSherlock' 'grpc/grpc-java' 'orientechnologies/orientdb' 'apereo/cas' 'wordpress-mobile/WordPress-Android' 'apache/storm' 'code4craft/webmagic' 'jeasonlzy/okhttp-OkGo' 'iBotPeaches/Apktool' 'spring-projects/spring-security' 'apache/incubator-shardingsphere' 'nathanmarz/storm' 'alibaba/ARouter' 'mockito/mockito' 'junit-team/junit4' 'firebase/quickstart-android' 'TEAMMATES/teammates' 'xuxueli/xxl-job' 'processing/processing' 'adambard/learnxinyminutes-docs' 'vondear/RxTool' 'YoKeyword/Fragmentation' 'Tencent/VasSonic' 'lingochamp/FileDownloader' 'zaproxy/zaproxy' 'wasabeef/recyclerview-animators' 'apache/incubator-skywalking' 'Activiti/Activiti' 'Konloch/bytecode-viewer' 'keycloak/keycloak' 'MyCATApache/Mycat-Server' 'AppIntro/AppIntro' 'jOOQ/jOOQ' 'runelite/runelite' 'gocd/gocd' 'openhab/openhab1-addons' 'rzwitserloot/lombok' 'Graylog2/graylog2-server' 'Yalantis/uCrop' 'b3log/solo' 'roughike/BottomBar' 'vaadin/framework' 'aporter/coursera-android' 'wildfly/wildfly' 'dyc87112/SpringBoot-Learning' 'google/guice' 'pentaho/pentaho-kettle' 'apache/zookeeper' 'codecentric/spring-boot-admin' 'florent37/MaterialViewPager' 'oracle/graal' 'Tencent/QMUI_Android' 'robolectric/robolectric' 'TechEmpower/FrameworkBenchmarks' 'k9mail/k-9' 'hongyangAndroid/okhttputils' 'wasabeef/glide-transformations' 'stanfordnlp/CoreNLP' 'OpenRefine/OpenRefine' 'antlr/antlr4' 'commonsguy/cw-omnibus' 'jersey/jersey' 'apache/beam' 'alibaba/atlas' 'Netflix/SimianArmy' 'facebook/buck' 'h2oai/h2o-3' 'MinecraftForge/MinecraftForge' 'daniulive/SmarterStreaming' 'mulesoft/mule' 'wyouflf/xUtils' 'facebook/facebook-android-sdk' 'spring-cloud/spring-cloud-netflix' 'TeamNewPipe/NewPipe' 'android-hacker/VirtualXposed' 'osmandapp/Osmand' 'nhaarman/ListViewAnimations' 'AsyncHttpClient/async-http-client' 'hs-web/hsweb-framework' 'naman14/Timber' 'NLPchina/ansj_seg' 'google/closure-compiler' 'google/physical-web' 'eclipse/smarthome' 'asLody/VirtualApp' 'owncloud/android' 'openhab/openhab2-addons' 'go-lang-plugin-org/go-lang-idea-plugin' 'elasticjob/elastic-job-lite' 'apache/cassandra' 'Qihoo360/RePlugin' 'yixia/VitamioBundle' 'apache/pulsar' 'ankidroid/Anki-Android' 'sakaiproject/sakai' 'google/j2objc' 'amlcurran/ShowcaseView' 'siacs/Conversations' 'alibaba/nacos' 'qiurunze123/miaosha' 'thinkaurelius/titan' 'hackware1993/MagicIndicator' 'springfox/springfox' 'careercup/CtCI-6th-Edition' 'topjohnwu/Magisk' 'gyf-dev/ImmersionBar' 'janishar/mit-deep-learning-book-pdf' 'motianhuo/wechat' 'Justson/AgentWeb' 'k0shk0sh/FastHub' 'java-native-access/jna' 'SonarSource/sonarqube' 'hibernate/hibernate-orm' 'aa112901/remusic' 'smuyyh/BookReader' 'aws/aws-sdk-java' 'rstudio/rstudio' 'MovingBlocks/Terasology' 'apache/camel' 'knowm/XChange' 'kickstarter/android-oss' 'eclipse/jetty.project' 'apache/incubator-heron' 'Nightonke/BoomMenu' 'JabRef/jabref' 'gabrielemariotti/cardslib' 'davemorrissey/subsampling-scale-image-view' 'google/android-classyshark' 'alibaba/freeline' 'linlinjava/litemall' 'Atmosphere/atmosphere' 'chentao0707/SimplifyReader' 'sockeqwe/mosby' 'facebook/rebound' 'firebase/FirebaseUI-Android' 'apache/zeppelin' 'alibaba/jstorm' 'gephi/gephi' 'TommyLemon/APIJSON' 'bitcoinj/bitcoinj' 'pardom-zz/ActiveAndroid' 'claritylab/lucida' 'izzyleung/ZhihuDailyPurify' 'googleapis/google-cloud-java' 'ArthurHub/Android-Image-Cropper' 'guardianproject/haven' 'DuGuQiuBai/Java' 'bisq-network/bisq' 'mybatis/generator' 'Angel-ML/angel' 'phonegap/phonegap-plugin-push' 'geoserver/geoserver' 'pili-engineering/PLDroidPlayer' 'AntennaPod/AntennaPod' 'sohutv/cachecloud' 'huanghaibin-dev/CalendarView' 'haifengl/smile' 'wuhaoyu1990/MagicCamera' 'DreaminginCodeZH/Douya' 'castorflex/SmoothProgressBar' 'jfoenixadmin/JFoenix' 'OpenTSDB/opentsdb' 'Ramotion/folding-cell-android' 'yarolegovich/DiscreteScrollView' 'HotBitmapGG/bilibili-android-client' 'purplecabbage/phonegap-plugins' 'kiegroup/drools' 'apache/tomcat' 'junit-team/junit5' 'diogobernardino/WilliamChart' 'pentaho/pentaho-platform' 'katzer/cordova-plugin-local-notifications' 'yanzhenjie/SwipeRecyclerView' 'roboguice/roboguice' 'brianfrankcooper/YCSB' 'azkaban/azkaban' 'cucumber/cucumber-jvm' 'apache/hive' 'looly/hutool' 'deeplearning4j/nd4j' 'youlookwhat/CloudReader' 'Exrick/xmall' 'tomakehurst/wiremock' 'actorapp/actor-platform' 'nextcloud/android' 'apache/ambari' 'PipelineAI/pipeline' 'querydsl/querydsl' 'TommyLemon/Android-ZBLibrary' 'yanzhenjie/NoHttp' 'jeasonlzy/ImagePicker' 'M66B/XPrivacy' 'javaparser/javaparser' 'nicolasgramlich/AndEngine' 'rubensousa/RecyclerViewSnap' 'Wizcorp/phonegap-facebook-plugin' 'FasterXML/jackson-databind' 'ximsfei/Android-skin-support' 'TeamAmaze/AmazeFileManager' 'apache/hbase' 'amirzaidi/Launcher3' 'apache/groovy' 'Tencent/GT' 'baoyachi/StepView' 'tronprotocol/java-tron' 'openmrs/openmrs-core' 'Rajawali/Rajawali' 'xcltapestry/XCL-Charts' 'nutzam/nutz' 'fossasia/phimpme-android' 'fossasia/open-event-droidgen' 'pmd/pmd' 'lcodecorex/TwinklingRefreshLayout' 'codeestX/GeekNews' 'apache/lucene-solr' 'apache/geode' 'roncoo/roncoo-pay' 'languagetool-org/languagetool' 'apache/cordova-android' 'xcc3641/SeeWeather' 'oblac/jodd' 'OpenAPITools/openapi-generator' 'qii/weiciyuan' 'psaravan/JamsMusicPlayer' 'survivingwithandroid/Surviving-with-android' 'bingoogolapple/BGABanner-Android' 'Jacksgong/JKeyboardPanelSwitch' 'pengjianbo/GalleryFinal' 'danikula/AndroidVideoCache' 'BroadleafCommerce/BroadleafCommerce' 'igniterealtime/Openfire' 'stephanenicolas/robospice' 'apache/incubator-gobblin' 'Screetsec/TheFatRat' 'vert-x3/vertx-examples' 'graphhopper/graphhopper' 'JanusGraph/janusgraph' 'Meituan-Dianping/Robust' 'ethereum/ethereumj' 'ftctechnh/ftc_app' 'h2database/h2database' 'andremion/Music-Player' 'nitaliano/react-native-mapbox-gl' 'dropbox/hackpad' 'apache/jmeter' 'jiangqqlmj/FastDev4Android' 'rovo89/XposedInstaller' 'Jasonchenlijian/FastBle' 'opentripplanner/OpenTripPlanner' 'apache/ignite' 'ManuelPeinado/FadingActionBar' 'CrawlScript/WebCollector' 'cSploit/android' 'liferay/liferay-portal' 'apache/shiro' 'Prototik/HoloEverywhere' 'yahoo/anthelion' 'pedrovgs/DraggablePanel' 'opendatakit/collect' 'guolindev/booksource' 'cbeust/testng' 'quartz-scheduler/quartz' 'GitLqr/LQRWeChat' 'jMonkeyEngine/jmonkeyengine' 'deeplearning4j/dl4j-examples' 'btraceio/btrace' 'code-troopers/android-betterpickers' 'mongodb/mongo-java-driver' 'flowable/flowable-engine' 'jboss-developer/jboss-eap-quickstarts' 'GoogleCloudPlatform/java-docs-samples' 'crossoverJie/cim' 'zwwill/yanxuan-weex-demo' 'osmdroid/osmdroid' 'danylovolokh/VideoPlayerManager' 'ltsopensource/light-task-scheduler' 'undertow-io/undertow' 'fossasia/susi_server' 'geotools/geotools' 'Tencent/MSEC' 'spring-io/sagan' 'bitcoin-wallet/bitcoin-wallet' 'liquibase/liquibase' 'north2016/T-MVP' 'Nightonke/CoCoin' 'apache/nutch' 'apache/kylin' 'guoguibing/librec' 'NLPIR-team/NLPIR' 'w446108264/XhsEmoticonsKeyboard' 'apache/cloudstack' 'spring-cloud/spring-cloud-config' 'saulmm/CoordinatorBehaviorExample' 'iSoron/uhabits' 'resteasy/Resteasy' 'commons-app/apps-android-commons' 'WritingMinds/ffmpeg-android-java' 'spring-projects/spring-session' 'Red5/red5-server' 'schwabe/ics-openvpn' 'gitblit/gitblit' 'jamesdbloom/mockserver' 'evollu/react-native-fcm' 'voldemort/voldemort' 'xinghongfei/LookLook' 'JackyAndroid/AndroidChromium' 'redsolution/xabber-android' 'jdsjlzx/LRecyclerView' 'javamelody/javamelody' 'federicoiosue/Omni-Notes' 'harjot-oberai/MusicDNA' 'Bukkit/Bukkit' 'kabouzeid/Phonograph' 'linkedin/databus' 'JpressProjects/jpress' 'qiujuer/Genius-Android' 'LuckyJayce/ViewPagerIndicator' 'gotev/android-upload-service' 'Frank-Zhu/PullZoomView' 'rmtheis/android-ocr' 'h2oai/h2o-2' 'JackyAndroid/AndroidTVLauncher' 'unclebob/fitnesse' 'DSpace/DSpace' 'Diolor/Swipecards' 'xuhuisheng/lemon' 'liuyubobobo/Play-with-Algorithms' 'xmuSistone/CardSlidePanel' 'xubinux/xbin-store' 'jitsi/jitsi' 'kymjs/KJFrameForAndroid' 'sarxos/webcam-capture' 'ninjaframework/ninja' 'lendylongli/qianghongbao' 'kiegroup/jbpm' 'cymcsg/UltimateAndroid' 'apache/flume' 'brianway/springmvc-mybatis-learning' 'igniterealtime/Smack' 'apache/maven' 'androidquery/androidquery' 'apache/nifi' 'liferay/liferay-plugins' 'Naoki2015/CircleDemo' 'mit-cml/appinventor-sources' 'novoda/android-demos' 'stylefeng/Guns' 'datastax/java-driver' 'android-cjj/Android-MaterialRefreshLayout' 'mitreid-connect/OpenID-Connect-Java-Spring-Server' 'geometer/FBReaderJ' 'apache/mahout' 'apache/commons-lang' 'codingXiaxw/seckill' 'spring-projects/spring-batch' 'spring-projects/spring-data-elasticsearch' 'spring-projects/spring-integration' 'se-edu/addressbook-level4' 'shopizer-ecommerce/shopizer' 'JetBrains/intellij-plugins' 'qos-ch/logback' 'apache/activemq' 'marytts/marytts' 'wangdan/AisenWeiBo' 'tuguangquan/mybatis' 'baichengzhou/SpringMVC-Mybatis-Shiro-redis-0.2' 'avjinder/Minimal-Todo' 'react-native-community/react-native-google-signin' 'ysc/QuestionAnsweringSystem' 'plutext/docx4j' 'cloudfoundry/uaa' 'kanwangzjm/funiture' 'unofficial-openjdk/openjdk' 'zhangdaiscott/jeecg' 'todoroo/astrid' 'guardianproject/ChatSecureAndroid' 'jamesagnew/hapi-fhir' 'hacktoberfest17/programming' 'pentaho/mondrian' 'qdrzwd/VideoRecorder' 'kiegroup/optaplanner' 'xamarin/recipes' 'wildfly/quickstart' 'aosp-mirror/platform_frameworks_support' 'apache/drill' 'mongodb/mongo-hadoop' 'playgameservices/android-basic-samples' 'alibaba/mdrill' 'openMF/mifosx' 'boylegu/SpringBoot-vue' 'aporter/coursera-android-labs' 'essentials/Essentials' 'project-travel-mate/Travel-Mate' 'apache/calcite' 'aimacode/aima-java' 'CyanogenMod/android_frameworks_base' 'MassiveCraft/Factions' 'lguipeng/Notes' 'Esri/arcgis-runtime-samples-android' 'apache/struts' 'floodlight/floodlight' 'ysc/word' 'android-cn/android-open-project-demo' 'spring-projects/spring-data-mongodb' 'a466350665/smart' 'EhsanTang/ApiManager' 'jhipster/jhipster-sample-app' 'apache/cxf' 'intel-hadoop/HiBench' 'bcgit/bc-java' 'GoogleCloudPlatform/community' 'IanDarwin/Android-Cookbook-Examples' 'menacher/java-game-server' 'sphinx02/AppStarter' 'alibaba/taokeeper' 'google/google-api-java-client-samples' 'ZHENFENG13/ssm-demo' 'QuickBlox/quickblox-android-sdk' 'apache/parquet-mr' 'z56402344/BaseAnimation' 'rakeshcusat/Code4Reference' 'good-life/PushTalk' 'camunda/camunda-bpm-platform' 'dannytiehui/androidpn' 'sanluan/PublicCMS' 'jfrog/project-examples' 'xuyisheng/AndroidHeroes' 'mobileresearch/weibo_android_sdk' 'xujeff/tianti' 'spring-projects/spring-data-neo4j' 'abstrakraft/android_build' 'mercyblitz/segmentfault-lessons' 'mahmoudparsian/data-algorithms-book' 'pubnub/java' 'aws-samples/aws-big-data-blog' 'apache/phoenix' 'aliyun/aliyun-openapi-java-sdk' 'Baeldung/spring-security-registration' 'onlyliuxin/coding2017' 'mrdear/JavaWEB' 'apache/ofbiz' 'opennetworkinglab/onos' 'vogellacompany/codeexamples-android' 'apache/tomee' 'winghc/hadoop2x-eclipse-plugin' 'liferay/liferay-docs' 'mtedone/podam' 'zc-zh-001/ShadowSocks-Share' 'aosp-mirror/platform_packages_apps_settings' 'in28minutes/spring-microservices' 'rybalkinsd/atom' 'CyanogenMod/android_packages_apps_Trebuchet' 'uthcode/learntosolveit' 'CyanogenMod/android_packages_apps_Settings' 'ekoontz/hadoop-common' 'jenkinsci/email-ext-plugin' 'zsol/android_frameworks_base' 'mdodsworth/lucene-solr' 'LineageOS/android_frameworks_base' 'daproy/android_packages_apps_Settings')
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
