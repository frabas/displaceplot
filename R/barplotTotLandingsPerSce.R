

#' Making an overview barplot for total landings per scenario for a selected set of stocks
#'
#' This function processes further the lst_loglike objects
#'
#' @param fname First name
#' @param lname Last name
#' @export
#' @examples
#'
#' \dontrun{
#' general <- setGeneralOverallVariable (pathToRawInputs =file.path("C:", "Users", "fbas", 
#'                                                 "Documents", "GitHub", paste0("DISPLACE_input_gis_", 
#'                                                  "DanishFleet")),
#'                                       pathToDisplaceInputs = file.path("C:", "Users", "fbas", 
#'                                                 "Documents", "GitHub", paste0("DISPLACE_input_", "DanishFleet")),
#'                                       pathToOutputs =file.path("C:","DISPLACE_outputs"),
#'                                       caseStudy="DanishFleet",
#'                                       iGraph=41,
#'                                       iYear="2015",
#'                                       iCountry="DEN",
#'                                       nbPops=39,
#'                                       nbSzgroup=14,
#'                                       theScenarios= c("svana_baseline",
#'                                                       "svana_sub1mx20",
#'                                                       "svana_sub4mx20",
#'                                                       "svana_sub4mx5ns20bt",
#'                                                       "svana_sub4mx20ns5bt",
#'                                                       "svana_sub4mx5ns5bt" ),
#'                                       nbSimus=20,
#'                                       useSQLite=FALSE    
#'                                       )
#'
#'
#'
#'
#'
#'   loadLoglikeFiles(general=general, use_port_info=FALSE)
#'
#'
#'
#'   barplotTotLandingsPerSce (general=general,
#'                                    selected="_selected_set1_",
#'                                    type_of_column="pop",
#'                                    selected_pops=c(0:38),
#'                                    group1= c(0, 1, 2, 3, 11, 23, 24, 26, 30, 31, 32),
#'                                    selected_scenarios=general$namefolderoutput,
#'                                    scenarios_names=general$namefolderoutput,
#'                                    nby=5, firsty="2015", lasty="2019",
#'                                    a_width=3500, a_height=2000, black_and_white = FALSE, ylims = c(0,305))
#'
#'  Note that if black_and_white at true then the barplot is split into 2 groups
#' (first group is group1 stocks, second is all other ones)
#'
#'
#' barplotTotLandingsPerSce (general=general,
#'                                    type_of_column="disc",
#'                                    selected="_selected_set1_",
#'                                    selected_pops=c(0:38),
#'                                    group1= c(0, 1, 2, 3, 11, 23, 24, 26, 30, 31, 32),
#'                                    selected_scenarios=general$namefolderoutput,
#'                                    scenarios_names=general$namefolderoutput,
#'                                    nby=5, firsty="2015", lasty="2019",
#'                                    a_width=3500, a_height=2000, black_and_white = FALSE, ylims = c(0,305))
#'
#'
#'   }




barplotTotLandingsPerSce <- function(general=general,
                                    type_of_column="pop", # or "disc"
                                    selected="_selected_set1_",
                                    selected_pops=c(0, 1, 2, 3, 11, 23, 24, 26, 30, 31, 32),
                                    group1= c(0, 1, 2, 3, 11, 23, 24, 26, 30, 31, 32),
                                    selected_scenarios=general$namefolderoutput,
                                    scenarios_names=general$namefolderoutput,
                                    nby=5, firsty="2015", lasty="2019",
                                    a_width=3500, a_height=2000, black_and_white = TRUE, ylims = c(0,10)){



   c.listquote <- function (...)
   {
    args <- as.list(match.call()[-1])
    lstquote <- list(as.symbol("list"))
    for (i in args) {
        if (class(i) == "name" || (class(i) == "call" && i[[1]] !=
            "list")) {
            i <- eval(substitute(i), sys.frame(sys.parent()))
        }
        if (class(i) == "call" && i[[1]] == "list") {
            lstquote <- c(lstquote, as.list(i)[-1])
        }
        else if (class(i) == "character") {
            for (chr in i) {
                lstquote <- c(lstquote, list(parse(text = chr)[[1]]))
            }
        }
        else stop(paste("[", deparse(substitute(i)), "] Unknown class [",
            class(i), "] or is not a list()", sep = ""))
    }
    return(as.call(lstquote))
   }


#------------------------
reshape_per_pop_for_one_sce <- function(lst_loglike1=lst_loglike,
                                        namesimu=paste("simu", 1:5, sep=''),
                                        selected_pops=explicit_pops,
                                        type_of_column="pop",
                                        nby=5){

    
   # filter lst_loglike to trash away the failed (i.e. non-complete) simus:
   # detection according to the number of rows...
   dd                <- table(unlist(lapply(lst_loglike1, nrow)))
   namesimu          <- names(unlist(lapply(lst_loglike1, function(x) nrow(x)>=nby)))
   print(namesimu)
   # subset
   refsimu     <- namesimu[1]
   lst_loglike <- lst_loglike1[ namesimu ]

   # explicit pops??
   pops <- selected_pops
   idx_col <- grep(type_of_column, colnames(lst_loglike[[refsimu]]))


  # check
  #print("check if same numbers of row across the simus")
  #print( lapply(lst_loglike1[ namesimu ], nrow) )


  # first, reshape for pop 
  #browser()
  for (i in 1:length(lst_loglike)){
   lst_loglike[[ i ]] <- lst_loglike[[ i ]][, colnames(lst_loglike[[ i ]]) %in% c("year", paste0(type_of_column,".",pops)) ]    [1:nby, (1:(length(selected_pops)+1))]

   lst_loglike[[ i ]] <- cbind( reshape(lst_loglike[[ i ]], idvar="year", varying=list(2:ncol(lst_loglike[[ i ]])),
        v.names=type_of_column, direction="long"), a_pop = rep(pops, each=nrow(lst_loglike[[ i ]])) )
  }
  # reshape...
  res <- NULL
  for(pop in pops){  # for each (explicit) pop
     mat.sim1 <- matrix(unlist(lapply(lst_loglike[ namesimu ], function(x){
                       res <- try(x[x$a_pop==pop, type_of_column], silent=TRUE); if(class(res)=="try-error") res <- rep(NA, ncol(lst_loglike[[refsimu]])); res
                       })), nrow=nrow(lst_loglike[[refsimu]][lst_loglike[[refsimu]]$a_pop==pop,]) , byrow=FALSE)
     colnames(mat.sim1) <- c(paste(type_of_column,"_", namesimu , sep=''))



     mat.sim1 <- replace(mat.sim1, is.na(mat.sim1), 0)

     mat.sim1 <- cbind.data.frame(lst_loglike[[refsimu]] [ lst_loglike[[1]]$a_pop==pop, c("year","a_pop") ], mat.sim1)

     if(!is.null(res)) res <- rbind.data.frame(res, mat.sim1) else res <- mat.sim1

   }


   res <- res[!is.na(res$year),]

   # get the median....
   res <- cbind (res,
                 median=apply(res[,-c(1,2)], 1, quantile, probs=0.5),
                 mean= apply(res[,-c(1,2)], 1, mean)
                 )

 return(res)
 }





### 1- calls for reshaping the lst_popdyn1----------------
count <- 0
for (sce in selected_scenarios){
       count <- count+1

        lst_loglike <- get(paste("lst_loglike_agg_weight", selected, sce, sep=''), env=.GlobalEnv)

       print(sce)
       # aggregate landings weight PER YEAR
       for (i in 1:length(lst_loglike)){

         library(data.table)
         loglike       <- lst_loglike[[i]] # input
         if(selected=="_met_") loglike <- loglike[loglike$metier==met,]
         loglike$year  <- unlist(lapply(strsplit(as.character(loglike$year.month), split="\\."), function(x) x[1]))
         nm            <- colnames(loglike)
         idx.col       <- grep(paste0(type_of_column,'.'), nm) # 40: DEBUG
         DT            <- data.table(loglike)
         eq1           <- c.listquote( paste ("sum(",nm[idx.col],",na.rm=TRUE)",sep="") )
         loglike.agg   <- DT[,eval(eq1),by=list(year)]
         loglike.agg   <- data.frame( loglike.agg)
         colnames(loglike.agg) <- c("year", paste(paste0(type_of_column,'.'), 0:(general$nbpops-1), sep=''))
         loglike.agg   <- loglike.agg[order(loglike.agg$year),] # order
         lst_loglike[[i]] <- loglike.agg # output
       }

       # keep complete simu i.e. 5 years
       lst_loglike <- lst_loglike [ names(lst_loglike) [lapply(lst_loglike, nrow)>=nby] ]

       loglike_reshaped <- reshape_per_pop_for_one_sce(
                                   lst_loglike1=lst_loglike,
                                   namesimu=general$namesimu[[sce]],
                                   selected_pops=selected_pops,
                                   type_of_column=type_of_column,
                                   nby=nby)
       assign(paste("loglike_", sce, sep=''), loglike_reshaped)
       }



 ### the code for the plot
 all_sces_first_y  <- data.frame(NULL)
 all_sces_last_y   <- data.frame(NULL)
 count    <- 0
 for (sce in selected_scenarios){
   count <- count+1

   loglike <- get(paste("loglike_", sce, sep=''))


   loglike_last_tstep   <- loglike[loglike$year %in%  lasty ,]
   loglike_first_tstep  <- loglike[loglike$year %in%  firsty ,]
   pop_names            <-  read.table(file.path(general$main.path.ibm, paste("pop_names_", general$namefolderinput, ".txt", sep='')), header=TRUE)
   if(count==1) group1               <-  as.character(pop_names[ pop_names[,1] %in%   group1 ,2])


   loglike_last_tstep$a_pop          <- factor(loglike_last_tstep$a_pop)
   levels(loglike_last_tstep$a_pop)  <- pop_names[ pop_names[,1] %in%   levels(loglike_last_tstep$a_pop) ,2]
   loglike_first_tstep$a_pop         <- factor(loglike_first_tstep$a_pop)
   levels(loglike_first_tstep$a_pop) <- pop_names[ pop_names[,1] %in%   levels(loglike_first_tstep$a_pop) ,2]

   if(count==1)  all_sces_first_y <- cbind.data.frame(a_pop=as.character(loglike_first_tstep[,"a_pop"]))
   all_sces_first_y <- cbind.data.frame(all_sces_first_y, loglike_first_tstep[,"mean"])
   colnames(all_sces_first_y)[ncol(all_sces_first_y)] <- scenarios_names[count]

   if(count==1)  all_sces_last_y <- cbind.data.frame(a_pop=as.character(loglike_last_tstep[,"a_pop"]))
   all_sces_last_y <- cbind.data.frame(all_sces_last_y, loglike_last_tstep[,"mean"])
   colnames(all_sces_last_y)[ncol(all_sces_last_y)] <- scenarios_names[count]
  } # end sce



  

    if(black_and_white){
      # split into two groups...
      levels(all_sces_first_y$a_pop) [levels(all_sces_first_y$a_pop) %in% group1] <- "GROUP1"
      levels(all_sces_first_y$a_pop) [!levels(all_sces_first_y$a_pop) %in% c("GROUP1",group1)] <- "GROUP2"

      levels(all_sces_last_y$a_pop) [levels(all_sces_last_y$a_pop) %in% group1] <- "GROUP1"
      levels(all_sces_last_y$a_pop) [!levels(all_sces_last_y$a_pop) %in% c("GROUP1",group1)] <- "GROUP2"

     all_sces_first_y <- aggregate(all_sces_first_y[,-1], list(all_sces_first_y[,1]), sum)
      colnames(all_sces_first_y)[1] <- "a_pop"
      all_sces_last_y <- aggregate(all_sces_last_y[,-1], list(all_sces_last_y[,1]), sum)
      colnames(all_sces_last_y)[1]  <- "a_pop"

      # black and white version
      some_colors <- c(grey(0.2),grey(0.5),grey(1))
      the_density <- rep(500, length(some_colors))
    } else{

      # reorder stocks
      all_sces_first_y$a_pop <- factor(all_sces_first_y$a_pop)
      #species_order <- c(
      #                 grep("nsea", all_sces_first_y$a_pop),
      #                 grep("kask",  all_sces_first_y$a_pop ),
      #                  grep("kat", all_sces_first_y$a_pop),
      #                   grep("3a22", all_sces_first_y$a_pop ),
      #                   grep("3a2223", all_sces_first_y$a_pop ),
      #                   grep("2224", all_sces_first_y$a_pop),
      #                    grep("2532",  all_sces_first_y$a_pop ),
      #                     grep("2232", all_sces_first_y$a_pop )
      #                     )
      #species_order <- unique(species_order)

      #all_sces_first_y <- all_sces_first_y[rev(species_order),]
      #all_sces_last_y <- all_sces_last_y[rev(species_order),]
    }


   some_colors <- c("#a6cee3","#1f78b4","red","#b2df8a","green","#33a02c", "#fb9a99",grey(0.5),"#fdbf6f","#ff7f00","#cab2d6","#6a3d9a","#ffff99","#b15928", "black")
   the_density <- rep(500, length(some_colors))



   ##-------A PLOT-----------
    graphics.off()
   if(type_of_column=="pop") namefileplot <- paste("landings_per_stock_per_scenario", selected, sep='')
   if(type_of_column=="disc") namefileplot <- paste("discards_per_stock_per_scenario", selected, sep='')

    tiff(file=file.path(general$main.path, general$namefolderinput, paste(namefileplot, ".tiff", sep="")),
                                  width = a_width, height = a_height,   compression="lzw",
                                   units = "px", pointsize = 12,  res=300)
   par(mfrow=c(1,2))
   par(mar=c(7,3,2,2))
   par(oma=c(3,2,1,1))


   rownames(all_sces_first_y) <- all_sces_first_y[,1]
   rownames(all_sces_last_y) <- all_sces_last_y[,1]

   mp_first_y <-  barplot(as.matrix(all_sces_first_y[,-1])/1e6, las=2,  ylim=ylims, xlab="", ylab="",
                          col =some_colors , density=the_density, legend=TRUE, axes = FALSE,axisnames = FALSE,
                         args.legend = list(x = "topright", bty = "n", ncol=2, cex=0.9))
   text(mp_first_y, par("usr")[3], labels = colnames(all_sces_first_y[-1]), srt = 45, adj = 1, xpd = TRUE, cex = 1)
   axis(2, las=2)
   title ("First year", adj=0)

   mtext("Scenario", 1, line=0, cex=1.5, outer=TRUE)
   if(type_of_column=="pop") mtext(side=2, "Annual landings [*000 tons]", line=0, cex=1., outer=TRUE)
   if(type_of_column=="disc") mtext(side=2, "Annual discards [*000 tons]", line=0, cex=1., outer=TRUE)

    mp_last_y <-  barplot(as.matrix(all_sces_last_y[,-1])/1e6, las=2, , ylim=ylims, xlab="", ylab="",
                         col =some_colors , density=the_density,  legend=FALSE, axes = FALSE,axisnames = FALSE,
                        args.legend = list(x = "topright", bty = "n", ncol=2))
   text(mp_last_y, par("usr")[3], labels = colnames(all_sces_last_y[-1]), srt = 45, adj = 1, xpd = TRUE, cex = 1)
   axis(2, las=2)
   title ("Last year", adj=0)

   mtext("Scenario", 1, line=0, cex=1.5, outer=TRUE)
   if(type_of_column=="pop") mtext(side=2,"Annual landings [*000 tons]",line=0, cex=1., outer=TRUE)
   if(type_of_column=="disc") mtext(side=2,"Annual discards [*000 tons]",line=0, cex=1., outer=TRUE)

   dev.off()


return()
}


