# GitMiner

Pharo smalltalk tools to mine Git Repos, work with R, Perl, git, etc. Tested only under Windows so far...

## Installation

You must start with a Pharo image that has Moose. Then load it using Metacello

```Smalltalk
Metacello new
  repository: 'github://fuhrmanator/GitMiner/src';
  baseline: 'GitMiner';
  load.
```

For now, most of the functions are in the Utility class (unstable).

![Example Pipeline](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/fuhrmanator/GitMiner/master/doc/pipelineExample.puml?cacheChangeCount=0)
