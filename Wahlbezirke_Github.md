---
title: 'Digitales Werkzeug zur Unterstützung der Wahlbezirkszuschnitte'
author: ""
date: ""
output: 
  html_document:
    keep_md: true
---



&nbsp;

### Identifying Alternative Districts for Blocs Located in Overpopulated Voting Districts

&nbsp;

Eighteen voting districts in Tempelhof-Schönefeld are overpopulated (> 2,500 inhabitants). Redrawing the borders of these voting districts implies the reassignment of some of their voting blocs to adjacent districts. The dataset presented here proposes all possible district reassignments for blocs located in overpopulated voting districts.

&nbsp;

### 1. Presenting the Dataset

&nbsp;

The dataset containing all alternative districts by bloc is called **optimization_options.csv**. 

&nbsp;

#### 1.1 Idea

&nbsp;

The main idea here is to identify alternative voting district classifications for relevant blocs wherever possible. The method consists in relocating blocs from overpopulated districts to *adjacent districts* that are not themselves overpopulated.

Thus, we need to focus on **relevant blocs** for which **an optimization is possible**:

**(1) Relevant blocs**: blocs within overpopulated voting districts.

**(2) Possible optimization**: relevant blocs adjacent to blocs from other voting districts that are not themselves overpopulated. We are using these adjacent blocs to identify alternative voting districts to switch relevant blocs to.

&nbsp;

<center> <h5>*Figure 1: Applicability of Optimization Code for Each Bloc X* </h5> </center>
&nbsp;

<center>
<!--html_preserve--><div id="htmlwidget-bb0b16d18a6845c39314" style="width:672px;height:500px;" class="grViz html-widget"></div>
<script type="application/json" data-for="htmlwidget-bb0b16d18a6845c39314">{"x":{"diagram":"\ndigraph rmarkdown {\n\nnode [fontname = Helvetica]\nA [label = \"Bloc X Located in an \n Overpopulated Voting District\"]\nB [label = \"Yes\"]\nC [label = \"No\"]\nD [label = \"Bloc X Adjacent to at \n Least one Bloc from a \n Different Voting District\"]\nE [label = \"Yes\"]\nF [label = \"No\"]\nG [label = \"This Different \n Voting District is not \n Itself Overpopulated\"]\nH [label = \"Yes\"]\nI [label = \"No\"]\nJ [label = \"Code Outputs Voting \n District Optimization \n Suggestion for Bloc X\"]\n\nA -> B\nA -> C\nB -> D\nD -> E\nD -> F\nE -> G\nG -> H\nG -> I\nH -> J\n}\n","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->
</center>

&nbsp;

#### 1.2 Method Justification

&nbsp;

Optimization suggestions are performed using the  `poly2nb()` function (**spdep** package in R). The function builds a neighbours list based on regions with contiguous boundaries (i.e. sharing one or more boundary points). In this case, because blocs are not directly contiguous---they are separated by physical barriers, most often streets or pavement---boundary points less than 0.0008 degrees (that is to say, 0.0008 * 111km, or 80 meters) apart are considered to indicate contiguity. This distance can be manually modified. The 0.0008 degrees threshold was selected because it seemed to offer the most effective way to identify adjacent blocs given the nature of the data. Any threshold will likely generate slight discrepancies---the goal is to minimize their occurrence by finding a good balance between over- and under-selection of adjacent districts.

&nbsp;

However, an advantage of using the 80 meters distance between blocs criterion it that it **takes into account the physical boundaries that increase the distance between blocs**---for instance large roads, parks or rivers---which we want to avoid within one same district. This seems to offer a better solution than directly using the adjacency between blocs and nearby districts, because some districts contain large sections of physical boundaries without blocs.

&nbsp;

Please note that this strategy builds on the adjacency of bloc boundaries rather than on the adjacency of bloc centroids. This is useful in order to avoid distortions for very large blocs. 

&nbsp;

Finally, this strategy suggests a way to produce marginal modifications to the current voting district map. That is to say, only the blocs located at the border of currently existing districts are matched with a potential new voting district.

&nbsp;

#### 1.3 Operationalization

&nbsp;

The optimization suggestions dataset contains the following information. The unit of observation (rows) is each bloc in Tempelhof-Schönefeld (1,032 in total).

&nbsp;

| Variable name                        | Description | 
|:-----------------|:------------------------------------------------------------|
| Block_Nummer | Bloc X Identification Number | 
| Block_Einwohnerzahl | Bloc X Number of Inhabitants | 
| Wahlbezirk_Bloeckezahl | Voting District Identification Number Associated with Bloc X | 
| Wahlbezirk_Uebervoelkert | Binary (dummy) Variable Indicating an Overpopulated Voting District Associated with Bloc X |
| Block_Nachbar_1, Block_Nachbar_2, ... |  Identification Number of Blocs Adjacent to Bloc X (NA when non-applicable)| 
| Block_Nachbar_1_Wahlbezirk, Block_Nachbar_2_Wahlbezirk, ... | Voting District Identification Number Associated with Blocs Adjacent to Bloc X  (NA when non-applicable) | 
| Optimized_Wahlbezirk_1, Optimized_Wahlbezirk_2, ... | Suggestion of Alternative Voting Districts for Bloc X (NA when non-applicable) | 

&nbsp;

#### 1.4 Dataset Content 

&nbsp;


```r
# Loading the dataset
myData <- read.csv("/Users/evelynebrie/Dropbox/CityLab/Projects/Wahlbezirke/Data/optimization_options.csv")

# Displaying the column names
colnames(myData)
```

```
##  [1] "X"                           "Block_Nummer"               
##  [3] "Block_Einwohnerzahl"         "Wahlbezirk_Nummer"          
##  [5] "Wahlbezirk_Bloeckezahl"      "Wahlbezirk_Einwohnerzahl"   
##  [7] "Wahlbezirk_Uebervoelkert"    "Block_Nachbar_1"            
##  [9] "Block_Nachbar_2"             "Block_Nachbar_3"            
## [11] "Block_Nachbar_4"             "Block_Nachbar_5"            
## [13] "Block_Nachbar_6"             "Block_Nachbar_7"            
## [15] "Block_Nachbar_8"             "Block_Nachbar_9"            
## [17] "Block_Nachbar_10"            "Block_Nachbar_11"           
## [19] "Block_Nachbar_12"            "Block_Nachbar_13"           
## [21] "Block_Nachbar_1_Wahlbezirk"  "Block_Nachbar_2_Wahlbezirk" 
## [23] "Block_Nachbar_3_Wahlbezirk"  "Block_Nachbar_4_Wahlbezirk" 
## [25] "Block_Nachbar_5_Wahlbezirk"  "Block_Nachbar_6_Wahlbezirk" 
## [27] "Block_Nachbar_7_Wahlbezirk"  "Block_Nachbar_8_Wahlbezirk" 
## [29] "Block_Nachbar_9_Wahlbezirk"  "Block_Nachbar_10_Wahlbezirk"
## [31] "Block_Nachbar_11_Wahlbezirk" "Block_Nachbar_12_Wahlbezirk"
## [33] "Block_Nachbar_13_Wahlbezirk" "Optimized_Wahlbezirk_1"     
## [35] "Optimized_Wahlbezirk_2"      "Optimized_Wahlbezirk_3"     
## [37] "Optimized_Wahlbezirk_4"      "Optimized_Wahlbezirk_5"     
## [39] "Optimized_Wahlbezirk_6"
```

```r
# Displaying the number of overpopulated districts
x <- table(myData$Wahlbezirk_Nummer,myData$Wahlbezirk_Uebervoelkert)
sum((x[,2])!=0)
```

```
## [1] 18
```
&nbsp;

Note that a minority of blocs (158 out of 1,032, or approximately 15\%) are located in overpopulated districts within Tempelhof-Schönefeld.

&nbsp;

```r
# Number of blocs located in overpopulated districts
sum(myData$Wahlbezirk_Uebervoelkert)
```

```
## [1] 158
```

```r
# Percentage of blocs located in overpopulated districts
sum(myData$Wahlbezirk_Uebervoelkert)/length(myData$Wahlbezirk_Uebervoelkert)*100
```

```
## [1] 15.31008
```

&nbsp;

However, not all of these 158 blocs could possibly be switched to another voting district. Indeed, only 100 of these districts have one redistricting suggestion or more. 

&nbsp;

```r
# Showing how many blocs have at least one optimization suggestion (100)
sum(!is.na(myData$Optimized_Wahlbezirk_1))
```

```
## [1] 100
```

```r
# Showing how many blocs have at least two optimization suggestions (54)
sum(!is.na(myData$Optimized_Wahlbezirk_2))
```

```
## [1] 54
```

```r
# Showing how many blocs have at least three optimization suggestions (26)
sum(!is.na(myData$Optimized_Wahlbezirk_3))
```

```
## [1] 26
```

```r
# Showing how many blocs have at least four optimization suggestions (5)
sum(!is.na(myData$Optimized_Wahlbezirk_4))
```

```
## [1] 5
```

```r
# Showing how many blocs have at least five optimization suggestions (1)
sum(!is.na(myData$Optimized_Wahlbezirk_5))
```

```
## [1] 1
```

```r
# Showing how many blocs have at least six optimization suggestions (none)
sum(!is.na(myData$Optimized_Wahlbezirk_6))
```

```
## [1] 0
```
&nbsp;

### 2. Example

&nbsp;

The area surrounding Alboinplatz in Tempelhof-Schönefeld offers a relevant example of this code's application because it encompasses two over-populated voting districts.

&nbsp;

<p align="center">
![](Alboinplatz.png){ width=60% }
</p>

&nbsp;

#### 2.1 Context

&nbsp;

There are 6 districts and 39 blocs in the subset of data that was selected for this example.

<p align="center">
![](Tabelle2.png){ width=60% }
</p>

Two of these voting districts (1468 and 1498) are overpopulated. These are represented by the darker shades of blue in the following graph.

<p align="center">
![](Tabelle4.png){ width=70% }
</p>

The example below consists in relocating one of the blocs located in one of these overpopulated districts within an adjacent, non-overpopulated district.

&nbsp;

#### 2.2 Content of Dataset

&nbsp;

Let's focus on **bloc number 068108** in **voting district 1468**. It is displayed in yellow in the figure below.

<p align="center">
![](Tabelle5.png){ width=70% }
</p>

Since this bloc is located in an overpopulated district (Wahlbezirk_Uebervoelkert column is equal to 1), we want to know to which alternative voting district this bloc could be switched to in order to reduce the number of inhabitants in its initial district.  

&nbsp;


```r
# Identifying row number associated with bloc 068108
idx <- which(myData$Block_Nummer=="68108")

myData[idx,c(2,4,7)]
```

```
##     Block_Nummer Wahlbezirk_Nummer Wahlbezirk_Uebervoelkert
## 407        68108              1468                        1
```

&nbsp;

This bloc is adjacent to seven other blocs (068101, 068102, 068103, 068107, 068109, 068113 and 068114).

&nbsp;



```r
myData[idx,8:14]
```

```
##     Block_Nachbar_1 Block_Nachbar_2 Block_Nachbar_3 Block_Nachbar_4
## 407           68101           68102           68103           68107
##     Block_Nachbar_5 Block_Nachbar_6 Block_Nachbar_7
## 407           68109           68113           68114
```

&nbsp;

Each of these adjacent blocs is itself associated with a voting district (1468, 1490 or 1498). We can thus see that some of them are located in the same district as our bloc of interest (1468).

&nbsp;



```r
myData[idx,21:26]
```

```
##     Block_Nachbar_1_Wahlbezirk Block_Nachbar_2_Wahlbezirk
## 407                       1468                       1468
##     Block_Nachbar_3_Wahlbezirk Block_Nachbar_4_Wahlbezirk
## 407                       1490                       1468
##     Block_Nachbar_5_Wahlbezirk Block_Nachbar_6_Wahlbezirk
## 407                       1490                       1498
```

&nbsp;

Finally, we can see that the one and only optimization suggestion for this specific bloc is to be transferred from voting district 1468 to voting district 1490. 

&nbsp;


```r
myData$Optimized_Wahlbezirk_1[idx]
```

```
## [1] 1490
```

&nbsp;

The following section displays the logical steps leading to this suggestion within the code.

&nbsp;

#### 2.3 Visual Representation of Selection Process

&nbsp;

Let's go back to our bloc of interest, **bloc number 068108** (displayed in yellow in the figure below), located in **voting district 1468**.  The code identifies the seven blocs adjacent to this bloc regardless of their respective voting district---that is to say, all blocs whose boundaries are located 80 meters or less from bloc number 068108's boundaries. These adjacent blocs are depicted in blue in the figure below.

<p align="center">
![](Tabelle9.png){width=70%}
</p>

However, some of these adjacent blocs are located within the same voting district as bloc number 068108, that is, in voting district 1468. These blocs are depicted in red in the figure below. Since they can't be used to propose a new voting district for bloc 068108, they are excluded from the following steps. Valid blocs, depicted in green, make it to the next step.


<p align="center">
![](Tabelle8.png){width=70%}
</p>

We are left with four blocs located in two different voting districts (1498 and 1490). These are presented in blue in the figure below.

<p align="center">
![](Tabelle6.png){width=70%}
</p>

Two of these blocs are located in a voting district which is itself overpopulated (voting district number 1498). These blocs are depicted in red in the figure below. We are left with two blocs from district 1490, which was the optimization suggestion for bloc number 068108 in our dataset. 

&nbsp;


```r
myData$Optimized_Wahlbezirk_1[idx]
```

```
## [1] 1490
```

<p align="center">
![](Tabelle7.png){width=70%}
</p>

Thus, we could consider redrawing the borders of voting district 1490 to include bloc number 068108.

&nbsp;

### 3. Conclusion

&nbsp;

Here is a list of the pros and cons of this method.

&nbsp;


**Pros**:

* This dataset can be used to identify alternative district assignments (one or more) to blocs located in overpopulated districts. 
* The threshold to assess adjacency can be manually changed if desired (more or less than 80 meters). 
* The method used to evaluate adjacency takes into account physical barriers such as large roads or rivers within each district. That is to say, since we take into account the distance between blocs in order to assess potential alternatives districts, blocs won't be assigned to seamingly nearby districts whose inhabitants (i.e. blocs) are actually located far away. 
* Because it focuses on blocs located at the border of overpopulated districts, this method offers marginal modifications to the current map.

&nbsp;

**Cons**: 

* All possible alternative assignments can't be simultaneously implemented. Indeed, this would likely result in the under-population of initially over-populated district. The next step is to select which of these proposed changes should be made.
* Once this is done, we need to make sure that switches do not result in the overpopulation of newly assigned districts.
* An important criterion is that new districts are reasonably compact. As of now, the method is only based on adjacency and thus can suggest redistricting blocs to closeby voting districts suboptimally located with regards to this criterion (ex.: diagonally to the original bloc).


&nbsp;

### 4. Appendix

&nbsp;

All suggested switches are displayed in tables below for reference. Here are also maps displaying bloc numbers, district numbers and overpopulated districts in Tempelhof-Schönefeld.


<p align="center">
![](simpleMap4.png)
</p>

<p align="center">
![](simpleMap3.png)
</p>

<p align="center">
![](simpleMap10.png)
</p>

*(Please note that voting district 1473 has exactly 2500 inhabitants, and is therefore not considered as overpopulated in the present analysis)*

&nbsp;

#### 4.1 First Optimization Suggestions

&nbsp;


```r
# Displaying all matches
idx <- which(!is.na(myData$Optimized_Wahlbezirk_1))
myData[idx,c(2,4,34)]
```

```
##      Block_Nummer Wahlbezirk_Nummer Optimized_Wahlbezirk_1
## 15          54133              1506                   1505
## 16          54134              1506                   1460
## 47          54156              1506                   1505
## 70          54222              1479                   1459
## 101         55072              1477                   1495
## 102         55073              1477                   1495
## 108         55079              1477                   1470
## 110         55103              1477                   1505
## 119         55118              1477                   1427
## 127         55619              1477                   1470
## 168         57135              1449                   1485
## 170         57137              1449                   1485
## 171         57157              1506                   1481
## 172         57159              1506                   1481
## 175         57165              1449                   1481
## 176         57166              1449                   1481
## 177         57183              1479                   1459
## 178         57184              1479                   1459
## 193         57621              1449                   1481
## 197         58182              1479                   1459
## 198         58187              1479                   1473
## 209         58907              1449                   1485
## 231         60334              1430                   1476
## 232         60335              1430                   1476
## 241         60348              1430                   1440
## 242         60349              1430                   1433
## 243         60350              1430                   1433
## 398         68097              1468                   1480
## 400         68101              1468                   1455
## 401         68102              1468                   1480
## 405         68106              1468                   1455
## 407         68108              1468                   1490
## 412         68113              1498                   1455
## 421         68125              1498                   1465
## 422         68126              1498                   1465
## 423         68127              1498                   1475
## 424         68128              1498                   1475
## 433         68146              1492                   1461
## 435         68168              1492                   1504
## 436         68169              1492                   1504
## 446         68615              1492                   1461
## 447         68629              1492                   1461
## 453         68622              1498                   1455
## 457         68628              1492                   1484
## 475         69170              1492                   1461
## 482         69189              1487                   1466
## 496         70005              1482                   1456
## 497         70006              1482                   1456
## 499         70008              1482                   1456
## 503         70016              1482                   1465
## 536         70076              1445                   1500
## 537         70077              1445                   1500
## 540         70080              1445                   1483
## 560         70122              1501                   1464
## 581         70145              1410                   1464
## 584         70150              1410                   1464
## 585         70151              1410                   1464
## 586         70152              1410                   1415
## 588         70154              1410                   1415
## 604         70617              1482                   1450
## 605         70618              1482                   1465
## 616         70628              1501                   1483
## 619         70632              1410                   1464
## 637         71102              1445                   1483
## 640         71611              1445                   1500
## 641         71612              1445                   1500
## 642         71613              1445                   1500
## 644         72031              1501                   1415
## 645         72032              1501                   1415
## 646         72033              1501                   1415
## 651         72601              1501                   1415
## 659         72639              1410                   1415
## 660         72908              1501                   1402
## 728         73618              1419                   1411
## 733         73624              1389                   1401
## 734         74021              1414                   1405
## 741         73640              1393                   1407
## 746         73644              1393                   1411
## 757         73657              1393                   1411
## 758         74001              1410                   1415
## 760         74003              1410                   1415
## 761         74004              1410                   1405
## 766         74009              1414                   1415
## 767         74010              1414                   1405
## 787         74044              1414                   1405
## 807         74067              1414                   1388
## 808         74068              1414                   1388
## 809         74069              1414                   1388
## 810         74070              1414                   1405
## 834         74096              1409                   1388
## 835         74098              1409                   1388
## 836         74102              1414                   1403
## 841         74109              1409                   1388
## 842         74110              1409                   1388
## 995         74603              1414                   1388
## 1004        74617              1409                   1388
## 1005        74618              1409                   1388
## 1014        74628              1414                   1388
## 1015        74629              1414                   1388
## 1022        74642              1409                   1418
```

&nbsp;


#### 4.2 Second Optimization Suggestions

&nbsp;


```r
# Displaying all matches
idx <- which(!is.na(myData$Optimized_Wahlbezirk_2))
myData[idx,c(2,4,35)]
```

```
##      Block_Nummer Wahlbezirk_Nummer Optimized_Wahlbezirk_2
## 15          54133              1506                   1451
## 16          54134              1506                   1481
## 47          54156              1506                   1481
## 70          54222              1479                   1473
## 101         55072              1477                   1470
## 102         55073              1477                   1470
## 108         55079              1477                   1451
## 110         55103              1477                   1470
## 119         55118              1477                   1497
## 127         55619              1477                   1427
## 168         57135              1449                   1481
## 175         57165              1449                   1447
## 176         57166              1449                   1447
## 177         57183              1479                   1481
## 178         57184              1479                   1481
## 193         57621              1449                   1485
## 197         58182              1479                   1473
## 209         58907              1449                   1447
## 231         60334              1430                   1440
## 241         60348              1430                   1441
## 398         68097              1468                   1458
## 400         68101              1468                   1458
## 401         68102              1468                   1458
## 413         68114              1498                   1490
## 424         68128              1498                   1465
## 453         68622              1498                   1465
## 457         68628              1492                   1480
## 475         69170              1492                   1504
## 494         70001              1482                   1475
## 496         70005              1482                   1450
## 497         70006              1482                   1474
## 499         70008              1482                   1496
## 503         70016              1482                   1450
## 537         70077              1445                   1483
## 572         70134              1410                   1464
## 582         70147              1410                   1415
## 605         70618              1482                   1456
## 616         70628              1501                   1453
## 647         72034              1501                   1415
## 660         72908              1501                   1478
## 728         73618              1419                   1392
## 731         73622              1389                   1401
## 741         73640              1393                   1397
## 760         74003              1410                   1405
## 766         74009              1414                   1405
## 787         74044              1414                   1388
## 810         74070              1414                   1388
## 835         74098              1409                   1418
## 836         74102              1414                   1408
## 841         74109              1409                   1400
## 842         74110              1409                   1400
## 995         74603              1414                   1413
## 1005        74618              1409                   1418
## 1022        74642              1409                   1406
```

&nbsp;


#### 4.3 Third Optimization Suggestions

&nbsp;


```r
# Displaying all matches
idx <- which(!is.na(myData$Optimized_Wahlbezirk_3))
myData[idx,c(2,4,36)]
```

```
##     Block_Nummer Wahlbezirk_Nummer Optimized_Wahlbezirk_3
## 15         54133              1506                   1460
## 101        55072              1477                   1488
## 102        55073              1477                   1451
## 110        55103              1477                   1451
## 119        55118              1477                   1505
## 193        57621              1449                   1447
## 209        58907              1449                   1472
## 241        60348              1430                   1433
## 398        68097              1468                   1490
## 401        68102              1468                   1490
## 412        68113              1498                   1465
## 413        68114              1498                   1475
## 424        68128              1498                   1456
## 457        68628              1492                   1461
## 494        70001              1482                   1456
## 496        70005              1482                   1474
## 499        70008              1482                   1474
## 503        70016              1482                   1500
## 560        70122              1501                   1453
## 605        70618              1482                   1450
## 616        70628              1501                   1491
## 660        72908              1501                   1407
## 728        73618              1419                   1396
## 733        73624              1389                   1397
## 842        74110              1409                   1406
## 995        74603              1414                   1394
```

&nbsp;

#### 4.4 Fourth Optimization Suggestions

&nbsp;


```r
# Displaying all matches
idx <- which(!is.na(myData$Optimized_Wahlbezirk_4))
myData[idx,c(2,4,37)]
```

```
##     Block_Nummer Wahlbezirk_Nummer Optimized_Wahlbezirk_4
## 457        68628              1492                   1504
## 560        70122              1501                   1483
## 605        70618              1482                   1474
## 757        73657              1393                   1397
## 995        74603              1414                   1408
```



&nbsp;

#### 4.5 Fifth Optimization Suggestion

&nbsp;


```r
# Displaying all matches
idx <- which(!is.na(myData$Optimized_Wahlbezirk_5))
myData[idx,c(2,4,38)]
```

```
##     Block_Nummer Wahlbezirk_Nummer Optimized_Wahlbezirk_5
## 728        73618              1419                   1401
```


&nbsp;


&nbsp;

&nbsp;

&nbsp;

