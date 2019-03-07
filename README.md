# GitMiner

Pharo smalltalk tools to mine (Java) Git Repos, work with R, Perl, git, etc. Tested only under Windows so far.

## Installation

You must start with a Pharo image that has Moose. Then load it using Metacello:

```Smalltalk
Metacello new
  repository: 'github://fuhrmanator/GitMiner/src';
  baseline: 'GitMiner';
  load.
```

Since this project uses `LibC system command` to run external tools, the baseline will also make sure that `Rscript` is in your path. Some functions require Java runtime, perl, and git, but those aren't verified on the install.

### Environment variables

The variable `JDT2FAMIXCOMMAND` must point to the script for parsing Java to MSE.

# Sample execution

For now, most of the functions are in the `GMUtility` class (the code is unstable). To mine interface client changes In a Playground, execute:

```Smalltalk
GMUtility mineClientChanges: 'cassandra' url: 'https://github.com/apache/cassandra' from: 'HEAD' to: 'bfbc5274f2b3a5af2cbbe9679f0e78f1066ef638'.
```

![Example Pipeline](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/fuhrmanator/GitMiner/master/doc/pipelineExample.puml?cacheChangeCount=0)
