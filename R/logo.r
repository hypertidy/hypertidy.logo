## thanks @hrbrmstr  https://rud.is/b/2016/02/11/plot-the-new-svg-r-logo-with-ggplot2/

library(sp)
library(maptools)
library(rgeos)
library(ggplot2)
library(ggthemes)

r_wkt_gist_file <- "https://gist.githubusercontent.com/hrbrmstr/07d0ccf14c2ff109f55a/raw/db274a39b8f024468f8550d7aeaabb83c576f7ef/rlogo.wkt"
if (!file.exists("rlogo.wkt")) download.file(r_wkt_gist_file, "rlogo.wkt")
rlogo <- readWKT(paste0(readLines("rlogo.wkt", warn=FALSE)))

rlogo_shp <- SpatialPolygonsDataFrame(rlogo, data.frame(poly=c("halo", "r")))
library(dplyr)
tables <- spbabel:::mtableFrom2(rlogo_shp[2,]@data, spbabel::sptable(rlogo_shp[2, ]))
path2seg <- function(x) {
  head(suppressWarnings(matrix(x, nrow = length(x) + 1, ncol = 2, byrow = FALSE)), -2L)
}

tables$v$countingIndex <- seq(nrow(tables$v))
nonuq <- inner_join(tables$bXv, tables$v)
#> Joining, by = "vertex_"
library(RTriangle)
ps <- pslg(P = as.matrix(tables$v[, c("x_", "y_")]), S = do.call(rbind, lapply(split(nonuq, nonuq$branch_), function(x) path2seg(x$countingIndex))))

## TODO: robust hole filtering
## I happen to know this will work, but we can use triangle filtering post hoc too, or use a known inner centroid
library(spdplyr)
ps$H <- spbabel::sptable(rlogo_shp[2, ]) %>% filter(!island_) %>% 
  group_by(branch_) %>% summarize(xm = mean(x_), ym = mean(y_)) %>% 
  select(xm, ym) %>% 
  as.matrix()
tr <- triangulate(ps, a = 200)
png(width = 420, height = 420)
par(mar = rep(0, 4))
plot(tr$VP, type = "p", pch = 19, cex = 0.5, asp = 1,  axes = FALSE, xlab = "", ylab = "", xaxs = "i", yaxs = "i")
#apply(tr$E[tr$EB < 1, ], 1, function(x) lines(tr$P[x, ], col = scales::alpha("grey", 0.75)))
dev.off()
