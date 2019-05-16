# GitMiner

Pharo smalltalk tools to mine (Java) Git Repos, work with R, Perl, git, etc. Tested mostly under Windows, but also works on MacOS and Linux versions (the paths should be relative to the image directory).

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

## Sample execution	

For now, most of the functions are in the `GMUtility` class (the code is unstable). To mine interface client changes In a Playground, execute:

```Smalltalk
GMUtility mineClientChanges: 'cassandra' url: 'https://github.com/apache/cassandra' from: 'HEAD' to: 'bfbc5274f2b3a5af2cbbe9679f0e78f1066ef638'.
```

![Example Pipeline](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/fuhrmanator/GitMiner/master/doc/pipelineExample.puml?cacheChangeCount=0)

## Sample mine results

Here's a PlantUML diagram of the results of a static analysis of the clients and implementations of interfaces defined in [fuhrmanator/FactoryVariants](https://github.com/fuhrmanator/FactoryVariants)

![PlantUML class diagram of Clients (green), Interfaces (blue) and Implementations (yellow)](https://www.plantuml.com/plantuml/svg/tLlDZjis4BxxAOZqa4lYRQz24IHskaKEoHfrsg8eWe8hZILYAL8WgGQxw0lqKVeSUR6EPSkMPSisVxnSx6NXbQMPRxvlPZYIwBVQK6Ngae_q7HCLLRGasjnpmB-AfSqt1Sk0G5cPUr92UGjATqw-fUbThcGjigdaKX6ZgD3u5GZJEIlbLEk9L1ceawUzKqf-NPt5MLwON0684OU58KOIjJn4CgOWDKoAqKkTKaJx_VY7aGP312q1xQOmXwL9WqQIPFJoSy4qMJ0yCGS1U1moib2o9BE2AdarBoddXlAxLsGw9jTreKegNf5l_wOIBy7e3QI5G4WvGsBgwjj_Ya6jOCI40RL0T-H50JHRCALDacIWMOuX6VnIw2J14n38VP9KxE61qaMIp9OVFWWCBMD8mVNgX1VakoRYMrx3LITsLozpMgVGDUgE5weAb1GiYBNV84SYTH1RKqxBC9RUopelXYnfLbOS_jfSzM6cP5Qd9amC1O3U5Qgf12TQczHgRQtonyNOi9aVtyE2rjoG6PO-pU7DKeHb5d-Iwpp-I9cmk_HcSUfIwwG8nCEdFuxNQcFvwXuubrzz7CpnCDYHzZipnQ-YKXAx4pQq09gtLHw8krLU1pF6KfhB4sJrwtJU_7z8CsyGbqk9d_AyubGicuk7bMib7q2q_T73q4U97nHUJpUDQjUQa5l2rtrnwkVoHk3QlcUYBsuONpEgS6QWulpW9duEVu5iLMb-Pd2c4LDLQzCkN6UHvOdzMe4k3kVK0QBU-JcRSEnuDvpz3PuPFEDr-LcME0ws8v67iP-fuYmzbszF2kOL4pJTLzUkW6jTA2bBtxJ5yO8AEL0dTeYemhWK3I07ba5wTwGExEX6PTlgN4sxQsEU-JR-SplRVHd_yyPfaBS4SMAjUltwAQ10Ol3Gbx4jbZx3bgXw-HT3dk71yf6K6GRWAiekgxOr4vUDzPJwIDusRTqpyzexwTYjuJ8uNFEmPTUsAMoMoJYgXEm8mI4uzuIML4iaxPJrrAHmvM4TZoMEdGduIVOALpwwaLaYwjm_FPVis8Pa2MNxgE1PPSScB4iuw-S6poKjLk546wGSUN0UfHpzzMzCFTLVcucuU8T6uDwLTeYr7QVs7Xj64IRuh7iH6CxZLPzasrhjFVoC8b5iRPmRbfkxxZDKNxuRAp5RLLW0hcNGeTHQZCvRaXXgXEzF5q3XhikMtNXDmTdzetdhlylnJCILbOXj8J00r_JhqMelokwRXHYg16yFbq3XeSyEmz5QXBjx7s_3hmptCsrm0zA-cTwUXmQV--KTRGVnZWPU_bg5SVu-brCHdM-f4zp128xOwkrsSiRKitCQqV0kY91PSrhswM7P9w5ajo9cCaoCBI1lOYQ7YR4LA0mnqsEMUjlkJkLmkDNSPnaTCEi6RswQdMJsFVmIA5oNqK6gWw_oyNKxi0qmbdW7eBWgU9nvsxcajuqp5Zyx-v6ZYRJT2XmlJphRO6E1sDlPv5lD6qiHRpCl0C9vpq6FtzYtUPT24ecV9q2CUm5lFRu5aIr_RFK_)
