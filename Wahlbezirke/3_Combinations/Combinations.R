#### 1. Preamble ####

### 1.1 Loading libraries

library(rgdal) # For readOGR()
library(spdep) # For poly2nb()
library(adjclust) # For adjClust()
library(tictoc) # For tic() and toc()
library(combinat) # For combn()
library(gtools) # For permutations() and combinations()

### 1.2 Loading datasets

demo_file <- readOGR("/Users/evelynebrie/Dropbox/CityLab/Projects/Wahlbezirke/Data/Demo_Final")
vote_file <- readOGR("/Users/evelynebrie/Dropbox/CityLab/Projects/Wahlbezirke/Data/Vote_Final")
vote_file <- vote_file[vote_file$BEZNAME=="Tempelhof-Schneberg",]

demo_file$ID_ajd <- NA
demo_file$ID_ajd <- seq(1,1032)

### 1.3 Creating adjacency matrix

adjlist_blocs <- poly2nb(demo_file, row.names = NULL, snap=0.0005,
                         queen=TRUE, useC=TRUE, foundInBox=NULL)

### 1.4 Simulate all combinations of blocs and districts 

#### 1.4.1 Using adjclust package

#mat_adjlist_blocs <- as.matrix(adjlist_blocs)
#h <- 3
#fit <- adjClust(mat_adjlist_blocs, "similarity", h)
#plot(fit)

#### 1.4.2 Using combn

combinations <- function(group_size, N) {
  apply(combn(N, m = group_size), 2, paste0, collapse = ",")
}

all_combinations <- function(N) {
  lapply(seq_len(N), combinations, N = N)
}

tic()
combis <- all_combinations(1032)
toc()

# 1.4.3 Using combinat

#permn(3)
#x <- combn(100, 5)
#x <- as.data.frame(x)
#x

# 1.4.5 Using gtools package

#x <- seq(1,1032)
#permutations(n=1032,r=1,v=x,set=F,repeats.allowed = T)
#combinations(n=1032,r=1,v=x)

# 1.4.6 Using expand.grid()

#n <- 14
#l <- rep(list(0:1), n)
#expand.grid(l)





