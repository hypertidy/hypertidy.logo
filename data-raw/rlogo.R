## thanks @hrbrmstr  https://rud.is/b/2016/02/11/plot-the-new-svg-r-logo-with-ggplot2/

library(sp)
library(maptools)
library(rgeos)
library(ggplot2)

r_wkt_gist_file <- "https://gist.githubusercontent.com/hrbrmstr/07d0ccf14c2ff109f55a/raw/db274a39b8f024468f8550d7aeaabb83c576f7ef/rlogo.wkt"
if (!file.exists("rlogo.wkt")) download.file(r_wkt_gist_file, "rlogo.wkt")
sp <- readWKT(paste0(readLines("rlogo.wkt", warn=FALSE)))

## easier these days
rlogo <- anglr::DEL0(sp[2, ], max_area = 200)
usethis::use_data(sp, rlogo, overwrite = TRUE)


## to get the logo plot we take centroids of the triangles
xy <- as.matrix(silicate::sc_vertex(rlogo))
tri <- as.matrix(do.call(rbind, silicate::sc_object(rlogo)$topology_)[c(".vx0", ".vx1", ".vx2")])
pts <- cbind(apply(matrix(xy[t(tri), 1L], 3L), 2, mean), apply(matrix(xy[t(tri), 2L], 3L), 2, mean))
plot(pts, pch = ".")
