"
""Class with homeless methods... To be refactored into an API.""
--------------
| urls |

urls := #(
'https://github.com/iluwatar/java-design-patterns'
'https://github.com/elastic/elasticsearch'
'https://github.com/ReactiveX/RxJava'
'https://github.com/spring-projects/spring-boot'
'https://github.com/square/retrofit'
'https://github.com/square/okhttp'
'https://github.com/google/guava'
'https://github.com/spring-projects/spring-framework'
'https://github.com/PhilJay/MPAndroidChart'
).
urls do: [ :url | GMUtility mineClientChangesNoARules: (url splitOn: '/') last url: url ] displayingProgress: [:url | 'Mining project: ', url ]. 
--------------

GMUtility mineClientChanges: 'cassandra' url: 'https://github.com/apache/cassandra' from: '3dcde0821a40eb2bc633082916d8f3ff861efdb5' to: '50560aaf0f2d395271ade59ba9b900a84cae70f1'.
GMUtility mineClientChanges: 'rhino' url: 'https://github.com/mozilla/rhino' from: 'HEAD' to: 'c34013ac67907ad2e1958d413bdea28d1ff707d5'.

-------------
HandMorph doubleClickTime: 500.

Utility cloneReposAndGenerateCommitMetadata: '_projects.csv'.

Utility generateSelectedCommitFiles: '*_commits.csv'.

Utility generateLogicalCouplingCandidatePairsAndTransactions: '_commits_UIDs.csv'.

Utility generateClientImplementationPairsFiles: 'ClientImpPairs'.

Utility applyRenamingsToTransactions: '_projects.csv'.

Utility removeUnrelatedClassesFromTransactions: 'alexo-chess'.

""R generates the coupling pairs ""
Utility generateLogicalCouplingPairsWithR: 'c:/chgevo'.

""Utility generateMSEFilesForEachUID: '_commits_UIDs.csv'.""

Utility calculateCouplingIntersections.
""---------------- Single project pipeline ""
gitName := 'rhino'.
olderTag :='Rhino1_7_8_Release'.
newerTag := 'Rhino1_7_9_Release'.
loc := Utility cloneRepo: 'https://github.com/mozilla/rhino'.

gitName := 'cassandra'.
""olderTag :='cassandra-2.0.0-beta1'.""
olderTag :='cassandra-3.11.2'.
newerTag := 'cassandra-3.11.3'.
loc := Utility cloneRepo: 'https://github.com/apache/cassandra'.
startOIDString := '3dcde0821a40eb2bc633082916d8f3ff861efdb5'.
endOIDString := '50560aaf0f2d395271ade59ba9b900a84cae70f1'.
commitMetadata := Utility filterCommitsOnRepoLeftBranchOnly: loc from: startOIDString to: endOIDString.

""Utility filterCommitsOnRepo: loc withRange: ''.""

selectedCommits := Utility generateSelectedCommits: commitMetadata.
pairsAndTransactions := Utility generatePairsAndTransactions: selectedCommits.

""oid := Utility getOIDFromTag: newerTag on: loc.""
mseFileRef := Utility generateMSEFileFor: startOIDString reponame: loc basename.
""mseFileRef := Utility generateMSEFileFor: 'HEAD' reponame: loc basename.""

cimpFile := Utility generateClientImplementationPairs: mseFileRef.

""Renamings should do a check-out of the Revision to use renamings from that point? Otherwise, integrate the revision info into the git-log command.""
renamedTransactionsFile := Utility applyRenamingsToTransactions: pairsAndTransactions second usingRevision: startOIDString project: gitName.

removedTr := Utility removeUnrelatedClassesFromTransactions: gitName fromRevision: startOIDString.
Utility generateLogicalCouplingPairsWithRSingleFile: removedTr.
""Utility generateLogicalCouplingPairsWithRSingleFile: pairsAndTransactions second.""

Utility calculateCouplingIntersectionsFor: gitName at: startOIDString.

""-----------------------------------""

repoHandle := LGitRepository on: loc.
repoHandle open.
gitRef := LGitReference of: repoHandle.
result := gitRef reference_lookup: nil repo: repoHandle name: 'refs/tags/',newerTag.
result = 0 ifTrue:[^gitRef targetId].
gitRef targetId .

""mseDirRoot := FileLocator C / 'tmp' / 'data_mining'.
mseDirs := mseDirRoot directories.
dir := mseDirs first.
projectName := dir basename asString allButLast: '_master' size.
mseFiles := dir allChildrenMatching: '*.mse'.
mseFile := mseFiles first.
results := InterfaceMiner mineClientImplementationPairs: mseFile readStream withPrefix: ''.
newFileName := projectName , '_', mseFile basenameWithoutExtension , '_' , 'ClientImpPairs' , '.csv'.

mseFile := (FileStream readOnlyFileNamed: 'C:\tmp\data_mining\alexo-chess_master\HEAD.mse').
InterfaceMiner mineClientImplementationPairs: mseFile withPrefix: ''.""



""Only needed once...""
Utility extractIndividualProjectLogicalCouplingData: 'G:\My Drive\Congé sabbatique 2018-2019\Activités INRIA\Change Evolution Interface Clients\AC2017 JSS\logicalcoupling.csv'.


OSEnvironment current setEnv: 'BLAH' value: 'x'.
OSEnvironment current getEnv: 'BLAH'.
LibC uniqueInstance system: 'env | more'.

"
Class {
	#name : #GMUtility,
	#superclass : #Object,
	#classInstVars : [
		'cloneRoot'
	],
	#category : #GitMiner
}

{ #category : #'as yet unclassified' }
GMUtility class >> abortWithErrorMessageFromFileReference: fileRef title: title [
	"Show abort dialog and the message from the R output"

	| displayText |
	displayText := fileRef readStreamEncoded: 'cp-1250' do: [ :stream |
        stream upToEnd ].
	"UIManager default abort: displayText title: title."
	AssertionFailure signal: title , ': ' , displayText withTag: #GitMinerException.
	"self error: displayText"
	
]

{ #category : #'as yet unclassified' }
GMUtility class >> annotateCommitsOnRepoLeftBranchOnly: location from: startOIDString to: endOIDString [
	"For all commits in a range specified by Git tags, add metadata according to what is important in the mining"

	| repoHandle commitDataList nCommits relativeRevNumber projectName outFile commit parentCommit startCommit endCommit startCommitShortOID endCommitShortOID |
	projectName := location path basename.
	repoHandle := LGitRepository on: location.
	repoHandle open.
	commitDataList := LinkedList new.

	startCommit := repoHandle revparse: startOIDString.
	"Make a shortened OID (7 chars)"
	startCommitShortOID := self shortOID: startCommit name.

	endOIDString isEmpty ifTrue: [ 
		"Find commit with no parent"
		endCommit := nil.
		endCommitShortOID := 'END'.
	] ifFalse: [ 
		endCommit := repoHandle revparse: endOIDString. 
		"Make a shortened OID (7 chars)"
		endCommitShortOID := self shortOID: endCommit name.
	].

	"Walk through to count commits for progress bar"
	nCommits := 0.
	commit := startCommit.
	[ (commit hasParents) & (commit ~= endCommit) ]
		whileTrue: [ nCommits := nCommits + 1.
			commit := commit parents first ].
	"nCommits > 2000
		ifTrue: [ (UIManager
				confirm:
					'This range has ' , nCommits asString
						, ' commits. Are you sure you want to mine it?')
				ifFalse: [ UIManager default abort: 'User aborted.' title: 'Mining stopped.'.
					self error: 'need to terminate Mining pipeline.'
					 ] ]."
			
	"Get commit ids that have:
  - no added files (only changed files)
  - 10 or fewer files
  - at least one .java file."
	relativeRevNumber := 0.
	commit := startCommit.
	parentCommit := startCommit parents first.
	[ :job | 
	[ (parentCommit hasParents) & (parentCommit ~= endCommit) ]
		whileTrue: [ | addedFiles difference atLeastOneJavaFile diffFiles |
			relativeRevNumber := relativeRevNumber + 1.
			difference := parentCommit tree diffTo: commit tree.
			"diffFiles := difference files." "This sometimes returns an empty set despite numberOfDeltas > 0"
			diffFiles := (1 to: difference numberOfDeltas) collect: [ :i | (difference deltaAt: i) oldFile path ].
			self assert: diffFiles size equals: difference numberOfDeltas.
			job
				progress: relativeRevNumber / nCommits;
				title:
					'Analyzing revision ' , (commit name truncateTo: 8) , ': '''
						, (commit message truncateTo: 25) , ''' ('
						, difference numberOfDeltas asString , ' files, isMerge=='
						, commit isMerge asString , ') ' , relativeRevNumber asString
						, '/' , nCommits asString.
			addedFiles := Set new.
			diffFiles
				do:
					[ :file | commit tree entryByPath: file ifAbsent: [ addedFiles add: file ] ].
			atLeastOneJavaFile := diffFiles
				anySatisfy: [ :file | file endsWith: '.java' ]. 
			commitDataList
				add:
					{commit name.
					(nCommits - relativeRevNumber + 1).	"Revwalk goes from latest to earliest"
					(Character space join: addedFiles).
					difference numberOfDeltas.
					atLeastOneJavaFile.
					(Character space join: diffFiles)}.
			commit := parentCommit.
			parentCommit := commit parents first ] ] asJob run.
	outFile := projectName , '_' , startCommitShortOID , '-'
		, endCommitShortOID, '_WithMiningMetadata.csv'.
	self writeCommitResults: commitDataList to: outFile.
	^ outFile
]

{ #category : #'file service' }
GMUtility class >> applyRenamingsToTransactions: projectsFile [
	"comment stating purpose of message"

	| working projectRecords projectName tempRepoRoot transactionsExtension newTransactionExtension clientImplementationPairsExtension file csvInputStream clientImplementationPairsRecords classesToCheckRenamings perlErrors renameHistoryCSV clientsTemp implementationsTemp perlProgram |
	tempRepoRoot := 'tmp/tempClonesPharo/'.	
	transactionsExtension := '_commits_UIDs_transactions.csv'.
	newTransactionExtension := '_commits_UIDs_transactions_renamed.csv'.
	clientImplementationPairsExtension := '_HEAD_ClientImpPairs.csv'.
	renameHistoryCSV := 'tmp/_renamings_temp.csv'.	
	perlProgram := 'tmp/hist2renamecsv.perl'.	
	perlErrors := 'tmp/_perl_errors'.	
	self ensureTmpDirectoryCreation.	
	working := FileSystem disk workingDirectory.
	csvInputStream := (working / projectsFile) readStream.
	projectRecords := self loadProjectsList: csvInputStream.	"ID	Project	Str.Dep.	Log.Dep.	Int.Set	CSD(%)	CLD(%)	GC_url	GitHub_url"	"GitHub url"
	projectRecords
		do: [ :projectRecord | 
			| githubUrl cTransactionsOriginal renamedCTransactions cTransactions |
			githubUrl := projectRecord last.
			githubUrl = 'NA'
				ifFalse: [ projectName := projectRecord second.
					file := (projectName , transactionsExtension) asFileReference.
					cTransactionsOriginal := self loadCommitTransactions: file.
					cTransactions := cTransactionsOriginal copy.
					"Load clients and implementations"
					"Read in CSV of structural coupling (client-implementation)"
					file := (projectName , clientImplementationPairsExtension) asFileReference.
					clientImplementationPairsRecords := self loadClientImplementationPairs: file.
					clientImplementationPairsRecords isNotEmpty 
						ifTrue: [ "Client file name is second column"
							clientsTemp := (clientImplementationPairsRecords collect: #second) asSet.
							"Implementation file name is fifth column"
							implementationsTemp := (clientImplementationPairsRecords collect: #fifth) asSet.
							classesToCheckRenamings := clientsTemp union: implementationsTemp.
							classesToCheckRenamings
								do: [ :class | 
									| projectRepoDir command result renamings dirs csvPath |
									"Generate git history"
									projectRepoDir := tempRepoRoot , projectName.
									command := 'cd ' , projectRepoDir , ' && git log --follow -p -- "' , class , '" | perl -0777 -n ' , perlProgram , ' > ' , renameHistoryCSV , ' 2>' , perlErrors.
									result := LibC uniqueInstance system: command.
									result = 0
										ifFalse: [ 0 halt ]
										ifTrue: [ "Load CSV of renamed names"
													dirs := renameHistoryCSV splitOn: $/.
													csvPath := FileLocator C.
													dirs
														do: [ :dir | 
															dir = ''
																ifFalse: [ csvPath := csvPath / dir ] ].
													renamings := self loadRenamings: csvPath.

													"For each transaction, replace any instance of a 'from' renaming with the current name"
													renamedCTransactions := OrderedCollection new.
													cTransactions
														do: [ :cTransaction | 
															| copyCTransaction i |
															"make copy of transaction record and add it to the new set"
															copyCTransaction := cTransaction copy.
															renamedCTransactions add: copyCTransaction .
															i := 0.
															cTransaction committedFileNames
																do: [ :classToMaybeRename | 
																	i := i + 1.
																	renamings
																				do: [ :renamingRecord | 
																					| fromRename percent |
																					percent := renamingRecord second.
																					fromRename := renamingRecord fourth.
																					copyCTransaction renameAll: fromRename to: class ] ]  .
													"Update for next class to check for renamings"
													cTransactions := renamedCTransactions ] ] ] ]

					"Check for case of no clients/implementations (no interfaces), just use original records (nothing to rename)"
					ifFalse: [ renamedCTransactions  := cTransactionsOriginal  copy ].

					self writeCommitTransactions: renamedCTransactions to: projectName , newTransactionExtension ] ]
		displayingProgress: [ :projectRecord | 'Applying renamings to project: ' , projectRecord second ]
]

{ #category : #'file service' }
GMUtility class >> applyRenamingsToTransactions: transactionsFile usingRevision: oid project: projectName [
	"For the commit transactions in a project, try to rename classes using the latest name.
	This works by taking the names at a specified revision (from MSE).
	Check out the git repo to that revision, then do a git history to get renamings."

	| cTransactionsOriginal renamedCTransactions cTransactions tempRepoRoot newTransactionExtension clientImplementationPairsExtension file clientImplementationPairsRecords classesToCheckRenamings perlErrors renameHistoryCSV clientsTemp implementationsTemp perlSubcommand |
	tempRepoRoot := 'tmp/tempClonesPharo/'.
	newTransactionExtension := '_commits_tags_OIDs_TR_renamed.csv'.
	clientImplementationPairsExtension := '_' , oid, '_ClientImpPairs.csv'.
	renameHistoryCSV := 'tmp/_renamings_temp.csv'.
	perlErrors := 'tmp/_perl_errors'.
	file := transactionsFile asFileReference.
	cTransactionsOriginal := self loadCommitTransactions: file.
	cTransactions := cTransactionsOriginal copy.
	"Properly escape the double-quotes on this"
	perlSubcommand := 'perl -0777 -ne "while (/commit (.+)\n(?:.*\n)+?similarity index (\d+)+%\n(rename|copy) from (.+)\n\3 to (.+)\n/g) { printf (\"$1,$2,$3,$4,$5\n\")}"'.
	"Load clients and implementations"
	"Read in CSV of structural coupling (client-implementation)"
	file := (projectName , clientImplementationPairsExtension) asFileReference.
	clientImplementationPairsRecords := self loadClientImplementationPairs: file.
	clientImplementationPairsRecords isNotEmpty
		ifTrue: [ "Client file name is second column"
			"Check for case of no clients/implementations (no interfaces), just use original records (nothing to rename)"
			clientsTemp := (clientImplementationPairsRecords collect: #second) asSet.
			"Implementation file name is fifth column"
			implementationsTemp := (clientImplementationPairsRecords collect: #fifth) asSet.
			classesToCheckRenamings := clientsTemp union: implementationsTemp.
			classesToCheckRenamings
				do: [ :class | 
					| projectRepoDir command result renamings dirs csvPath |
					"Generate git history"
					projectRepoDir := tempRepoRoot , projectName.
					command := 'cd ' , projectRepoDir , ' && git log --follow -p "' , oid , '^@" -- "' , class , '" | ' , perlSubcommand , ' > ' , renameHistoryCSV , ' 2>' , perlErrors.
					result := LibC uniqueInstance system: command.
					result = 0
						ifFalse: [ self error: 'LibC system command: '' , command , '' failed.' ]
						ifTrue: [ "Load CSV of renamed names"
							dirs := renameHistoryCSV splitOn: $/.
							csvPath := FileLocator C.
							dirs
								do: [ :dir | 
									dir = ''
										ifFalse: [ csvPath := csvPath / dir ] ].
							renamings := self loadRenamings: csvPath.

							"For each transaction, replace any instance of a 'from' renaming with the current name"
							renamedCTransactions := OrderedCollection new.
							cTransactions
								do: [ :cTransaction | 
									| copyCTransaction i |
									"make copy of transaction record and add it to the new set"
									copyCTransaction := cTransaction copy.
									renamedCTransactions add: copyCTransaction.
									i := 0.
									cTransaction committedFileNames
										do: [ :classToMaybeRename | 
											i := i + 1.
											renamings
												do: [ :renamingRecord | 
													| fromRename percent |
													percent := renamingRecord second.
													fromRename := renamingRecord fourth.
													copyCTransaction renameAll: fromRename to: class ] ].
									"Update for next class to check for renamings"
									cTransactions := renamedCTransactions ] ] ] displayingProgress: 'Renaming classes.' ]
		ifFalse: [ renamedCTransactions := cTransactionsOriginal copy ].
	^self writeCommitTransactions: renamedCTransactions to: projectName , newTransactionExtension
]

{ #category : #'file service' }
GMUtility class >> applyRenamingsToTransactionsFiles: projectsFile [
	"comment stating purpose of message"

	| working projectRecords projectName tempRepoRoot transactionsExtension newTransactionExtension clientImplementationPairsExtension file csvInputStream clientImplementationPairsRecords classesToCheckRenamings perlErrors renameHistoryCSV clientsTemp implementationsTemp perlProgram |
	tempRepoRoot := 'tmp/tempClonesPharo/'.	
	transactionsExtension := '_commits_UIDs_transactions.csv'.
	newTransactionExtension := '_commits_UIDs_transactions_renamed.csv'.
	clientImplementationPairsExtension := '_HEAD_ClientImpPairs.csv'.
	renameHistoryCSV := 'tmp/_renamings_temp.csv'.	
	perlProgram := 'tmp/hist2renamecsv.perl'.
	perlErrors := 'tmp/_perl_errors'.
	self ensureTmpDirectoryCreation.	
 	working := FileSystem disk workingDirectory.
	csvInputStream := (working / projectsFile) readStream.
	projectRecords := self loadProjectsList: csvInputStream.	"ID	Project	Str.Dep.	Log.Dep.	Int.Set	CSD(%)	CLD(%)	GC_url	GitHub_url"	"GitHub url"
	projectRecords
		do: [ :projectRecord | 
			| githubUrl cTransactionsOriginal renamedCTransactions cTransactions |
			githubUrl := projectRecord last.
			githubUrl = 'NA'
				ifFalse: [ projectName := projectRecord second.
					file := (projectName , transactionsExtension) asFileReference.
					cTransactionsOriginal := self loadCommitTransactions: file.
					cTransactions := cTransactionsOriginal copy.
					"Load clients and implementations"
					"Read in CSV of structural coupling (client-implementation)"
					file := (projectName , clientImplementationPairsExtension) asFileReference.
					clientImplementationPairsRecords := self loadClientImplementationPairs: file.
					clientImplementationPairsRecords isNotEmpty 
						ifTrue: [ "Client file name is second column"
							clientsTemp := (clientImplementationPairsRecords collect: #second) asSet.
							"Implementation file name is fifth column"
							implementationsTemp := (clientImplementationPairsRecords collect: #fifth) asSet.
							classesToCheckRenamings := clientsTemp union: implementationsTemp.
							classesToCheckRenamings
								do: [ :class | 
									| projectRepoDir command result renamings dirs csvPath |
									"Generate git history"
									projectRepoDir := tempRepoRoot , projectName.
									command := 'cd ' , projectRepoDir , ' && git log --follow -p -- "' , class , '" | perl -0777 -n ' , perlProgram , ' > ' , renameHistoryCSV , ' 2>' , perlErrors.
									result := LibC uniqueInstance system: command.
									result = 0
										ifFalse: [ 0 halt ]
										ifTrue: [ "Load CSV of renamed names"
													dirs := renameHistoryCSV splitOn: $/.
													csvPath := FileLocator C.
													dirs
														do: [ :dir | 
															dir = ''
																ifFalse: [ csvPath := csvPath / dir ] ].
													renamings := self loadRenamings: csvPath.

													"For each transaction, replace any instance of a 'from' renaming with the current name"
													renamedCTransactions := OrderedCollection new.
													cTransactions
														do: [ :cTransaction | 
															| copyCTransaction i |
															"make copy of transaction record and add it to the new set"
															copyCTransaction := cTransaction copy.
															renamedCTransactions add: copyCTransaction .
															i := 0.
															cTransaction committedFileNames
																do: [ :classToMaybeRename | 
																	i := i + 1.
																	renamings
																				do: [ :renamingRecord | 
																					| fromRename percent |
																					percent := renamingRecord second.
																					fromRename := renamingRecord fourth.
																					copyCTransaction renameAll: fromRename to: class ] ]  .
													"Update for next class to check for renamings"
													cTransactions := renamedCTransactions ] ] ] ]

					"Check for case of no clients/implementations (no interfaces), just use original records (nothing to rename)"
					ifFalse: [ renamedCTransactions  := cTransactionsOriginal  copy ].

					self writeCommitTransactions: renamedCTransactions to: projectName , newTransactionExtension ] ]
		displayingProgress: [ :projectRecord | 'Applying renamings to project: ' , projectRecord second ]
]

{ #category : #'file service' }
GMUtility class >> calculateCouplingIntersections [
	| logicalCouplingFiles arulesExtension clientImpExtension basename trimCurlyBraces linkString results |
	arulesExtension := '_renamed_apriori_rules.csv'.
	clientImpExtension := '_HEAD_ClientImpPairs.csv'.
	linkString := '->'.
	trimCurlyBraces := [ :string | string allButFirst allButLast ].
	results := OrderedCollection new.
	logicalCouplingFiles := FileLocator workingDirectory / 'arules'
		allChildrenMatching: '*' , arulesExtension.
	"	Transcript
		show: 'Processing files: ';
		cr.
	Transcript
		show: (' ' join: logicalCouplingFiles);
		cr."
	logicalCouplingFiles
		do: [ :logicalCouplingFile | 
			| clientImpFile lcInputStream lcRecords scRecords logicalCouplingSet protectedCouplingSet unprotectedCouplingSet logicalProtectedIntersection logicalUnprotectedIntersection |
			basename := logicalCouplingFile basename
				allButLast: arulesExtension size.
			clientImpFile := FileLocator workingDirectory
				/ (basename , clientImpExtension).
			"Transcript
				show: basename;
				cr."
			"Read in CSV of logical coupling"
			lcInputStream := logicalCouplingFile readStream.
			lcRecords := (NeoCSVReader on: lcInputStream)
				separator: $,;
				skipHeader;
				"ruleNumber LHS RHS support confidence lift count"
					addIntegerField;
				"ruleNumber"
					addFieldConverter: trimCurlyBraces;
				"{LHS} - note R puts {...} around the string"
					addFieldConverter: trimCurlyBraces;
				"{RHS}"
					addFloatField;
				"support"
					addFloatField;
				"confidence"
					addFloatField;
				"lift"
					addIntegerField;
				"count"
					upToEnd.

			"Read in CSV of structural coupling (client-implementation)"
			scRecords := self loadClientImplementationPairs: clientImpFile.

			"Create a set of logical coupling"
			logicalCouplingSet := (lcRecords
				collect: [ :each | each second , linkString , each third ]) asSet.
			"Transcript
				show: 'Logical coupling set size: ' , logicalCouplingSet size asString;
				cr."
			protectedCouplingSet := (scRecords
				collect: [ :each | 
					each sixth
						ifTrue: each second , linkString , each fifth ]) asSet.
			"Transcript
				show: 'Protected coupling set size: ' , protectedCouplingSet size asString;
				cr."
			unprotectedCouplingSet := (scRecords
				collect: [ :each | 
					each sixth
						ifFalse: each second , linkString , each fifth ]) asSet.
			"Transcript
				show: 'Unprotected coupling set size: ' , unprotectedCouplingSet size asString;
				cr."
			logicalProtectedIntersection := logicalCouplingSet
				intersection: protectedCouplingSet.
			logicalUnprotectedIntersection := logicalCouplingSet
				intersection: unprotectedCouplingSet.
			"Transcript
				show: 'Intersection of logical coupling and protected coupling set size:' , logicalProtectedIntersection size asString;
				cr."
			"						, (' ' join: logicalProtectedIntersection); cr."
			"Transcript
				show:
					'Intersection of logical coupling and unprotected coupling set size: '
						, logicalUnprotectedIntersection size asString;
				cr."
			"						, (' ' join: logicalUnprotectedIntersection); cr"
			results
				add:
					{basename.
					logicalCouplingSet size.
					protectedCouplingSet size.
					unprotectedCouplingSet size.
					logicalProtectedIntersection size.
					logicalUnprotectedIntersection size} ]
		displayingProgress: [ :file | 'Processing project ' , file basenameWithoutExtension ].
	"Save results to .CSV"
	FileStream
		forceNewFileNamed: 'Logical_and_Structural_Dependency_results.csv'
		do: [ :csvStream | 
			(NeoCSVWriter on: csvStream)
				nextPut:
					#('Project' '|Logical Coupling|' '|Protected Structural Coupling|' '|Unprotected Structural Coupling|' '|Logical Coupling ^ Protected Structural Coupling|' '|Logical Coupling ^ Unprotected Structural Coupling|');
				addFields: #(first second third fourth fifth sixth);
				nextPutAll: results ].
	^ results
]

{ #category : #'file service' }
GMUtility class >> calculateCouplingIntersectionsFor: project at: oid [
	| logicalCouplingFile arulesExtension clientImpExtension basename trimCurlyBraces linkString results clientImpFile lcInputStream lcRecords scRecords logicalCouplingSet protectedCouplingSet unprotectedCouplingSet logicalProtectedIntersection logicalUnprotectedIntersection outRef isOutFileNew |
	arulesExtension := '_renamed_only_clients_and_imps_TR_apriori_rules.csv'.
	clientImpExtension := '_' , oid , '_ClientImpPairs.csv'.
	linkString := '->'.
	trimCurlyBraces := [ :string | string allButFirst allButLast ].
	results := OrderedCollection new.
	logicalCouplingFile := FileLocator workingDirectory / 'arules'
		/ (project , arulesExtension).
	"	Transcript
		show: 'Processing files: ';
		cr.
	Transcript
		show: (' ' join: logicalCouplingFiles);
		cr."
	basename := logicalCouplingFile basename allButLast: arulesExtension size.
	clientImpFile := FileLocator workingDirectory / (basename , clientImpExtension).
	"Transcript
				show: basename;
				cr."
	"Read in CSV of logical coupling"
	lcInputStream := logicalCouplingFile readStream.
	lcRecords := (NeoCSVReader on: lcInputStream)
		separator: $,;
		skipHeader;
		"ruleNumber LHS RHS support confidence lift count"
			addIntegerField;
		"ruleNumber"
			addFieldConverter: trimCurlyBraces;
		"{LHS} - note R puts {...} around the string"
			addFieldConverter: trimCurlyBraces;
		"{RHS}"
			addFloatField;
		"support"
			addFloatField;
		"confidence"
			addFloatField;
		"lift"
			addIntegerField;
		"count"
			upToEnd.

	"Read in CSV of structural coupling (client-implementation)"
	scRecords := self loadClientImplementationPairs: clientImpFile.

	"Create a set of logical coupling"
	logicalCouplingSet := (lcRecords
		collect: [ :each | each second , linkString , each third ]) asSet.
	"Transcript
				show: 'Logical coupling set size: ' , logicalCouplingSet size asString;
				cr."
	protectedCouplingSet := Set new.
	scRecords
		do: [ :each | 
			each sixth
				ifTrue: [ protectedCouplingSet add: each second , linkString , each fifth ] ].
	"Transcript
				show: 'Protected coupling set size: ' , protectedCouplingSet size asString;
				cr."
	unprotectedCouplingSet := Set new.
	scRecords
		do: [ :each | 
			each sixth
				ifFalse: [ unprotectedCouplingSet add: each second , linkString , each fifth ] ].
	"Transcript
				show: 'Unprotected coupling set size: ' , unprotectedCouplingSet size asString;
				cr."
	logicalProtectedIntersection := logicalCouplingSet intersection: protectedCouplingSet.
	logicalUnprotectedIntersection := logicalCouplingSet intersection: unprotectedCouplingSet.
	"Transcript
				show: 'Intersection of logical coupling and protected coupling set size:' , logicalProtectedIntersection size asString;
				cr."
	"						, (' ' join: logicalProtectedIntersection); cr."
	"Transcript
				show:
					'Intersection of logical coupling and unprotected coupling set size: '
						, logicalUnprotectedIntersection size asString;
				cr."
	"						, (' ' join: logicalUnprotectedIntersection); cr"
	results
		add:
			{basename.
			logicalCouplingSet size.
			protectedCouplingSet size.
			unprotectedCouplingSet size.
			logicalProtectedIntersection size.
			logicalUnprotectedIntersection size}.
	"Append results to .CSV"
	outRef := 'Logical_and_Structural_Dependency_results.csv' asFileReference.
	isOutFileNew := outRef exists not.
	outRef
		writeStreamDo: [ :csvStream | 
			| streamWriter |
			"Append"
			csvStream setToEnd.
			streamWriter := NeoCSVWriter on: csvStream.
			isOutFileNew
				ifTrue: [ streamWriter
						nextPut:
							#('Project' '|Logical Coupling|' '|Protected Structural Coupling|' '|Unprotected Structural Coupling|' '|Logical Coupling ^ Protected Structural Coupling|' '|Logical Coupling ^ Unprotected Structural Coupling|') ].
			streamWriter
				addFields: #(first second third fourth fifth sixth);
				nextPutAll: results ].
	^ results
]

{ #category : #'file service' }
GMUtility class >> calculateCouplingIntersectionsFor: project withARulesFile: trFile at: oid [
	| logicalCouplingFile arulesExtension clientImpExtension basename trimCurlyBraces linkString results clientImpFile lcInputStream lcRecords scRecords logicalCouplingSet protectedCouplingSet unprotectedCouplingSet logicalProtectedIntersection logicalUnprotectedIntersection outRef isOutFileNew |
	arulesExtension := '_apriori_rules.csv'.
	clientImpExtension := '_' , oid , '_ClientImpPairs.csv'.
	linkString := '->'.
	trimCurlyBraces := [ :string | string allButFirst allButLast ].
	results := OrderedCollection new.
	logicalCouplingFile := FileLocator workingDirectory / 'arules'
		/ ((trFile asFileReference) basenameWithoutExtension , arulesExtension).
	"	Transcript
		show: 'Processing files: ';
		cr.
	Transcript
		show: (' ' join: logicalCouplingFiles);
		cr."
	basename := logicalCouplingFile basename allButLast: '_only_clients_and_imps_TR.csv' size.
	clientImpFile := FileLocator workingDirectory / (basename , clientImpExtension).
	"Transcript
				show: basename;
				cr."
	"Read in CSV of logical coupling"
	lcInputStream := logicalCouplingFile readStream.
	lcRecords := (NeoCSVReader on: lcInputStream)
		separator: $,;
		skipHeader;
		"ruleNumber LHS RHS support confidence lift count"
			addIntegerField;
		"ruleNumber"
			addFieldConverter: trimCurlyBraces;
		"{LHS} - note R puts {...} around the string"
			addFieldConverter: trimCurlyBraces;
		"{RHS}"
			addFloatField;
		"support"
			addFloatField;
		"confidence"
			addFloatField;
		"lift"
			addIntegerField;
		"count"
			upToEnd.

	"Read in CSV of structural coupling (client-implementation)"
	scRecords := self loadClientImplementationPairs: clientImpFile.

	"Create a set of logical coupling"
	logicalCouplingSet := (lcRecords
		collect: [ :each | each second , linkString , each third ]) asSet.
	"Transcript
				show: 'Logical coupling set size: ' , logicalCouplingSet size asString;
				cr."
	protectedCouplingSet := Set new.
	scRecords
		do: [ :each | 
			each sixth
				ifTrue: [ protectedCouplingSet add: each second , linkString , each fifth ] ].
	"Transcript
				show: 'Protected coupling set size: ' , protectedCouplingSet size asString;
				cr."
	unprotectedCouplingSet := Set new.
	scRecords
		do: [ :each | 
			each sixth
				ifFalse: [ unprotectedCouplingSet add: each second , linkString , each fifth ] ].
	"Transcript
				show: 'Unprotected coupling set size: ' , unprotectedCouplingSet size asString;
				cr."
	logicalProtectedIntersection := logicalCouplingSet intersection: protectedCouplingSet.
	logicalUnprotectedIntersection := logicalCouplingSet intersection: unprotectedCouplingSet.
	"Transcript
				show: 'Intersection of logical coupling and protected coupling set size:' , logicalProtectedIntersection size asString;
				cr."
	"						, (' ' join: logicalProtectedIntersection); cr."
	"Transcript
				show:
					'Intersection of logical coupling and unprotected coupling set size: '
						, logicalUnprotectedIntersection size asString;
				cr."
	"						, (' ' join: logicalUnprotectedIntersection); cr"
	results
		add:
			{basename.
			logicalCouplingSet size.
			protectedCouplingSet size.
			unprotectedCouplingSet size.
			logicalProtectedIntersection size.
			logicalUnprotectedIntersection size}.
	"Append results to .CSV"
	outRef := 'Logical_and_Structural_Dependency_results.csv' asFileReference.
	isOutFileNew := outRef exists not.
	outRef
		writeStreamDo: [ :csvStream | 
			| streamWriter |
			"Append"
			csvStream setToEnd.
			streamWriter := NeoCSVWriter on: csvStream.
			isOutFileNew
				ifTrue: [ streamWriter
						nextPut:
							#('Project' '|Logical Coupling|' '|Protected Structural Coupling|' '|Unprotected Structural Coupling|' '|Logical Coupling ^ Protected Structural Coupling|' '|Logical Coupling ^ Unprotected Structural Coupling|') ].
			streamWriter
				addFields: #(first second third fourth fifth sixth);
				nextPutAll: results ].
	^ results
]

{ #category : #'file service' }
GMUtility class >> calculateCouplingIntersectionsFor: project withARulesFile: trFile from: startOID to: endOID [
	| logicalCouplingFile arulesExtension clientImpExtension basename trimCurlyBraces linkString results clientImpFile lcInputStream lcRecords scRecords logicalCouplingSet protectedCouplingSet unprotectedCouplingSet logicalProtectedIntersection logicalUnprotectedIntersection outRef isOutFileNew |
	arulesExtension := '_apriori_rules.csv'.
	clientImpExtension := '_' , startOID , '_ClientImpPairs.csv'.
	linkString := '->'.
	trimCurlyBraces := [ :string | string allButFirst allButLast ].
	results := OrderedCollection new.
	logicalCouplingFile := FileLocator workingDirectory / 'arules'
		/ ((trFile asFileReference) basenameWithoutExtension , arulesExtension).
	"	Transcript
		show: 'Processing files: ';
		cr.
	Transcript
		show: (' ' join: logicalCouplingFiles);
		cr."
	basename := project. "logicalCouplingFile basename allButLast: arulesExtension size"
	clientImpFile := FileLocator workingDirectory / (basename , clientImpExtension).
	"Transcript
				show: basename;
				cr."
	"Read in CSV of logical coupling"
	lcInputStream := logicalCouplingFile readStream.
	lcRecords := (NeoCSVReader on: lcInputStream)
		separator: $,;
		skipHeader;
		"ruleNumber LHS RHS support confidence lift count"
			addIntegerField;
		"ruleNumber"
			addFieldConverter: trimCurlyBraces;
		"{LHS} - note R puts {...} around the string"
			addFieldConverter: trimCurlyBraces;
		"{RHS}"
			addFloatField;
		"support"
			addFloatField;
		"confidence"
			addFloatField;
		"lift"
			addIntegerField;
		"count"
			upToEnd.

	"Read in CSV of structural coupling (client-implementation)"
	scRecords := self loadClientImplementationPairs: clientImpFile.

	"Create a set of logical coupling"
	logicalCouplingSet := (lcRecords
		collect: [ :each | each second , linkString , each third ]) asSet.
	"Transcript
				show: 'Logical coupling set size: ' , logicalCouplingSet size asString;
				cr."
	protectedCouplingSet := Set new.
	scRecords
		do: [ :each | 
			each sixth
				ifTrue: [ protectedCouplingSet add: each second , linkString , each fifth ] ].
	"Transcript
				show: 'Protected coupling set size: ' , protectedCouplingSet size asString;
				cr."
	unprotectedCouplingSet := Set new.
	scRecords
		do: [ :each | 
			each sixth
				ifFalse: [ unprotectedCouplingSet add: each second , linkString , each fifth ] ].
	"Transcript
				show: 'Unprotected coupling set size: ' , unprotectedCouplingSet size asString;
				cr."
	logicalProtectedIntersection := logicalCouplingSet intersection: protectedCouplingSet.
	logicalUnprotectedIntersection := logicalCouplingSet intersection: unprotectedCouplingSet.
	"Transcript
				show: 'Intersection of logical coupling and protected coupling set size:' , logicalProtectedIntersection size asString;
				cr."
	"						, (' ' join: logicalProtectedIntersection); cr."
	"Transcript
				show:
					'Intersection of logical coupling and unprotected coupling set size: '
						, logicalUnprotectedIntersection size asString;
				cr."
	"						, (' ' join: logicalUnprotectedIntersection); cr"
	results
		add:
			{basename.
			logicalCouplingSet size.
			protectedCouplingSet size.
			unprotectedCouplingSet size.
			logicalProtectedIntersection size.
			logicalUnprotectedIntersection size}.
	"Append results to .CSV"
	outRef := 'Logical_and_Structural_Dependency_results.csv' asFileReference.
	isOutFileNew := outRef exists not.
	outRef
		writeStreamDo: [ :csvStream | 
			| streamWriter |
			"Append"
			csvStream setToEnd.
			streamWriter := NeoCSVWriter on: csvStream.
			isOutFileNew
				ifTrue: [ streamWriter
						nextPut:
							#('Project' '|Logical Coupling|' '|Protected Structural Coupling|' '|Unprotected Structural Coupling|' '|Logical Coupling ^ Protected Structural Coupling|' '|Logical Coupling ^ Unprotected Structural Coupling|') ].
			streamWriter
				addFields: #(first second third fourth fifth sixth);
				nextPutAll: results ].
	^ results
]

{ #category : #pipeline }
GMUtility class >> calculateCouplingIntersectionsFor: project withPairsFile: commitHistoryPairsFile from: startOIDString to: endOIDString selectedCommitsFile: selectedCommitsFile [
	"take the pairs file (commits) and client-implementation pairs and find intersections"

	"Read commit history pairs"

	"Read structural coupling pairs"

	"Create protected set"

	"Create unprotected set"

	"Calculate intersections"

	| subprojectName clientImpExtension linkString interfaces implementations interfacesExtension implementationsExtension interfacesFile implementationsFile results clientImpFile lcInputStream lcRecords scRecords historicalCouplingBag protectedCouplingSet unprotectedCouplingSet historicalProtectedIntersectionBag historicalUnprotectedIntersectionBag outRef isOutFileNew classesExtension classesFile classes clientSet mergedProtectedCouplingSet protectedPairToInterfaceDic mergedHistoricalCouplingBag mergedHistoricalProtectedIntersectionBag |
	clientImpExtension := '_' , startOIDString , '_ClientImpPairs.csv'.
	interfacesExtension := '_' , startOIDString , '_Interfaces.csv'.
	classesExtension := '_' , startOIDString , '_Classes.csv'.
	implementationsExtension := '_' , startOIDString
		, '_Implementations.csv'.
	linkString := '->'.
	results := OrderedCollection new.
	subprojectName := project , '_' , (startOIDString truncate: 7) , '-'
		, (endOIDString truncate: 7 ellipsis: '').
	self
		flag:
			'should not recreate path to ClientImpPairs, it should be passed as argument.'.
	clientImpFile := FileLocator workingDirectory
		/ (project , clientImpExtension).
	classesFile := FileLocator workingDirectory
		/ (project , classesExtension).
	interfacesFile := FileLocator workingDirectory
		/ (project , interfacesExtension).
	implementationsFile := FileLocator workingDirectory
		/ (project , implementationsExtension).

	"Read in CSV of classes"
	classes := classesFile contents lines.

	"Read in CSV of interfaces"
	interfaces := interfacesFile contents lines.

	"Read in CSV of implementations"
	implementations := implementationsFile contents lines.

	"Read in CSV of commit history pairs"
	lcInputStream := commitHistoryPairsFile asFileReference readStream.
	lcRecords := (NeoCSVReader on: lcInputStream)
		separator: $,;
		skipHeader;
		"Project Class_1 Class_2 Commit_ID Revision_number"
			addField;
		"ruleNumber"
			addField;
		"Class_1"
			addField;
		"Class_2"
			addField;
		"Commit_ID"
			addIntegerField;
		"Revision_number"
			upToEnd.

	"Create a bag of historical coupling -- occurrences of each entry will be counted"
	historicalCouplingBag := (lcRecords
		collect: [ :each | each second , linkString , each third ]) asBag.
	"Transcript
				show: 'historical coupling set size: ' , historicalCouplingSet size asString;
				cr."

	"Read in CSV of structural coupling (client-implementation)"
	scRecords := self loadClientImplementationPairs: clientImpFile.

	"Bag allows us to count occurrences"
	protectedCouplingSet := Set new.
	unprotectedCouplingSet := Set new.
	mergedProtectedCouplingSet := Set new.
	protectedPairToInterfaceDic := Dictionary new.
	clientSet := Set new.
	scRecords
		do: [ :each | 
			| isProtected client interface implementation setToAdd |
			client := each second.
			interface := each third.
			implementation := each fifth.
			clientSet add: client.
			isProtected := each sixth
				ifTrue: [ | pCoupling pICoupling |
					pCoupling := client , linkString , implementation.
					pICoupling := client , linkString , interface.
					"Merge couplings with the interface"
					mergedProtectedCouplingSet add: pICoupling.
					"Set a dictionary entry to point to the merged link"
					"Used later to find merges from cochanges "
					protectedPairToInterfaceDic at: pCoupling put: pICoupling.
					setToAdd := protectedCouplingSet ]
				ifFalse: [ setToAdd := unprotectedCouplingSet ].
			setToAdd add: client , linkString , implementation ].

	"Calculate merged cochange"
	mergedHistoricalCouplingBag := (historicalCouplingBag
		collect: [ :each | 
			| pCoupling pICoupling |
			pCoupling := each.
			pICoupling := protectedPairToInterfaceDic
				at: pCoupling
				ifAbsent: [ Transcript logCr: 'missing co-change: ' , pCoupling ] ])
		asBag.
	"Calculate the intersections"
	mergedHistoricalProtectedIntersectionBag := mergedHistoricalCouplingBag
		intersectionKeepingOccurrences: mergedProtectedCouplingSet.
	historicalProtectedIntersectionBag := historicalCouplingBag
		intersectionKeepingOccurrences: protectedCouplingSet.
	historicalUnprotectedIntersectionBag := historicalCouplingBag
		intersectionKeepingOccurrences: unprotectedCouplingSet.
	results
		add:
			{subprojectName.
			(selectedCommitsFile asFileReference contents lines size - 1).
			classes size.
			interfaces size.
			clientSet size.
			implementations size.
			historicalCouplingBag size.
			protectedCouplingSet size.
			mergedProtectedCouplingSet size.
			unprotectedCouplingSet size.
			historicalProtectedIntersectionBag size.
			historicalProtectedIntersectionBag asSet size.
			mergedHistoricalProtectedIntersectionBag size.
			mergedHistoricalProtectedIntersectionBag asSet size.
			historicalUnprotectedIntersectionBag size.
			historicalUnprotectedIntersectionBag asSet size.
			(protectedCouplingSet isEmpty
				ifTrue: [ 'N/A' ]
				ifFalse: [ (historicalProtectedIntersectionBag asSet size
						/ protectedCouplingSet size) asFloat * 100 round: 1 ]).
			(mergedProtectedCouplingSet isEmpty
				ifTrue: [ 'N/A' ]
				ifFalse: [ (mergedHistoricalProtectedIntersectionBag asSet size
						/ mergedProtectedCouplingSet size) asFloat * 100 round: 1 ]).
			(unprotectedCouplingSet isEmpty
				ifTrue: [ 'N/A' ]
				ifFalse: [ (historicalUnprotectedIntersectionBag asSet size
						/ unprotectedCouplingSet size) asFloat * 100 round: 1 ])}.
	"Append results to .CSV"
	outRef := 'Historical_Dependency_and_Structural_Dependency_results.csv'
		asFileReference.
	isOutFileNew := outRef exists not.
	outRef
		writeStreamDo: [ :csvStream | 
			| streamWriter |
			"Append"
			csvStream setToEnd.
			streamWriter := NeoCSVWriter on: csvStream.
			isOutFileNew
				ifTrue: [ streamWriter
						nextPut:
							#('Project' 'Selected_commits' 'Classes' 'Interfaces' 'Clients' 'Implementations' 'HSize' 'PSize' 'P_gSize' 'USize' 'HPSizeM' 'HPSize' 'HP_gSizeM' 'HP_gSize' 'HUSizeM' 'HUSize' 'CPD' 'CGPD' 'CUD') ].
			streamWriter
				addRawFieldsAt: (1 to: 19);
				"#(second third fourth fifth sixth seventh eighth ninth tenth eleventh twelvth thirteenth fourteenth fifteenth sixteenth seventeenth eighteenth nineteenth);"
					nextPutAll: results ].
	^ results
]

{ #category : #'as yet unclassified' }
GMUtility class >> changeHistoryMatrixFromTransactions: transactions classes: classes [
	| histMatrix |
	histMatrix := PMMatrix
		zerosRows: classes size
		cols: transactions size.
	transactions
		doWithIndex: [ :t :j | 
			"t is a GMCommitTransaction"
			t committedFileNames
				do: [ :classFileName | 
					| i |
					i := self
						classIndexFromFileName: classFileName
						InMooseClasses: classes.
					"self assert: (i ~= 0)."
					"i = 0 means that a class was not found (deleted, renamed?)"
					i > 0
						ifTrue: [ histMatrix at: i at: j put: 1 ] ] ].
	^ histMatrix
]

{ #category : #'as yet unclassified' }
GMUtility class >> checkoutRepo: repoPath at: oid to: checkoutDest [
	"Check out the code from a repo into a working directory (outside the repo directory)"

	| command working gitErrors result gitWorkTreeEnvVar |
	working := FileSystem disk workingDirectory.
	gitErrors := working / 'tmp' / 'errors_git'.
	gitWorkTreeEnvVar := 'GIT_WORK_TREE'.

	"setenv for GIT_WORK_TREE -- it's cleaner than an argument to a LibC command with spaces, etc. in path"
	OSEnvironment current
		setEnv: gitWorkTreeEnvVar
		value: checkoutDest fullName.
	('OSEnvironment: ' , gitWorkTreeEnvVar , ' set to '''
		, checkoutDest fullName , '''') record.
	"Command to extract the revision from git into a temp dir so we can generate an MSE file for it"
	command := 'cd ' , repoPath fullName , ' && git checkout ' , oid
		, ' -- . 2>"' , gitErrors fullName , '"'.
	"Work_tree must exist"
	checkoutDest ensureCreateDirectory.
	'LibC: about to run command: ' record.
	(' > ' , command) record.
	result := LibC runCommand: command.
	OSEnvironment current removeKey: gitWorkTreeEnvVar.
	result = 0
		ifFalse: [ self
				abortWithErrorMessageFromFileReference: gitErrors asFileReference
				title: 'Failed to execute: ' , command ].
	^ result
]

{ #category : #'as yet unclassified' }
GMUtility class >> checkoutRepo: repoPath at: oid to: checkoutDest withPostCheckoutCommand: postCheckoutCommand [
	"Check out the code from a repo into a working directory (outside the repo directory)"

	| command working result gitWorkTreeEnvVar checkoutErrors postCheckoutErrors |
	working := FileSystem disk workingDirectory.
	checkoutErrors := working / 'tmp' / 'errors_checkout'.
	postCheckoutErrors := working / 'tmp' / 'errors_post_checkout'.
	gitWorkTreeEnvVar := 'GIT_WORK_TREE'.

	"setenv for GIT_WORK_TREE -- it's cleaner than an argument to a LibC command with spaces, etc. in path"
	OSEnvironment current
		setEnv: gitWorkTreeEnvVar
		value: checkoutDest fullName.
	('OSEnvironment: ' , gitWorkTreeEnvVar , ' set to '''
		, checkoutDest fullName , '''') record.
	"Command to extract the revision from git into a temp dir so we can generate an MSE file for it"
	command := 'cd ' , repoPath fullName , ' && git checkout ' , oid
		, ' -- . 2>"' , checkoutErrors fullName , '"'.
	"Work_tree must exist"
	checkoutDest ensureCreateDirectory.
	'LibC: about to run command: ' record.
	(' > ' , command) record.
	result := LibC runCommand: command.
	OSEnvironment current removeKey: gitWorkTreeEnvVar.
	result = 0
		ifFalse: [ self
				abortWithErrorMessageFromFileReference: checkoutErrors asFileReference
				title: 'Failed to execute: ' , command ].
	"Customized post-checkout command if applicable"
	postCheckoutCommand isNotEmpty
		ifTrue: [ command := 'cd ' , checkoutDest fullName , ' && '
				, postCheckoutCommand , ' 2>"' , postCheckoutErrors fullName , '"'.
			'LibC: about to run CUSTOM command: ' record.
			(' > ' , command) record.
			result := LibC runCommand: command ].
	result = 0
		ifFalse: [ self
				abortWithErrorMessageFromFileReference: postCheckoutErrors asFileReference
				title: 'Failed to execute: ' , command ].
	^ result
]

{ #category : #'as yet unclassified' }
GMUtility class >> classIndexFromFileName: classFileName InMooseClasses: classes [
	"Moose class names aren't by file names - return the index of the class by looking for its Moose File name"
	classes doWithIndex: [ :class :index | classFileName = (GMUtility normalizedFileName: class sourceAnchor fileName) ifTrue: [^index] ].
	^0 "not found"
]

{ #category : #'as yet unclassified' }
GMUtility class >> cloneRepo: url [
	"clone a repo of a project (if it doesn't already exist) and return its handle "

	| projectName location |
	"Get project name from URL, accounting for cases where it ends in .git"
	"Clone repo locally if not already there"
	projectName := self extractProjectNameFromURL: url.
	location := (self cloneRoot , projectName) asFileReference.
	location exists
		ifFalse: [ "IceGitClone new
				location: location;
				url: url;
				execute"
			| cloneCommand working cloneDir gitErrors result |
			working := FileSystem disk workingDirectory.
			cloneDir := working / 'tmp' / 'tempClonesPharo'.
			gitErrors := working / 'tmp' / 'errors_gitClone'.
			"Command to extract the revision from git into a temp dir so we can generate an MSE file for it"
			cloneCommand := 'cd "' , cloneDir fullName , '" && git clone ' , url , ' 2>"'
				, gitErrors fullName , '"'.
			'LibC: About to run command: ' record.
			(' > ', cloneCommand) record.
			result := LibC runCommand: cloneCommand.
			result = 0
				ifFalse: [ self
						abortWithErrorMessageFromFileReference: gitErrors asFileReference
						title: 'Failed to execute: ' , cloneCommand ] ].
	self assert: location exists.
	^ location
]

{ #category : #accessing }
GMUtility class >> cloneRoot [
	^ cloneRoot
]

{ #category : #accessing }
GMUtility class >> cloneRoot: anObject [
	cloneRoot := anObject
]

{ #category : #'as yet unclassified' }
GMUtility class >> cochangeMatrixFromChangeHistory: aChangeHistoryMatrix forClasses: classes [
	^ GMCochangeMatrix with: aChangeHistoryMatrix classes: classes
]

{ #category : #'as yet unclassified' }
GMUtility class >> commitswithoutInterfaces: commitsFile project: project start: startOIDString [
	| commits interfaces commitsWithoutInterfaces interfacesFile interfacesExtension |
	interfacesExtension := '_' , startOIDString , '_Interfaces.csv'.

	"Load commits"
	commits := GMUtility readSelectedCommitsFile: commitsFile.

	"Load interfaces"
	interfacesFile := FileLocator workingDirectory
		/ (project , interfacesExtension).
	interfaces := interfacesFile contents lines.
	"Get interface set with just interface name, which looks like: 
	 'com::baeldung::dao::repositories::ItemTypeRepository' 
	 as 'ItemTypeRepository'"
	"interfaces := (interfacesMoose
		collect: [ :interface | (interface splitOn: '::') last ]) asSet."
	"Make sure we didn't lose anything"
	"self assert: interfaces size equals: interfacesMoose size."

	"Remove commits that contain interfaces"
	commitsWithoutInterfaces := commits
		reject: [ :commit | 
			| committedFiles |
			committedFiles := commit third splitOn: ' '.
			(committedFiles intersection: interfaces) isNotEmpty ].
	^ self
		rewriteSelectedCommits: commitsWithoutInterfaces
		file: commitsFile
]

{ #category : #'as yet unclassified' }
GMUtility class >> createJavaMSEOn: revPath using: pathToJavaToFamixCommand named: mseFileName [
	"create an MSE file from the source code in revPath using the Java parser"

	| command result working javaToFamixOutput javaToFamixErrors verveineJ5Options |
	working := FileSystem disk workingDirectory.
	javaToFamixOutput := working / 'tmp' / 'output_java_to_famix'.
	javaToFamixErrors := working / 'tmp' / 'errors_java_to_famix'.
	verveineJ5Options := '-Xms1g -Xmx15g -- -o ' , mseFileName
		, ' -anchor assoc -alllocals .'.	"-localaccesses -autocp "
	command := 'cd "' , revPath fullName , '" && "'
		, pathToJavaToFamixCommand , '" > "' , javaToFamixOutput fullName
		, '" ' , verveineJ5Options , ' 2> "' , javaToFamixErrors fullName
		, '"'.
	'LibC: about to run command: ' record.
	(' > ' , command) record.
	result := LibC runCommand: command.
	result = 0
		ifFalse: [ self
				abortWithErrorMessageFromFileReference: javaToFamixErrors
				title: 'The command ''' , command , ''' terminated with errors' ].
	^ result
]

{ #category : #pipeline }
GMUtility class >> dependencyMatrixFromMooseModel: aMooseModel [
	"Create a dependency matrix D where D(i,j)=1 means that i depends on j, and D(i,j)=0 is independence."

 	"There is a dependency between classes i and j if 
	  1) i extends or implements j,
	  2) i uses j as member or variable,
	  3) i references members or calls a method of j."

 	| d classes |
	classes := self mooseClassesForDependencyMining: aMooseModel.
	d := PMMatrix zerosRows: classes size cols: classes size.
	"d := Array2D rows: classes size columns: classes size."
	classes
		doWithIndex: [ :classJ :j | 
			| classJClients |
			classJClients := classJ clientTypes reject: #isStub.
			"clientTypes includes inheritance, so we can just put 1's in the array for each classJClient"
			classJClients do: [ :classI |
				| i |
				"find index of classI in classes to find the column"
				i := classes indexOf: classI.
				self assert: (i ~= 0).
				d at: i at: j put: 1.
				 ]
		].
	^ GMDependencyMatrix new matrix: d; classes: classes
]

{ #category : #pipeline }
GMUtility class >> ensureTmpDirectoryCreation [
	(FileLocator workingDirectory / 'tmp') ensureCreateDirectory.
	(FileLocator workingDirectory / 'tmp' / 'data_mining')
		ensureCreateDirectory.
	(FileLocator workingDirectory / 'tmp' / 'tempClonesPharo')
		ensureCreateDirectory
]

{ #category : #'as yet unclassified' }
GMUtility class >> exampleMineInterfacesAndMakeUML [
	| scRecords |
	GMUtility mineProjectsWithLog: #('fuhrmanator/FactoryVariants').
	scRecords := GMUtility
		loadClientImplementationPairs: 'FactoryVariants_HEAD_ClientImpPairs.csv' asFileReference.
	GMUtility
		writePlantUMLOutputFor: scRecords
		toFile: 'FactoryVariants_HEAD.puml'
]

{ #category : #'as yet unclassified' }
GMUtility class >> extractProjectNameFromURL: url [
	| projectName |
	projectName := (url splitOn: '/') last.
	(projectName endsWith: '.git')
		ifTrue: [ projectName := projectName allButLast: '.git' size ].
	^ projectName
]

{ #category : #'file service' }
GMUtility class >> generateClientImplementationPairs: mseFileRef [
	"For the given MSE file, mine the client-implementation pairs info"

	| results clientImplementationsFile interfacesFile implementationsFile interfaceNames implementationNames |
	[ :job | 
	job title: 'Mining client-implementation pairs...'.
	results := GMInterfaceMiner
		mineClientImplementationPairs: mseFileRef
		withPrefix: ''.
	"results size = 0 ifTrue: 0halt."	"-> no interfaces will yield this"
	"Save results to .CSV"
	job title: 'Saving files...'.
	interfaceNames := (results second
		collect: [ :c | GMUtility normalizedFileName: c sourceAnchor fileName ])
		asSortedCollection.
	interfacesFile := self
		writeInterfaces: interfaceNames
		file: mseFileRef.
	job progress: 0.3.
	implementationNames := (results third
		collect: [ :c | GMUtility normalizedFileName: c sourceAnchor fileName ]) asSortedCollection.
	implementationsFile := self
		writeImplementations: implementationNames
		file: mseFileRef.
	job progress: 0.6.
	clientImplementationsFile := self
		writeClientImplementationPairs: results first
		file: mseFileRef ] asJob run.
	^ clientImplementationsFile
]

{ #category : #'file service' }
GMUtility class >> generateLogicalCouplingPairsWithRSingleFile: filePath [
	"Use R to do some calculations"

	| command pathToRFiles |
	self isRInPath
		ifFalse: [ UIManager default
				abort:
					'Rscript could not be found in the path. R must be installed and Rscript''s directory must be added to the system path'.
			"Return non-zero means something bad happened"
			^ 1 ].
	self ensureTmpDirectoryCreation.	
	pathToRFiles := (self locationOfProjectRepo / 'R/') pathString.
	command := self getLocalRCommand , ' "' , pathToRFiles
		, '/GenerateLogicalPairsFromTransactionsSingleFile.R" "' , filePath
		, '" 2> /tmp/R.errors.txt'.
	^ LibC uniqueInstance system: command
]

{ #category : #'file service' }
GMUtility class >> generateMSEFileFor: oid reponame: repoName [
	"Generate a Moose MSE for the OID -- OID can be hexString or 'HEAD' "

	| working destPath repoPath revPath result mseFromJavaToFamix mseDestination pathToJavaToFamixCommand checkoutDest |
	destPath := Path * 'tmp' / 'data_mining'.
	working := FileSystem disk workingDirectory.
	checkoutDest := working
		resolve: destPath / (repoName , '_master') / oid.
	repoPath := Path * 'tmp' / 'tempClonesPharo' / repoName.
	revPath := destPath / (repoName , '_master') / oid.
	mseFromJavaToFamix := working resolve: revPath / oid , 'mse'.
	mseDestination := working
		resolve: destPath / (repoName , '_master') / oid , 'mse'.

	"Only if the MSE does not already exist"
	mseDestination exists
		ifFalse: [ pathToJavaToFamixCommand := self queryJavaToFamixCommand.
			pathToJavaToFamixCommand
				ifNil: [ self
						error:
							'This tool can not run without a Java-to-MSE parser (JDT2Famix, VerveineJ).' ].
			[ :job | 
			job
				title: 'To create MSE file, checking out copy of repo at ' , oid;
				progress: 1 / 3.


			"Only checkout if the checkout doesn't exist"
			checkoutDest exists
				ifFalse: [ result := self checkoutRepo: repoPath at: oid to: checkoutDest ]
				ifTrue: [ result := 0.
					('Skipping git checkout of ' , oid
						, ' because it''s already there.') record ].
			result = 0
				ifTrue: [ 
					job
						title: 'Generating MSE file in ' , revPath fullName;
						progress: 2 / 3.
					result := self createJavaMSEOn: revPath using: pathToJavaToFamixCommand named: (oid , '.mse').
					result = 0
						ifTrue: [ "Move the file out of the directory"
							('Moving ' , mseFromJavaToFamix asString , ' to '
								, mseDestination asString) record.
							mseFromJavaToFamix exists
								ifTrue: [ mseDestination exists
										ifTrue: [ mseDestination delete ].
									mseFromJavaToFamix moveTo: mseDestination ] ] ] ] asJob run ].
	^ mseDestination
]

{ #category : #'file service' }
GMUtility class >> generateMSEFileFor: oid reponame: repoName withPostCheckoutCommand: postCheckoutCommand [
	"Generate a Moose MSE for the OID -- OID can be hexString or 'HEAD' "

	| working destPath repoPath revPath result mseFromJavaToFamix mseDestination pathToJavaToFamixCommand checkoutDest |
	destPath := Path * 'tmp' / 'data_mining'.
	working := FileSystem disk workingDirectory.
	checkoutDest := working
		resolve: destPath / (repoName , '_master') / oid.
	repoPath := Path * 'tmp' / 'tempClonesPharo' / repoName.
	revPath := destPath / (repoName , '_master') / oid.
	mseFromJavaToFamix := working resolve: revPath / oid , 'mse'.
	mseDestination := working
		resolve: destPath / (repoName , '_master') / oid , 'mse'.

	"Only if the MSE does not already exist"
	mseDestination exists
		ifFalse: [ pathToJavaToFamixCommand := self queryJavaToFamixCommand.
			pathToJavaToFamixCommand
				ifNil: [ self
						error:
							'This tool can not run without a Java-to-MSE parser (JDT2Famix, VerveineJ).' ].
			[ :job | 
			job
				title: 'To create MSE file, checking out copy of repo at ' , oid;
				progress: 1 / 3.


			"Only checkout if the checkout doesn't exist"
			checkoutDest exists
				ifFalse: [ result := self
						checkoutRepo: repoPath
						at: oid
						to: checkoutDest
						withPostCheckoutCommand: postCheckoutCommand ]
				ifTrue: [ result := 0.
					('Skipping git checkout of ' , oid
						, ' because it''s already there.') record ].
			result = 0
				ifTrue: [ job
						title: 'Generating MSE file in ' , revPath fullName;
						progress: 2 / 3.
					result := self
						createJavaMSEOn: revPath
						using: pathToJavaToFamixCommand
						named: oid , '.mse'.
					result = 0
						ifTrue: [ "Move the file out of the directory"
							('Moving ' , mseFromJavaToFamix asString , ' to '
								, mseDestination asString) record.
							mseFromJavaToFamix exists
								ifTrue: [ mseDestination exists
										ifTrue: [ mseDestination delete ].
									mseFromJavaToFamix moveTo: mseDestination ] ] ] ] asJob run ].
	^ mseDestination
]

{ #category : #'file service' }
GMUtility class >> generatePairsAndTransactions: selectedCommitsFile [
	"Create the logical coupling candidate pairs and transaction file from the set of selected commits"

	| selectedCommitsFileRef csvRecords logicalCouplingRecords project commitTransactions cp ct |
	"Parse the CSV and gather the UIDs for commits that match criteria"
	selectedCommitsFileRef := selectedCommitsFile asFileReference.
	project := selectedCommitsFileRef basenameWithoutExtension.
	csvRecords := self readSelectedCommitsFile: selectedCommitsFile.
	logicalCouplingRecords := OrderedCollection new.
	commitTransactions := OrderedCollection new.	"Transaction data: UID, item, item, ..."
	"Write out the logical coupling of java classes for the selected commits"
	"It's pairs of classes in the committed_files set"
	csvRecords
		do: [ :rec | 
			| committedFiles committedClasses classPairs uid revNum |
			uid := rec first.
			revNum := rec second.
			committedFiles := rec third splitOn: Character space.
			committedClasses := committedFiles
				select: [ :each | each endsWith: '.java' ].
			commitTransactions
				addFirst:
					(GMCommitTransaction new
						uid: uid;
						committedFileNames: committedClasses).	"ID, item, item, ..."
			classPairs := committedClasses combinations
				select: [ :each | each size = 2 ].
			"Note: this won't create pair-entries for commits with only one java file."
			classPairs
				do: [ :pair | 
					"Add the pair twice - logical coupling could be either direction"
					logicalCouplingRecords
						addFirst:
							{project.
							pair first.
							pair second.
							uid.
							revNum}.
					logicalCouplingRecords
						addFirst:
							{project.
							pair second.
							pair first.
							uid.
							revNum} ] ]
		displayingProgress: 'Selecting commits according to criteria...'.
	"self crLog: 'Creating file ', (file basenameWithoutExtension) , '_logicalcoupling.csv'."
	[ :job | 
	job title: 'Writing class pairs.'.
	cp := self
		writeClassPairs: logicalCouplingRecords
		file: selectedCommitsFile.
	job
		progress: 0.5;
		title: 'Writing transactions.'.
	"Generates a 'transactions' (basket) style file for arules in R"
	ct := self
		writeCommitTransactions: commitTransactions
		to: selectedCommitsFile ] asJob run.
	^ Array with: cp with: ct
]

{ #category : #accessing }
GMUtility class >> generateSelectedCommits: commitMetadataFile [
	"Selects commits from metadata file and writes the list"

	| csvRecords selectedCommits addedFiles countCommittedFiles hasJava |
	csvRecords := self loadCommitMetadataFile: commitMetadataFile.
	selectedCommits := csvRecords
		select: [ :each | 
			"		commitID := each first. 
		revisionNumber := each second. "
			addedFiles := each third.
			countCommittedFiles := each fourth.
			hasJava := each fifth.
			"		committedFiles := each sixth."
			addedFiles isNil & (countCommittedFiles <= 10) & (hasJava = 'true') ].
	^ self writeSelectedCommits: selectedCommits file: commitMetadataFile
]

{ #category : #'as yet unclassified' }
GMUtility class >> getLocalRCommand [
	^ 'Rscript'
]

{ #category : #'as yet unclassified' }
GMUtility class >> getOIDFromTag: tagString on: loc [
	"based on example from https://ben.straub.cc/2013/06/03/refs-tags-and-branching/ "
	| repoHandle gitRef result toReturn |
	toReturn := nil.
	repoHandle := LGitRepository on: loc.
	repoHandle open.
	gitRef := LGitReference of: repoHandle.
	result := gitRef reference_lookup: nil repo: repoHandle name: 'refs/tags/' , tagString.
	result = LGitReturnCodeEnum git_ok
		ifTrue: [ toReturn := gitRef targetId hexString ].
	^ toReturn
]

{ #category : #'as yet unclassified' }
GMUtility class >> historyRevwalk: repo from: startTag to: endTag [
	"inits an LGitRevwalk for history between two tags, formatted as 'tags/blah*' where 'blah' is the tag name"
	| revwalk |
	revwalk := LGitRevwalk of: repo.
	revwalk beSortedByCommitTime.
	revwalk beSortedParentsBeforeChildren.
	revwalk pushGlob: startTag.
	revwalk hideGlob: endTag.
	^ revwalk

]

{ #category : #initialization }
GMUtility class >> initialize [
	"init the variables used in mining"
	cloneRoot := 'tmp/tempClonesPharo/'.
	self ensureTmpDirectoryCreation

]

{ #category : #'as yet unclassified' }
GMUtility class >> isRInPath [
	"Make sure RScript.exe can be found"
	| result rCommand |
	rCommand := self getLocalRCommand.
 	result := LibC uniqueInstance system: rCommand, ' --version'.
	^ result = 0

]

{ #category : #'file service' }
GMUtility class >> loadClientImplementationPairs: fileReference [
	| scRecords scInputStream |
	scInputStream := fileReference  readStream.
	scRecords := (NeoCSVReader on: scInputStream)
		separator: $,;
		skipHeader;
		"Client ClientFile Interface Implementation ImplementationFile Protected"
			addField;
		"Client (Moose name)"
			addField;
		"ClientFile (file name)"
			addField;
		"Interface"
			addField;
		"Implementation (Moose name)"
			addField;
		"ImplementationFile (file name)"
			addFieldConverter: [ :string | string = 'true' ];
		"Protected"
			upToEnd.
	^ scRecords
]

{ #category : #'file service' }
GMUtility class >> loadCommitMetadataFile: fileName [ 
	"Parse the CSV and gather the UIDs for commits that match criteria"
	| csvInputStream csvRecords |
	csvInputStream := fileName asFileReference readStream.
	csvRecords := (NeoCSVReader on:  csvInputStream) 
		separator: $,;
		skipHeader;
		addField; "Commit_id"
		addField; "Revision_number"
		addField; "set of Added_files"
		addIntegerField; "n_committed_files"
		addField; "has_java"
		addField; "committed_files"
		upToEnd.
		^ csvRecords
]

{ #category : #'file service' }
GMUtility class >> loadCommitTransactions: transactionsFileReference [
	"Load commit transactions. Note NeoCSVReader doesn't support variable records, so we declare spots for many entries, and remove them after."

	| transactionRecords csvInputStream |
	csvInputStream := transactionsFileReference  readStream.
	transactionRecords := (NeoCSVReader on: csvInputStream)
		separator: $,;
		"Commit UID"
			addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		upToEnd.

	csvInputStream close.
	"Get rid of the nil elements in the transactions"
	^ transactionRecords 
		collect: [ :transaction | 
			GMCommitTransaction transactionFromRecord:  (transaction asCollection select: #isNotNil) ]
]

{ #category : #'as yet unclassified' }
GMUtility class >> loadMooseModelFromMSE: mseFileRef [
	"Load the moose Model with some error checking"
	| mseStream mooseModel |
	mseStream := mseFileRef readStream.
	mseStream
		ifNotNil: [ mooseModel := MooseModel importFromMSEStream: mseStream.
			mseStream close. ^mooseModel ]
		ifNil: [ self error: 'Could not load MSE file into Moose: ' , mseFileRef asString ].
]

{ #category : #'file service' }
GMUtility class >> loadProjectsList: csvInputStream [
	| csvRecords |
	csvRecords := (NeoCSVReader on: csvInputStream)
		separator: $,;
		skipHeader;
		"ID	Project	Str.Dep.	Log.Dep.	Int.Set	CSD(%)	CLD(%)	GC_url	GitHub_url"
			addIntegerField;
		addField;
		addIntegerField;
		addIntegerField;
		addIntegerField;
		addIntegerField;
		addIntegerField;
		addField;
		addField;
		"GitHub url"
			upToEnd.
	^ csvRecords
]

{ #category : #'file service' }
GMUtility class >> loadRenamings: csvPath [
 	"Load csv file of renamings (from git history)"
	| records |
	records := (NeoCSVReader on: csvPath readStream)
		separator: $,;
		"UID"
		addField;
		"percentage"
		addIntegerField; 
		"operation (copy or rename)"
		addField;
		"from name"
		addField;
		"to name"
		addField;		
		upToEnd.
		^ records
]

{ #category : #'as yet unclassified' }
GMUtility class >> locationOfProjectRepo [
	"finds the location of the project (e.g., to find R files that are not part of Pharo)"

	| icebergRepository |
	icebergRepository := IceRepository registry
		detect: [ :repository | 
			repository workingCopy packages
				anySatisfy: [ :package | package name = 'GitMiner' ] ]
		ifNone:
			[ self error: 'No repository in Iceberg containing the needed files.' ].
	icebergRepository location exists
		ifFalse: [ self
				error:
					'The repository of the project does not have a pointer to a local clone to find the files' ].
	^ icebergRepository location
]

{ #category : #pipeline }
GMUtility class >> mineClientChangesNoARules: gitName url: urlString [
	"Mine the whole repo, using HEAD and nil as limits"
	^ self mineClientChangesNoARules: gitName url: urlString from: 'HEAD' to: ''
]

{ #category : #pipeline }
GMUtility class >> mineClientChangesNoARules: gitName url: urlString from: startOIDString to: endOIDString [
	"Pipeline to mine changes of clients of interfaces - don't use ARules to calculate Logical Coupling"

	| loc commitMetadata selectedCommits pairsAndTransactions mseFileRef cimpFile commitsWithoutInterfaces |
	[ :job | 
	job title: 'Cloning repo...'.
	loc := GMUtility cloneRepo: urlString.
	job progress: 1/6.
	job title: 'Gathering commit data...'.
	commitMetadata := GMUtility
		annotateCommitsOnRepoLeftBranchOnly: loc
		from: startOIDString
		to: endOIDString.
	job progress: 2/6.
	job title: 'Selecting commits...'.
	selectedCommits := GMUtility generateSelectedCommits: commitMetadata.
	job progress: 3/6.
	job title: 'Generating MSE file...'.
	mseFileRef := GMUtility
		generateMSEFileFor: startOIDString
		reponame: loc basename.
	job progress: 4/6.
	job title: 'Generating client-implementation pairs...'.
	cimpFile := GMUtility generateClientImplementationPairs: mseFileRef.
	job title: 'Removing commits with interfaces'.
	commitsWithoutInterfaces := GMUtility
		commitswithoutInterfaces: selectedCommits
		project: gitName
		start: startOIDString.
	job progress: 5/6.
	job title: 'Generating pairs and transactions...'.
	pairsAndTransactions := GMUtility
		generatePairsAndTransactions: commitsWithoutInterfaces.

	job progress: 6/6.
	job title: 'Calculating final stats...'.
	GMUtility
		calculateCouplingIntersectionsFor: gitName
		withPairsFile: pairsAndTransactions first
		from: startOIDString
		to: endOIDString
		selectedCommitsFile: commitsWithoutInterfaces ] asJob run
]

{ #category : #pipeline }
GMUtility class >> mineFactoryEvolution: gitName url: urlString [
	"Mine the whole repo, using HEAD and nil as limits"
	^ self mineFactoryEvolution: gitName url: urlString from: 'HEAD' to: ''
]

{ #category : #pipeline }
GMUtility class >> mineFactoryEvolution: gitName url: urlString from: startOIDString to: endOIDString [
	"Pipeline to mine changes instances of Factory-related evolutions"

	| loc feMine mseFileRef aNoUpcasting aUpcasting |
	[ :job | 
	job title: 'Cloning repo for ' , gitName.
	('----> NEW PROJECT: ' , gitName) record.
	loc := GMUtility cloneRepo: urlString.
	job progress: 1 / 6.
	job title: 'Generating MSE file...'.
	mseFileRef := GMUtility
		generateMSEFileFor: startOIDString
		reponame: loc basename.
	job progress: 3 / 6.
	job title: 'Mining factory evolution patterns...'.
	'Mining factory evolution patterns...' record.
	feMine := GMFactoryEvolutionMine fromMSE: mseFileRef.
	feMine load.
	feMine
		sourceFolder: (mseFileRef parent / mseFileRef basenameWithoutExtension) fullName.

	"Show the classes where there are instances of upcasting or no"
	aNoUpcasting := feMine assignmentsOfImplementationsWithoutUpCasting.
	aUpcasting := feMine assignmentsOfImplementationsWithUpCasting.
	'----> Classes with instantiations that are NOT upcast:' record.
	aNoUpcasting
		ifNotNil: [ aNoUpcasting
				do: [ :a | 
					a variable famixVariable isNil
						ifTrue: [ ('''' , a sourceCode
								, ''' in class UNKNOWN -- famixVariable is nil.') record ]
						ifFalse: [ ('''' , a sourceCode , ''' in class '
								, a variable famixVariable declaredType mooseName) record ] ] ]
		ifNil: [ 'None.' record ].
	'----> Classes with instantiations that ARE upcast:' record.
	aUpcasting
		ifNotNil: [ aUpcasting
				do: [ :a | 
					('''' , a sourceCode , ''' in '
						,
							((a variable famixVariable typeOf: FAMIXLocalVariable)
								ifTrue: [ 'method '
										, a variable famixVariable parentBehaviouralEntity mooseName
										, ' in class '
										, a variable famixVariable parentBehaviouralEntity parentType mooseName ]
								ifFalse: [ 'class ' , a variable famixVariable declaredType mooseName ]))
						record	 ] ]
		ifNil: [ 'None.' record ].
	job progress: 6 / 6
	"	job title: 'Calculating final stats...'.
	GMUtility
		calculateCouplingIntersectionsFor: gitName
		withPairsFile: pairsAndTransactions first
		from: startOIDString
		to: endOIDString
		selectedCommitsFile: commitsWithoutInterfaces" ] asJob run
]

{ #category : #pipeline }
GMUtility class >> mineFactoryEvolution: gitName url: urlString from: startOIDString to: endOIDString withPostCheckoutCommand: postCheckoutCommand [
	"Pipeline to mine changes instances of Factory-related evolutions"

	| loc feMine mseFileRef aNoUpcasting aUpcasting |
	[ :job | 
	job title: 'Cloning repo for ' , gitName.
	('----> NEW PROJECT: ' , gitName) record.
	loc := GMUtility cloneRepo: urlString.
	job progress: 1 / 6.
	job title: 'Generating MSE file...'.
	mseFileRef := GMUtility
		generateMSEFileFor: startOIDString
		reponame: loc basename withPostCheckoutCommand: postCheckoutCommand.
	job progress: 3 / 6.
	job title: 'Mining factory evolution patterns...'.
	'Mining factory evolution patterns...' record.
	feMine := GMFactoryEvolutionMine fromMSE: mseFileRef.
	feMine load.
	feMine
		sourceFolder: (mseFileRef parent / mseFileRef basenameWithoutExtension) fullName.

	"Show the classes where there are instances of upcasting or no"
	aNoUpcasting := feMine assignmentsOfImplementationsWithoutUpCasting.
	aUpcasting := feMine assignmentsOfImplementationsWithUpCasting.
	'----> Classes with instantiations that are NOT upcast:' record.
	aNoUpcasting
		ifNotNil: [ aNoUpcasting
				do: [ :a | 
					('''' , a sourceCode , ''' in class '
						, a variable famixVariable declaredType mooseName) record ] ]
		ifNil: [ 'None.' record ].
	'----> Classes with instantiations that ARE upcast:' record.
	aUpcasting
		ifNotNil: [ aUpcasting
				do: [ :a | 
					('''' , a sourceCode , ''' in class '
						, a variable famixVariable parentType mooseName) record ] ]
		ifNil: [ 'None.' record ].
	job progress: 6 / 6
	"	job title: 'Calculating final stats...'.
	GMUtility
		calculateCouplingIntersectionsFor: gitName
		withPairsFile: pairsAndTransactions first
		from: startOIDString
		to: endOIDString
		selectedCommitsFile: commitsWithoutInterfaces" ] asJob run
]

{ #category : #pipeline }
GMUtility class >> mineFactoryEvolution: gitName url: urlString withPostCheckoutCommand: postCheckoutCommand [
	"Mine the whole repo, using HEAD and nil as limits"
	^ self mineFactoryEvolution: gitName url: urlString from: 'HEAD' to: '' withPostCheckoutCommand: postCheckoutCommand
]

{ #category : #'as yet unclassified' }
GMUtility class >> mineFactoryEvolutionProjectsWithLog: projects [
	"The projects is a collection of two-item collections; the first item is a github project owner/name and the second item is a command to run after checking out the code."
	| working logName |
	logName := 'tmp/FactoryEvolution.log'.
	TinyLogger default
		ensureFileLoggerNamed: logName; clearLog.
	working := FileSystem disk workingDirectory.
	"OSEnvironment current
		setEnv: 'JDT2FAMIXCOMMAND'
		value: '/mnt/c/Users/fuhrm/Documents/GitHub/VerveineJ/verveinej.sh'."
	"value: '/mnt/c/verveineJ5/verveinej.sh'."
	projects
		do: [ :projectEntry | 
			| pName ownerAndName postCheckoutCommand |
			ownerAndName := projectEntry first.
			postCheckoutCommand := projectEntry second.
			pName := (ownerAndName splitOn: '/') last.
			('Mining project ' , ownerAndName) record.
			"Check if files exist for project - if so, don't do mining"
			(working / (pName , '_HEAD_Interfaces.csv')) exists
				ifFalse: [ [ "GMUtility generateMSEFileFor: 'HEAD' reponame: name."
					GMUtility
						mineFactoryEvolution: pName
						url: 'https://github.com/' , ownerAndName 
						withPostCheckoutCommand: postCheckoutCommand ]
						on: AssertionFailure
						do: [ :exception | 
							exception tag = #GitMinerException
								ifTrue: [ ('>>>> Mining exception while processing project ' , ownerAndName) record.
									exception messageText record ]
								ifFalse: [ 'Caught unknown AssertionFailure exception.' record.
									0 halt ] ] ]
				ifTrue: [ ' --> skipping since found .csv files for project' record ] ]
		displayingProgress: [ :ownerAndName | 'Mining project: ' , ownerAndName ]
]

{ #category : #'as yet unclassified' }
GMUtility class >> mineFixedProjectListWithLog [
	| working projectList |
	working := FileSystem disk workingDirectory.
	OSEnvironment current
		setEnv: 'JDT2FAMIXCOMMAND'
		value: '/mnt/c/verveineJ5/verveinej.sh'.

	"OSEnvironment current at: 'JDT2FAMIXCOMMAND'."

	projectList := (GMGitHubGraphQLQuery hardCodedProjectList difference: GMGitHubGraphQLQuery hardCodedVerveineJCrashingProjectList) difference: GMGitHubGraphQLQuery hardCodedExcludedProjectList.
	'Mining.log' asFileReference
		ensureDelete;
		writeStreamDo: [ :stream | 
			projectList
				do: [ :ownerAndName | 
					| pName |
					pName := (ownerAndName splitOn: '/') last.
					stream
						nextPutAll: DateAndTime now asString , ': Mining project ' , ownerAndName;
						crlf.
					"Check if files exist for project - if so, don't do mining"
					(working / (pName , '_HEAD_Interfaces.csv')) exists
						ifFalse: [ [ "GMUtility generateMSEFileFor: 'HEAD' reponame: name."
							GMUtility
								mineClientChangesNoARules: pName
								url: 'https://github.com/' , ownerAndName ]
								on: AssertionFailure
								do: [ :exception | 
									exception tag = #GitMinerException
										ifTrue: [ stream
												nextPutAll:
													DateAndTime now asString , ': Mining exception processing project '
														, ownerAndName;
												crlf.
											stream
												nextPutAll: exception messageText;
												crlf.
											stream flush ]
										ifFalse: [ stream
												nextPutAll:
													DateAndTime now asString
														, ': Caught unknown AssertionFailure exception.';
												crlf.
											0 halt ] ] ]
						ifTrue: [ "Skip the mining"
							stream
								nextPutAll:
									DateAndTime now asString
										, ': skipping since found .csv files for project';
								crlf ] ]
				displayingProgress: [ :ownerAndName | 'Mining project: ' , ownerAndName ] ]
]

{ #category : #'as yet unclassified' }
GMUtility class >> mineProjectsWithLog: projects [
	| working |
	working := FileSystem disk workingDirectory.
	OSEnvironment current
		setEnv: 'JDT2FAMIXCOMMAND'
		value: '/mnt/c/Users/fuhrm/Documents/GitHub/VerveineJ/verveinej.sh'.
		"value: '/mnt/c/verveineJ5/verveinej.sh'."

	"OSEnvironment current at: 'JDT2FAMIXCOMMAND'."
	
	"(GMGitHubGraphQLQuery hardCodedProjectList difference: GMGitHubGraphQLQuery hardCodedCrashingProjectList)"
	'Mining.log' asFileReference
		ensureDelete;
		writeStreamDo: [ :stream | 
			projects
				do: [ :ownerAndName | 
					| pName |
					pName := (ownerAndName splitOn: '/') last.
					stream
						nextPutAll: DateAndTime now asString , ': Mining project ' , ownerAndName;
						crlf.
					"Check if files exist for project - if so, don't do mining"
					(working / (pName , '_HEAD_Interfaces.csv')) exists
						ifFalse: [ [ "GMUtility generateMSEFileFor: 'HEAD' reponame: name."
							GMUtility
								mineClientChangesNoARules: pName
								url: 'https://github.com/' , ownerAndName ]
								on: AssertionFailure
								do: [ :exception | 
									exception tag = #GitMinerException
										ifTrue: [ stream
												nextPutAll:
													DateAndTime now asString , ': Mining exception processing project '
														, ownerAndName;
												crlf.
											stream
												nextPutAll: exception messageText;
												crlf.
											stream flush ]
										ifFalse: [ stream
												nextPutAll:
													DateAndTime now asString
														, ': Caught unknown AssertionFailure exception.';
												crlf.
											0 halt ] ] ]
						ifTrue: [ "Skip the mining"
							stream
								nextPutAll:
									DateAndTime now asString
										, ': skipping since found .csv files for project';
								crlf ] ]
				displayingProgress: [ :ownerAndName | 'Mining project: ' , ownerAndName ] ]
]

{ #category : #'as yet unclassified' }
GMUtility class >> mineTestProjectWithLog [
	| working |
	working := FileSystem disk workingDirectory.
	OSEnvironment current
		setEnv: 'JDT2FAMIXCOMMAND'
		value: '/mnt/c/verveineJ5/verveinej.sh'.

	"OSEnvironment current at: 'JDT2FAMIXCOMMAND'."

	"(GMGitHubGraphQLQuery hardCodedProjectList difference: GMGitHubGraphQLQuery hardCodedCrashingProjectList)"
	'Mining.log' asFileReference
		ensureDelete;
		writeStreamDo: [ :stream | 
			#('fuhrmanator/FactoryVariants')
				do: [ :ownerAndName | 
					| pName |
					pName := (ownerAndName splitOn: '/') last.
					stream
						nextPutAll: DateAndTime now asString , ': Mining project ' , ownerAndName;
						crlf.
					"Check if files exist for project - if so, don't do mining"
					(working / (pName , '_HEAD_Interfaces.csv')) exists
						ifFalse: [ [ "GMUtility generateMSEFileFor: 'HEAD' reponame: name."
							GMUtility
								mineClientChangesNoARules: pName
								url: 'https://github.com/' , ownerAndName ]
								on: AssertionFailure
								do: [ :exception | 
									exception tag = #GitMinerException
										ifTrue: [ stream
												nextPutAll:
													DateAndTime now asString , ': Mining exception processing project '
														, ownerAndName;
												crlf.
											stream
												nextPutAll: exception messageText;
												crlf.
											stream flush ]
										ifFalse: [ stream
												nextPutAll:
													DateAndTime now asString
														, ': Caught unknown AssertionFailure exception.';
												crlf.
											0 halt ] ] ]
						ifTrue: [ "Skip the mining"
							stream
								nextPutAll:
									DateAndTime now asString
										, ': skipping since found .csv files for project';
								crlf ] ]
				displayingProgress: [ :ownerAndName | 'Mining project: ' , ownerAndName ] ]
]

{ #category : #'as yet unclassified' }
GMUtility class >> mooseClassesForDependencyMining: aMooseModel [
	"Cyril F. helped immensely with crafting the class selection so as not to have strangeness in classes"
	^((aMooseModel allWithSubTypesOf: FamixTClass) reject: #isStub) reject: #isAnonymousClass.
]

{ #category : #pipeline }
GMUtility class >> navigateToFile: userMessage extensions: ext [
	"Ask the user to find something on the filesystem"
	^ UIManager default chooseExistingFileReference: userMessage extensions: ext path: FileLocator home.

]

{ #category : #'as yet unclassified' }
GMUtility class >> normalizedFileName: fileName [
	"Fix the namings since files from git logs don't have a './' at the start"

	| fixedName |
	fixedName := fileName.
	(fixedName beginsWith: './')
		ifTrue: [ fixedName := fixedName allButFirst: 2 ].
	^ fixedName
]

{ #category : #'file service' }
GMUtility class >> queryJavaToFamixCommand [
	"Read the command from the environment variable, or if it's not set, get the user to find the command"
	| pathToJDT2FamixCommand |
	pathToJDT2FamixCommand := OSEnvironment current
		at: 'JDT2FAMIXCOMMAND'
		ifAbsent: [ | cmdFileRef |
			cmdFileRef := self
				navigateToFile:
					'JDT2FAMIXCOMMAND environment variable not defined. Please select the JDT2Famix script.'
				extensions: #('cmd' 'sh').
			cmdFileRef
				ifNotNil: [ "set the environment variable"
					OSEnvironment current
						setEnv: 'JDT2FAMIXCOMMAND'
						value: cmdFileRef fullName.
					"we want the string containing the entire path, not a file ref"
					cmdFileRef fullName ] ].
	^ pathToJDT2FamixCommand
]

{ #category : #'file service' }
GMUtility class >> readSelectedCommitsFile: selectedCommitsFile [
	| csvRecords csvInputStream |
	csvInputStream := selectedCommitsFile asFileReference readStream.
	csvRecords := (NeoCSVReader on: csvInputStream)
		separator: $,;
		skipHeader;
		addField;
		"Commit_id"
			addField;
		"Revision_number"
			addField;
		"committed_files"
			upToEnd.
	^ csvRecords
]

{ #category : #'file service' }
GMUtility class >> removeUnrelatedClassesFromTransactions: project [
	"Go through renamed transaction files and remove the class names that aren't clients or implementations"
	 | cTransactions file clientImplementationPairsRecords clientsTemp implementationsTemp classesToInclude | 
	file := (project,'_commits_UIDs_transactions_renamed.csv') asFileReference .
	cTransactions := self loadCommitTransactions:  file.
	file := (project, '_HEAD_ClientImpPairs.csv') asFileReference .
	clientImplementationPairsRecords := self loadClientImplementationPairs: file.
	clientImplementationPairsRecords size > 0
	ifTrue: [ "Client file name is second column"
		clientsTemp := (clientImplementationPairsRecords collect: #second) asSet.
		"Implementation file name is fifth column"
		implementationsTemp := (clientImplementationPairsRecords collect: #fifth) asSet.
		classesToInclude := clientsTemp union: implementationsTemp.
		cTransactions do: [ :cTran |
			cTran committedFileNames: (cTran committedFileNames intersection: classesToInclude )
			 ]
		].
	self writeCommitTransactions: cTransactions  to: project,'_commits_UIDs_transactions_renamed_only_clients_and_imps.csv'.	
	^cTransactions
]

{ #category : #'file service' }
GMUtility class >> removeUnrelatedClassesFromTransactions: project fromRevision: oid [
	"Go through renamed transaction files and remove the class names that aren't clients or implementations"
	 | cTransactions file clientImplementationPairsRecords clientsTemp implementationsTemp classesToInclude | 
	file := (project,'_commits_tags_OIDs_TR_renamed_TR.csv') asFileReference .
	cTransactions := self loadCommitTransactions:  file.
	file := (project, '_', oid , '_ClientImpPairs.csv') asFileReference .
	clientImplementationPairsRecords := self loadClientImplementationPairs: file.
	clientImplementationPairsRecords size > 0
	ifTrue: [ "Client file name is second column"
		clientsTemp := (clientImplementationPairsRecords collect: #second) asSet.
		"Implementation file name is fifth column"
		implementationsTemp := (clientImplementationPairsRecords collect: #fifth) asSet.
		classesToInclude := clientsTemp union: implementationsTemp.
		cTransactions do: [ :cTran |
			cTran committedFileNames: (cTran committedFileNames intersection: classesToInclude )
			 ]
		].
	^self writeCommitTransactions: cTransactions  to: project,'_commits_UIDs_transactions_renamed_only_clients_and_imps.csv'
]

{ #category : #'file service' }
GMUtility class >> removeUnrelatedClassesFromTransactions: project withTransactionsFile: transFile fromRevision: oid [
	"Go through renamed transaction files and remove the class names that aren't clients or implementations"
	 | cTransactions file clientImplementationPairsRecords clientsTemp implementationsTemp classesToInclude | 
	file := transFile asFileReference .
	cTransactions := self loadCommitTransactions:  file.
	file := (project, '_', oid , '_ClientImpPairs.csv') asFileReference .
	clientImplementationPairsRecords := self loadClientImplementationPairs: file.
	clientImplementationPairsRecords size > 0
	ifTrue: [ "Client file name is second column"
		clientsTemp := (clientImplementationPairsRecords collect: #second) asSet.
		"Implementation file name is fifth column"
		implementationsTemp := (clientImplementationPairsRecords collect: #fifth) asSet.
		classesToInclude := clientsTemp union: implementationsTemp.
		cTransactions do: [ :cTran |
			cTran committedFileNames: (cTran committedFileNames intersection: classesToInclude )
			 ]
		].
	^self writeCommitTransactions: cTransactions  to: file basenameWithoutExtension , '_only_clients_and_imps.csv'
]

{ #category : #'file service' }
GMUtility class >> rewriteSelectedCommits: selectedCommits file: fileName [
	"E.g. when a subsequent filter has been applied to commit data that's already in 3 columns"
	| file selCommitsFileName |
	file := fileName asFileReference.
	selCommitsFileName := file basenameWithoutExtension , '_selected.csv'.
	selCommitsFileName asFileReference
		ensureDelete;
		writeStreamDo: [ :csvStream | 
			(NeoCSVWriter on: csvStream)
				nextPut: #('Commit_id' 'Revision_number' 'committed_files');
				addFields: #(first second third);
				nextPutAll: selectedCommits ].
	^ selCommitsFileName
]

{ #category : #'as yet unclassified' }
GMUtility class >> shortOID: oidString [
	"Take the traditional (github) 7 characters of an OID string, but don't chop it if it's shorter (e.g., HEAD)"
	self flag: 'Should make this smarter to handle commit-ish'.
	^ oidString truncate: 7 ellipsis: ''
]

{ #category : #'file service' }
GMUtility class >> writeClassPairs: logicalCouplingRecords file: fromFileName [
	| newFileName |
	newFileName := fromFileName asFileReference basenameWithoutExtension
		, '_LC.csv'.
	newFileName asFileReference
		ensureDelete;
		writeStreamDo: [ :csvStream | 
			(NeoCSVWriter on: csvStream)
				nextPut: #('Project' 'Class_1' 'Class_2' 'Commit_ID' 'Revision_number');
				addFields: #(first second third fourth fifth);
				nextPutAll: logicalCouplingRecords ].
	^ newFileName
]

{ #category : #writing }
GMUtility class >> writeClasses: classes file: mseFileRef [
	"Save results to file"

	| fileName projectName |
	projectName := mseFileRef parent basename allButLast: '_master' size.
	fileName := projectName , '_' , mseFileRef basenameWithoutExtension
		, '_' , 'Classes' , '.csv'.
	[ :job | 
	job title: 'Writing classes.'.
	fileName asFileReference
		ensureDelete;
		writeStreamDo: [ :stream | 
			classes
				do: [ :aFamixTClass | 
 
					stream
						nextPutAll: (GMUtility normalizedFileName: aFamixTClass sourceAnchor fileName) ;
						cr ] ] ] asJob run.
	^ fileName
]

{ #category : #writing }
GMUtility class >> writeClientImplementationPairs: results file: mseFileRef [
	"Save results to CSV file"

	| fileName projectName |
	projectName := mseFileRef parent basename allButLast: '_master' size.
	fileName := projectName , '_' , mseFileRef basenameWithoutExtension
		, '_' , 'ClientImpPairs' , '.csv'.
	[ :job | 
	job title: 'Writing client-implementation pairs.'.
	FileStream
		forceNewFileNamed: fileName
		do: [ :csvStream | 
			(NeoCSVWriter on: csvStream)
				nextPut:
					#('Client' 'ClientFile' 'Interface' 'Implementation' 'ImplementationFile' 'Protected');
				addFields: #(first second third fourth fifth sixth);
				nextPutAll: results ] ] asJob run.
	^ fileName
]

{ #category : #writing }
GMUtility class >> writeCommitResults: commitDataList to: fileName [
	" Generate a CSV with commit results"

	FileStream
		forceNewFileNamed: fileName
		do: [ :csvStream | 
			"{newerCommit . addedFiles . difference numberOfDeltas . atLeastOneJavaFile . committedFiles}"
			(NeoCSVWriter on: csvStream)
				nextPut: #('Commit_id' 'Revision_num' 'Added_files' 'n_commited_files' 'has_java' 'committed_files');
				addFields: #(first second third fourth fifth sixth);
				nextPutAll: commitDataList ].
]

{ #category : #writing }
GMUtility class >> writeCommitTransactions: transactionRecords to: selectedCommitsFile [
	"Write out single column (with embedded commas!)"

	| concatRecords outFileName |
	outFileName := selectedCommitsFile asFileReference
		basenameWithoutExtension , '_TR.csv'.
	"Concatenate variable number of items with commas, since we can't use NeoCSV to write them"
	concatRecords := OrderedCollection new.
	transactionRecords
		ifNotNil: [ concatRecords := transactionRecords
				collect:
					[ :cTran | cTran uid , ',' , ($, join: cTran committedFileNames)	"ID, item, item, ..." ] ].
	outFileName asFileReference
		ensureDelete;
		writeStreamDo: [ :stream | 
			concatRecords
				do: [ :rec | 
					stream
						nextPutAll: rec;
						cr ] ].
	^ outFileName
]

{ #category : #writing }
GMUtility class >> writeImplementations: implementations file: mseFileRef [
	"Save results to file"

	| fileName projectName |
	projectName := mseFileRef parent basename allButLast: '_master' size.
	fileName := projectName , '_' , mseFileRef basenameWithoutExtension
		, '_' , 'Implementations' , '.csv'.
	[ :job | 
	job title: 'Writing implementations.'.
	fileName asFileReference
		ensureDelete;
		writeStreamDo: [ :stream | 
			implementations
				do: [ :c | 
					stream
						nextPutAll: c ;
						cr ] ] ] asJob run.
	^ fileName
]

{ #category : #writing }
GMUtility class >> writeInterfaces: interfaces file: mseFileRef [
	"Save results to file"

	| fileName projectName |
	projectName := mseFileRef parent basename allButLast: '_master' size.
	fileName := projectName , '_' , mseFileRef basenameWithoutExtension
		, '_' , 'Interfaces' , '.csv'.
	[ :job | 
	job title: 'Writing interfaces.'.
	fileName asFileReference
		ensureDelete;
		writeStreamDo: [ :stream | 
			interfaces
				do: [ :interface | 
					stream
						nextPutAll: interface ;
						cr ] ] ] asJob run.
	^ fileName
]

{ #category : #writing }
GMUtility class >> writePlantUMLOutputFor: scList toFile: plantUMLFile [
	| pumlHistory writeOnce interfaces clients implementations |
	pumlHistory := Set new.
	writeOnce := [ :lineToWrite :stream | 
	(pumlHistory includes: lineToWrite)
		ifFalse: [ pumlHistory add: lineToWrite.
			stream
				nextPutAll: lineToWrite;
				cr ] ].
	interfaces := (scList collect: #third) asSet.
	implementations := (scList collect: #fourth) asSet.
	clients := (scList collect: #first) asSet.
	FileStream
		forceNewFileNamed: plantUMLFile
		do: [ :stream | 
			stream
				nextPutAll: '@startuml';
				cr.
			stream
				nextPutAll: 'skinparam style strictuml';
				cr.
			stream
				nextPutAll: 'hide empty members';
				cr.
			stream
				nextPutAll: 'skinparam backgroundColor transparent';
				cr.
			stream
				nextPutAll: 'skinparam classBorderColor transparent';
				cr.
			stream
				nextPutAll: 'skinparam classArrowColor lightgreen';
				cr.
			stream
				nextPutAll: 'left to right direction';
				cr.
			stream
				nextPutAll: '''scale 0.1';
				cr.
			stream
				nextPutAll: 'set namespaceSeparator ::';
				cr.
			stream
				nextPutAll:
					'''This file generated from Pharo/Smalltalk, C. Fuhrman, École de technologie supérieure';
				cr.

			"All interfaces"
			interfaces
				do: [ :interface | 
					| color |
					color := '#lightblue'.
					"Special case where interface is also a client"
					(clients includes: interface)
						ifTrue: [ color := '#lightblue/lightgreen' ].
					stream
						nextPutAll: 'interface "' , interface , '" ' , color;
						cr ].
			"All clients"
			clients
				do: [ :client | 
					(interfaces includes: client)
						ifFalse: [ | color |
							color := '#lightgreen'.
							"Special case where client is also an implementation"
							(implementations includes: client)
								ifTrue: [ color := '#lightgreen/yellow' ].
							stream
								nextPutAll: 'class "' , client , '" ' , color;
								cr ] ].
			"All implementations"
			implementations
				do: [ :implementation | 
					"Special case where client is also an implementation"
					(clients includes: implementation)
						ifFalse: [ stream
								nextPutAll: 'class "' , implementation , '" #yellow';
								cr ] ].
			scList
				do: [ :e | 
					| isProtected client interface implementation line |
					client := e first.
					interface := e third.
					implementation := e fourth.
					isProtected := e sixth.
					"Implements an interface"
					line := '"' , implementation , '" .[' , '#lightblue' , '].|> "'
						, interface , '"'.
					writeOnce value: line value: stream.

					"Client coupling to implementation"
					line := '"' , client , '" --> "' , interface , '"'.
					writeOnce value: line value: stream.
					isProtected
						ifFalse: [ line := '"' , client , '" .[' , '#red' , '].> "' , implementation
								, '"'.
							writeOnce value: line value: stream ] ].
			stream
				nextPutAll: '@enduml';
				cr ]
]

{ #category : #'file service' }
GMUtility class >> writeSelectedCommits: selectedCommits file: fileName [
	| file selCommitsFileName |
	file := fileName asFileReference.
	selCommitsFileName := file basenameWithoutExtension , '_selected.csv'.
	selCommitsFileName asFileReference
		ensureDelete;
		writeStreamDo: [ :csvStream | 
			(NeoCSVWriter on: csvStream)
				nextPut: #('Commit_id' 'Revision_number' 'committed_files');
				addFields: #(first second sixth);
				nextPutAll: selectedCommits ].
	^ selCommitsFileName
]
