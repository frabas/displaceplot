


#' This function produces a wealth of raw graphics for interpretation purpose
#'
#' This function produces a wealth of raw graphics in a output hierarchy of folders to compare scenarios vs. baseline sce
#'
#' @param fname First name
#' @param lname Last name
#' @export
#' @examples
#' 
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
#'  load( file=file.path(general$main.path, general$namefolderinput,
#'                     paste("selected_vessels.RData", sep='')) )
#'
#'   if(FALSE){
#'     aggregratLoglikeFiles(general=general, what="weight",
#'             explicit_pops=c(0, 1, 2, 3, 11, 23, 24, 26, 30, 31, 32),
#'             implicit_pops=c (4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 25, 27, 28, 29, 33, 34, 35, 36, 37, 38),
#'             selected_vessels_set1=selected_vessels_set_1,
#'             selected_vessels_set2=selected_vessels_set_2,
#'             selected_vessels_set3=selected_vessels_set_3)
#'   } else{
#'     loadLoglikeFiles (general, use_port_info=FALSE)
#'   }
#'
#'  callCompareSimSimPlots (general,
#'                        the_baseline="svana_baseline",
#'                        explicit_pops=explicit_pops,
#'                        selected= "_selected_set1_",
#'                        selected_vessels=selected_set1,
#'                        years_span=2015:2019,
#'                        per_pop=FALSE,
#'                        per_vessel=TRUE)
#'
#'   require(plotrix)
#'   stressBarplot (general=general,
#'                          the_baseline="svana_baseline",
#'                          selected_vessels=selected_vessels_set_1,
#'                          by_class=NULL,
#'                          a_width=1500, a_height=3500)
#'   }





compareSimSimPlots <- function (lst_loglike_agg_1, lst_loglike_agg_2, years_span=2015:2019, ...,  explicit_pops=explicit_pops, plot_obs=TRUE,
                                       idx.sim=list(sce1=c(1), sce2=c(1)), combined_name=c("baseline_vs_implicit"),
                                         a.comment="", what="per_vessel", what2="weight", count=0,
                                          a.xlab="", a.ylab="", a.unit=1, do_mtext=FALSE)  {

     lstargs <- list(...)


    ## CAUTION: DEBUG to get the same number of rows......
    tstep                               <- paste(rep(years_span, each=12), c("01","02","03","04","05","06","07","08","09","10","11","12"), sep=".")
    names.for.change                    <- names(lst_loglike_agg_1)[!names(lst_loglike_agg_1)%in%"obs"]
    lst_loglike_agg_1[names.for.change] <- lapply(lst_loglike_agg_1[names.for.change], function(x) {merge(data.frame(year.month=tstep), x, all.x=TRUE)})
    lst_loglike_agg_2                   <- lapply(lst_loglike_agg_2, function(x) {merge(data.frame(year.month=tstep), x, all.x=TRUE)})


    # filter lst_popdyn to trash away the failed (i.e. non-complete) simus:
    # detection according to the number of rows...
    # for 1.
    dd                <- table(unlist(lapply(lst_loglike_agg_1, nrow)))
    expected_nb_rows  <- as.numeric(names(dd[dd==max(dd)]))[1] # most common number of rows
    idx               <- unlist(lapply(lst_loglike_agg_1, function(x) nrow(x)==expected_nb_rows))
    namesimu1          <- names(unlist(lapply(lst_loglike_agg_1, function(x) nrow(x)==expected_nb_rows)))[idx]
    lst_loglike_agg_1 <- lst_loglike_agg_1[namesimu1]
    # for 2.
    dd                <- table(unlist(lapply(lst_loglike_agg_2, nrow)))
    expected_nb_rows  <- as.numeric(names(dd[dd==max(dd)])) [1] # most common number of rows
    idx               <- unlist(lapply(lst_loglike_agg_2, function(x) nrow(x)==expected_nb_rows))
    namesimu2          <- names(unlist(lapply(lst_loglike_agg_2, function(x) nrow(x)==expected_nb_rows)))[idx]
    lst_loglike_agg_2 <- lst_loglike_agg_2[namesimu2]

    if(length(namesimu1)>2 && length(namesimu2)>2){

    # folder creations
    cat("if it still doesn't exist, an output folder is created in ",
                    file.path(general$main.path, general$namefolderinput),"\n")
    dir.create(file.path(general$main.path, general$namefolderinput, combined_name),
                      showWarnings = TRUE, recursive = TRUE, mode = "0777")
    dir.create(file.path(general$main.path, general$namefolderinput, combined_name, 'jpeg_plots'),
                      showWarnings = TRUE, recursive = TRUE, mode = "0777")
    dir.create(file.path(general$main.path, general$namefolderinput, combined_name, 'jpeg_plots', 'per_vessel'),
                      showWarnings = TRUE, recursive = TRUE, mode = "0777")
    dir.create(file.path(general$main.path, general$namefolderinput, combined_name, 'jpeg_plots', 'per_pop'),
                      showWarnings = TRUE, recursive = TRUE, mode = "0777")




    # small adjustements....
     if (what %in% c('per_country')) {
        output.folder <-  file.path(general$main.path, general$namefolderinput, combined_name, 'jpeg_plots')
        segment.names <- colnames( lst_loglike_agg_1[[1]] )[-1]
        outputfile <- file.path(output.folder,
                        paste("loglike_",what2,"_panel",count,"_",gsub("\\.","",a.comment),'.pdf',sep="" ))
        pdf(file = outputfile)
        par(mfrow=c(3,3))
        a.cex.axis <-0.5

         } else{
         if (what %in% c('per_vessel')) {
           output.folder <- file.path(general$main.path, general$namefolderinput, combined_name, 'jpeg_plots', 'per_vessel')
           segment.names <- colnames( lst_loglike_agg_1[[1]] )[-(1:2)]
           outputfile <- file.path(output.folder,
                      paste("loglike_",what2,"_panel",count,"_",gsub("\\.","",a.comment),'.pdf',sep="" ))
           pdf(file = outputfile)
           par(mfrow=c(3,3))
              a.cex.axis <-0.5
           } else{
            if (what %in% c('per_pop')) {
              output.folder <-  file.path(general$main.path, general$namefolderinput, combined_name, 'jpeg_plots', 'per_pop')
              segment.names <-  a.comment
              outputfile <- file.path(output.folder,
                     paste("loglike_",what2,"_panel",count,"_",gsub("\\.","",a.comment),'.pdf',sep="" ))
              pdf(file = outputfile)
              par(mfrow=c(3,3))
              a.cex.axis <-0.5
               }else{
                output.folder <-  file.path(general$main.path, general$namefolderinput, combined_name, 'jpeg_plots')
                segment.names <-  what
                a.cex.axis <-1
                a.comment <- what
                outputfile <- file.path(output.folder,
                     paste("loglike_panel",count,"_",gsub("\\.","",a.comment),'.pdf',sep="" ))
                pdf(file = outputfile)
                par(mfrow=c(1,1))
                par(mar=c(5,5,1,1))

             }
           }
        }


              print(lapply(lst_loglike_agg_1[ namesimu1 ], nrow))  # check if same number of rows between simu!!
              print(lapply(lst_loglike_agg_2[ namesimu2 ], nrow))  # check if same number of rows between simu!!
              refsimu1 <- namesimu1[1]
              refsimu2 <- namesimu2[1]

           # init for pie chart
           segment.names <- c(segment.names, "fcpue_all", "fcpue_explicit", "fcpue_implicit", paste("fcpue_pop", explicit_pops, sep="")  )

           sum_all_months_and_mean_across_runs1 <- matrix(0, nrow=1, ncol=length(segment.names))
           colnames(sum_all_months_and_mean_across_runs1) <- segment.names
           sum_all_months_and_mean_across_runs2 <- matrix(0, nrow=1, ncol=length(segment.names))
           colnames(sum_all_months_and_mean_across_runs2) <- segment.names

           segment.names <- segment.names[!is.na(segment.names)]

           for(seg in segment.names ){  # for each col
              cat (paste(seg, "\n"))

              count <- count +1

              # for sce1
              mat.sim1 <- matrix(unlist(lapply(lst_loglike_agg_1[namesimu1], function(x){
                  res <- try(x[,seg], silent=TRUE)
                  if(seg=="fcpue_all")        res <- x[,'totland']/(x[,'effort']- x[,'cumsteaming'])
                  if(seg=="fcpue_explicit")   res <- x[,'totland_explicit']/(x[,'effort']- x[,'cumsteaming'])
                  if(seg=="fcpue_implicit")   res <- x[,'totland_implicit']/(x[,'effort']- x[,'cumsteaming'])
                  if(length(grep("fcpue_pop", seg))!=0){
                     a_sp <- gsub("fcpue_pop","",seg)
                     res  <- x[,paste('pop.', a_sp, sep="")]/(x[,'effort']- x[,'cumsteaming'])
                     }
                  res
                  })), nrow=nrow(lst_loglike_agg_1[[refsimu1]]), byrow=FALSE)
              colnames(mat.sim1) <- c(paste(seg, namesimu1 , sep=''))

              sum_all_months_and_mean_across_runs1[,seg] <- mean(apply(mat.sim1, 2, function(x) sum (as.numeric(x), na.rm=TRUE)))

              # for sce2
              mat.sim2 <- matrix(unlist(lapply(lst_loglike_agg_2[namesimu2 ], function(x){
                  res <- try(x[,seg], silent=TRUE)
                  if(seg=="fcpue_all")        res <- x[,'totland']/(x[,'effort']- x[,'cumsteaming'])
                  if(seg=="fcpue_explicit")   res <- x[,'totland_explicit']/(x[,'effort']- x[,'cumsteaming'])
                  if(seg=="fcpue_implicit")   res <- x[,'totland_implicit']/(x[,'effort']- x[,'cumsteaming'])
                  if(length(grep("fcpue_pop", seg))!=0){
                     a_sp <- gsub("fcpue_pop","",seg)
                     res  <- x[,paste('pop.', a_sp, sep="")]/(x[,'effort']- x[,'cumsteaming'])
                     }
                  if(class(res)=="try-error") res <- rep(NA, ncol(lst_loglike_agg_2[[refsimu2]]))
                  res
                  })), nrow=nrow(lst_loglike_agg_2[[refsimu2]]), byrow=FALSE)
              colnames(mat.sim2) <- c(paste(seg, namesimu2 , sep=''))

              sum_all_months_and_mean_across_runs2[,seg] <- mean(apply(mat.sim2, 2, function(x) sum (as.numeric(x), na.rm=TRUE)))



             plot(0,0, type='n', axes=FALSE, xlim=c(1,nrow(lst_loglike_agg_1[[refsimu1]])),
                 ylim=c(0, (max(c(mat.sim1,mat.sim2), na.rm=TRUE)/a.unit)*1.2),
                     ylab=a.ylab, xlab=a.xlab)
             if(what=="per_pop") title(paste(seg, lst_loglike_agg_1[[refsimu1]][1,1]))
             if(what=="per_vessel") title(paste(seg))
             if(what=="per_country") title(paste(seg))

             if(do_mtext){
               mtext(side=2 , a.ylab, outer=TRUE, line=-1.2)
               mtext(side=1 , a.xlab, outer=TRUE, line=-1)
               }

             axis(1, labels= lst_loglike_agg_1[[refsimu1]]$year.month,
                           at=1:nrow(lst_loglike_agg_1[[refsimu1]]), las=2, cex.axis=a.cex.axis)
             axis(2, las=2)
             box()

             # polygon 5-95% for simus SCE 1
             mat.sim1 <- replace(mat.sim1, is.na(mat.sim1),0)
             polygon(c(1:nrow(mat.sim1), rev(1:nrow(mat.sim1))  ),
                  c(apply(mat.sim1, 1, quantile, 0.05, na.rm=TRUE)/a.unit,
                    rev(apply(mat.sim1, 1, quantile, 0.95 , na.rm=TRUE)/  a.unit)) ,
              col=  rgb(0,1,0,0.5), border=FALSE)   # 1=> GREEN

             # polygon 5-95% for simus SCE 2
             mat.sim2 <- replace(mat.sim2, is.na(mat.sim2),0)
             polygon(c(1:nrow(mat.sim2), rev(1:nrow(mat.sim2))  ),
                  c(apply(mat.sim2, 1, quantile, 0.05, na.rm=TRUE)/a.unit,
                    rev(apply(mat.sim2, 1, quantile, 0.95, na.rm=TRUE)/  a.unit)) ,
              col=  rgb(0,0.5,1,0.5), border=FALSE)  # 2=> BLUE
           # add obs. data
             if( plot_obs && seg %in% names(lst_loglike_agg_1[['obs']]) ) {
               lines(1:nrow(mat.sim1),
               lst_loglike_agg_1[['obs']][  lst_loglike_agg_1[[refsimu1]]$year.month   ,seg]/a.unit,
                 col=1, lwd=2)
             }

     # an indicator PER VESSEL of gain compared to baseline  (over the entire period)
     # in terms of landings and in terms of vpuf
     # i.e. an unique summarizing number per vessel for this scenario
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="effort"){
        effort_1       <- apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        effort_2       <- apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        effort_mat1    <- mean( effort_1,  na.rm=TRUE)  # baseline
        effort_mat2    <- mean( effort_2,  na.rm=TRUE)
        gain_effort    <- effort_mat2/effort_mat1
        gain_effort_per_simu   <- effort_2/effort_1
        effort_sce         <- effort_mat2
        effort_base        <- effort_mat1
     }
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="cumsteaming"){
        seffort1       <- apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        seffort2       <- apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        seffort_mat1    <- mean( seffort1,  na.rm=TRUE)  # baseline
        seffort_mat2    <- mean( seffort2,  na.rm=TRUE)
        gain_seffort    <- seffort_mat2/seffort_mat1
        gain_seffort_per_simu   <- seffort2/seffort1
      }
   if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="fuelcost"){
        fuelcost1       <- apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        fuelcost2       <- apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        fuelcost_mat1    <- mean( fuelcost1,  na.rm=TRUE)  # baseline
        fuelcost_mat2    <- mean( fuelcost2,  na.rm=TRUE)
        gain_fuelcost    <- fuelcost_mat2/fuelcost_mat1
        gain_fuelcost_per_simu   <- fuelcost2/fuelcost1
      }
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="totland"){
        totland1       <- apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        totland2       <- apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        totland_mat1   <- mean( totland1,  na.rm=TRUE)  # baseline
        totland_mat2   <- mean( totland2,  na.rm=TRUE)
        gain_totland   <- totland_mat2/totland_mat1
        gain_totland_per_simu   <- totland2/totland1
    }
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="totland_explicit"){
        totlandav1explicit       <- apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        totlandav2explicit       <- apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        totland_av_mat1_explicit <- mean( totlandav1explicit,  na.rm=TRUE)  # baseline
        totland_av_mat2_explicit <- mean( totlandav2explicit,  na.rm=TRUE)
        gain_totland_explicit    <- totland_av_mat2_explicit/totland_av_mat1_explicit
        gain_totland_explicit_per_simu   <- totlandav2explicit/totlandav1explicit
     }
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="totland_implicit"){
        totlandav1implicit       <- apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        totlandav2implicit       <- apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        totland_av_mat1_implicit <- mean( totlandav1implicit,  na.rm=TRUE)  # baseline
        totland_av_mat2_implicit <- mean( totlandav2implicit,  na.rm=TRUE)
        gain_totland_implicit   <- totland_av_mat2_implicit/totland_av_mat1_implicit
        gain_totland_implicit_per_simu   <- totlandav2implicit/totlandav1implicit
     }
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="vpuf"){
        avvpuf1                 <- apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        avvpuf2                 <- apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        av_vpuf_mat1            <- mean( avvpuf1,  na.rm=TRUE) # baseline
        av_vpuf_mat2            <-  mean( avvpuf2,  na.rm=TRUE) #
        gain_av_vpuf            <- av_vpuf_mat2/av_vpuf_mat1
        gain_av_vpuf_per_simu   <- avvpuf2/avvpuf1
         }
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="vapuf"){
        avvapuf1                 <- apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        avvapuf2                 <- apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        av_vapuf_mat1            <- mean( avvapuf1,  na.rm=TRUE) # baseline
        av_vapuf_mat2            <-  mean( avvapuf2,  na.rm=TRUE) #
        gain_av_vapuf            <- av_vapuf_mat2/av_vapuf_mat1
        gain_av_vapuf_per_simu   <- avvapuf2/avvapuf1
         }
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="revenue"){
        avrevenue1         <- apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        avrevenue2         <- apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        av_revenue_mat1    <- mean( avrevenue1,  na.rm=TRUE) # baseline
        av_revenue_mat2    <- mean( avrevenue2,  na.rm=TRUE) #
        gain_av_revenue   <- av_revenue_mat2/av_revenue_mat1
        gain_av_revenue_per_simu   <- avrevenue2/avrevenue1
         }
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="rev_from_av_prices"){
        avrevavprices1           <- apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        avrevavprices2           <- apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        av_rev_av_prices_mat1    <- mean( avrevavprices1,  na.rm=TRUE) # baseline
        av_rev_av_prices_mat2    <- mean( avrevavprices2,  na.rm=TRUE) #
        gain_av_rev_av_prices    <- av_rev_av_prices_mat2/av_rev_av_prices_mat1
        gain_av_rev_av_prices_per_simu    <- avrevavprices2/avrevavprices1
         }
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="av_effort"){
        tripdur1                       <- apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        tripdur2                       <- apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        av_trip_duration_mat1          <- mean(tripdur1,  na.rm=TRUE) # baseline
        av_trip_duration_mat2          <- mean(tripdur2,  na.rm=TRUE) #
        gain_av_trip_duration          <- av_trip_duration_mat2/av_trip_duration_mat1
        gain_av_trip_duration_per_simu <- tripdur1/tripdur2
         }
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="traveled_dist"){
        traveleddistav1         <- apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        traveleddistav2         <- apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        traveled_dist_av_mat1   <- mean( traveleddistav1,  na.rm=TRUE) # baseline
        traveled_dist_av_mat2   <- mean( traveleddistav2,  na.rm=TRUE) #
        gain_av_traveled_dist   <- traveled_dist_av_mat2/traveled_dist_av_mat1
        gain_av_traveled_dist_per_simu   <- traveleddistav2/traveleddistav1
         }
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="gav"){
        avgav1        <- apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        avgav2        <- apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        av_gav_mat1   <- mean( avgav1,  na.rm=TRUE) # baseline
        av_gav_mat2   <- mean( avgav2,  na.rm=TRUE) #
        gain_av_gav   <- av_gav_mat2/av_gav_mat1
        gain_av_gav_per_simu   <- avgav2/avgav1
         }
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="gradva"){
        avgradva1       <- apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        avgradva2       <- apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        av_gradva_mat1  <- mean( avgradva1,  na.rm=TRUE) # baseline
        av_gradva_mat2  <-  mean( avgradva2,  na.rm=TRUE) #

       ## CAUTION THE LOG RATIO WHEN POTENTIAL NEGATIVE VALUES MAKE IT TRICKY:
       if(av_gradva_mat1 >=0 && av_gradva_mat2>=0 && abs(av_gradva_mat1)> abs(av_gradva_mat2)){
         gain_av_gradva   <- log(av_gradva_mat2/av_gradva_mat1) # this is in the positive interval
        }
       if(av_gradva_mat1 >=0 && av_gradva_mat2>=0 && abs(av_gradva_mat1)< abs(av_gradva_mat2)){
         gain_av_gradva   <- log(av_gradva_mat2/av_gradva_mat1) # this is in the positive interval
       }
       if(av_gradva_mat1 <0 && av_gradva_mat2 <0 && abs(av_gradva_mat1)> abs(av_gradva_mat2)) {
         gain_av_gradva   <- -log(av_gradva_mat2/av_gradva_mat1) # this is worsening (in the negative interval)
       }
       if(av_gradva_mat1 <0 && av_gradva_mat2 <0 && abs(av_gradva_mat1)< abs(av_gradva_mat2)) {
         gain_av_gradva   <- log(av_gradva_mat2/av_gradva_mat1) # this is an improvement (in the negative interval)
       }

       if(av_gradva_mat1 <0 && av_gradva_mat2 >=0 ) {
         gain_av_gradva   <- log((abs(av_gradva_mat1)+av_gradva_mat2)) # this is an improvement
       }
           if(av_gradva_mat1 >0 && av_gradva_mat2 <=0 ) {
         gain_av_gradva   <- -log((abs(av_gradva_mat2)+av_gradva_mat1)) # this is an worsening
       }


       gain_av_gradva_per_simu         <- rep(0, length(avgradva1))
       idx1                            <- avgradva1 >=0 & avgradva2>=0
       gain_av_gradva_per_simu[idx1]   <- log(avgradva2[idx1]/avgradva1[idx1])
       idx2                            <- avgradva1 <0 & avgradva2 <0 & abs(avgradva1)> abs(avgradva2)
       gain_av_gradva_per_simu[idx2]   <- -log(avgradva2[idx2]/avgradva1[idx2])
       idx3                            <- avgradva1 <0 & avgradva2 <0 & abs(avgradva1)< abs(avgradva2)
       gain_av_gradva_per_simu[idx3]   <- log(avgradva2[idx3]/avgradva1[idx3])
       idx4                            <- avgradva1 <0 & avgradva2 >0
       gain_av_gradva_per_simu[idx4]   <- log((abs(avgradva1[idx4])+avgradva2[idx4])/avgradva1[idx4])
       idx5                            <- avgradva1 >0 & avgradva2 <0
       gain_av_gradva_per_simu[idx5]   <- -log((abs(avgradva2[idx5])+avgradva1[idx5])/abs(avgradva2[idx5]))




     }
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="nbtrip"){
        avnbtrip1        <-  apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        avnbtrip2        <-  apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        av_nbtrip_mat1   <-  mean( avnbtrip1,  na.rm=TRUE) # baseline
        av_nbtrip_mat2   <-  mean( avnbtrip2,  na.rm=TRUE) #
        gain_av_nbtrip   <- av_nbtrip_mat2/av_nbtrip_mat1
        gain_av_nbtrip_per_simu   <- avnbtrip2/avnbtrip1
         }
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="fcpue_all"){
        fcpueall1        <- apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        fcpueall2        <- apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        fcpue_all_mat1   <- mean(fcpueall1,  na.rm=TRUE) # baseline
        fcpue_all_mat2   <- mean(fcpueall2,  na.rm=TRUE) #
        gain_fcpue_all   <- fcpue_all_mat2/fcpue_all_mat1
        gain_fcpue_all_per_simu   <- fcpueall2/fcpueall1
         }
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="fcpue_explicit"){
        fcpueexplicit1         <-  apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        fcpueexplicit2         <-  apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        fcpue_explicit_mat1    <-  mean( fcpueexplicit1,  na.rm=TRUE) # baseline
        fcpue_explicit_mat2    <-  mean( fcpueexplicit2,  na.rm=TRUE) #
        gain_fcpue_explicit    <-  fcpue_explicit_mat2/fcpue_explicit_mat1
        gain_fcpue_explicit_per_simu   <- fcpueexplicit2/fcpueexplicit1
         }
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg=="fcpue_implicit"){
        fcpueimplicit1         <-  apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        fcpueimplicit2         <-  apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        fcpue_implicit_mat1    <-  mean( fcpueimplicit1,  na.rm=TRUE) # baseline
        fcpue_implicit_mat2    <-  mean( fcpueimplicit2,  na.rm=TRUE) #
        gain_fcpue_implicit    <-  fcpue_implicit_mat2/fcpue_implicit_mat1
        gain_fcpue_implicit_per_simu   <- fcpueimplicit2/fcpueimplicit1
         }
     for (spi in 1: length(explicit_pops)) {
     if(what %in% c('per_vessel') &&  what2 %in% c("weight") && seg==paste0("fcpue_pop", explicit_pops[spi])){
        fcpuepop0_1        <- apply(mat.sim1, 2, function(x) sum(x[x!=0]))
        fcpuepop0_2        <- apply(mat.sim2, 2, function(x) sum(x[x!=0]))
        fcpue_pop0_mat1    <- mean(fcpuepop0_1,  na.rm=TRUE) # baseline
        fcpue_pop0_mat2    <- mean(fcpuepop0_2,  na.rm=TRUE) #
        assign(paste("gain_fcpue_pop", explicit_pops[spi], sep=""),  fcpue_pop0_mat2/fcpue_pop0_mat1)
        assign(paste("gain_fcpue_pop",explicit_pops[spi],"_per_simu", sep=""), fcpuepop0_2/fcpuepop0_1)
         }
       }


             if(count%%9 ==0){
                 # save the current one
                 dev.off()
                   # to be converted in wmf afterward (because wmf do not handle transparency directly in R)
                 #...and open a new one:
                 outputfile <- file.path(output.folder,
                                        paste("loglike_",what2,"_panel",count,"_",gsub("\\.","",a.comment),'.pdf',sep="" ))
                 pdf(file = outputfile)
                 par(mfrow=c(3,3))
                }

       }   # end for column in lst_loglike_agg_1[[1]]

       # save the last one
      dev.off()

      # after all....
      # draw a barplot
      graphics.off()
      if(what %in% c("per_pop", "per_vessel", "per_country")){

      outputfile <- file.path(output.folder, paste("loglike_",what2,"_barchart_land_composition_",
                                                gsub("\\.","",a.comment),'.png',sep="" ))
      #pdf(file = outputfile)
       png(filename=file.path(outputfile),
                                   width = 1500, height = 1500,
                                   units = "px", pointsize = 12,  res=300)

      par(mfrow=c(2,1))
      idx_pop <- grep('pop', colnames(sum_all_months_and_mean_across_runs1))
      idx_col <- intersect(
                   idx_pop,
                   which(sum_all_months_and_mean_across_runs1 <
                           0.10* max(sum_all_months_and_mean_across_runs1[idx_pop], na.rm=TRUE))
                        )
      idx_col2 <- intersect(
                   idx_pop,
                   which(sum_all_months_and_mean_across_runs1 >
                           0.10* max(sum_all_months_and_mean_across_runs1[idx_pop], na.rm=TRUE))
                        )
     if(length(idx_col)!=0){
      barplot(t(cbind(sum_all_months_and_mean_across_runs1[,idx_col],
                    sum_all_months_and_mean_across_runs2[,idx_col])/1e6),
                      col = rep(rainbow(24), each=2), density= c(10,100),
                       axes = TRUE, beside=TRUE, cex.names=1.0,las=2,
                        ylab= "mean over runs of total landings (thousand tons)")
      barplot(t(cbind(sum_all_months_and_mean_across_runs1[,idx_col2],
                    sum_all_months_and_mean_across_runs2[,idx_col2])/1e6),
                      col = rep(rainbow(24), each=2), density= c(10,100),
                       axes = TRUE, beside=TRUE, cex.names=1.0,las=2,
                        ylab= "mean over runs of total landings (thousand tons)")
      }
     dev.off()
     }




 graphics.off()

    } else{
    cat(paste("not enough (equivalent) simus for this subset....\n"))
    }




    # write the output for the individual indicator
      if(what %in% c('per_vessel') &&  what2 %in% c("weight")){
         write(c(format(Sys.time(), "%H:%M:%S"), combined_name, lstargs$vid,
                      effort_base, effort_sce, gain_effort, gain_seffort,
                      totland_mat1, totland_av_mat1_explicit,
                      gain_totland, gain_totland_explicit, gain_totland_implicit,
                      gain_av_vpuf, gain_av_vapuf, gain_av_revenue, gain_av_rev_av_prices,
                       gain_av_gav, gain_av_gradva,
                        gain_fcpue_all, gain_fcpue_explicit, gain_fcpue_implicit,
                        paste("gain_fcpue_pop",explicit_pops, sep=""),
                        gain_av_trip_duration, gain_av_traveled_dist, gain_av_nbtrip), ncol=24 + length(explicit_pops),
                    file=file.path(lstargs$general$main.path, lstargs$general$namefolderinput,
                     paste("vid_indicators_gain_in_totland_and_vpuf_",the_baseline,".txt", sep='')),
                     append = TRUE, sep = " ")


        a_df_disc <-  eval(parse(text=paste("cbind.data.frame(",paste("gain_fcpue_pop",explicit_pops,"_per_simu", sep="", collapse=","), ")" )))

        write.table(cbind.data.frame(time=format(Sys.time(), "%H:%M:%S"), combined_name, lstargs$vid,
                                     simu=gsub("effort","", names(gain_effort_per_simu)),
                      effort_base, effort_sce, gain_effort_per_simu, gain_seffort_per_simu,
                      totland_mat1, totland_av_mat1_explicit,
                      gain_totland_per_simu, gain_totland_explicit_per_simu, gain_totland_implicit_per_simu,
                       gain_av_vpuf_per_simu, gain_av_vapuf_per_simu, gain_av_revenue_per_simu, gain_av_rev_av_prices_per_simu,
                       gain_av_gav_per_simu, gain_av_gradva_per_simu,  gain_fuelcost_per_simu,
                        gain_fcpue_all_per_simu, gain_fcpue_explicit_per_simu,gain_fcpue_implicit_per_simu,
                         a_df_disc,
                        gain_av_trip_duration_per_simu, gain_av_traveled_dist_per_simu, gain_av_nbtrip_per_simu),
                    file=file.path(lstargs$general$main.path, lstargs$general$namefolderinput,
                     paste("vid_indicators_gain_in_totland_and_vpuf_",the_baseline,"_per_simu.txt", sep='')),
                     append = TRUE, sep = " ", col.names = FALSE, row.names=FALSE, quote=FALSE)

       }


 return()
}








