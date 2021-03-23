#' Draws a gradient legend for a climate stripes plot
#'
#' @param xleft the lower left x coordinate of the legend
#' @param ybottom the lower left y coordinate of the legend
#' @param xright the upper right x coordinate of the legend
#' @param ytop the upper right y coordinate of the legend
#' @param colour.vec a vector of colours to ramp between (see colorRampPalette, "colors")
#' @param ncolours the number of colours to show on the legend. Default is 500, a large number produces a smooth legend colour gradient
#' @param labels default TRUE. If TRUE then values you supply (var.min.label) and (var.max.label) are shown on the legend
#' @param var.min.label the value for the highest temperature to show on the legend
#' @param var.max.label the value for the lowest temperature to show on the legend
#' @param text.col.legend colour of the legend text
#' @description This draws a colour gradient legend for use as a climate stripes legend. It uses rect to draw many rectangles (500) and colours
#'       each with a ramp palette so that it appears as a smooth gradient. It is also possible to do this as a rasterImage but these images
#'       can be hard to work with and do not scale properly especially for multiplot layouts.
#' @seealso rect colorRampPalette
#' @export
colour.gradient.legend.f= function(xleft,ybottom,xright,ytop,colour.vec=c("blue","red"),ncolours=500,labels=T,var.min.label,var.max.label, text.col.legend){
  tempcol=colorRampPalette(colors=colour.vec)(ncolours)
  xlefts= rep(xleft,length=ncolours)
  xrights= rep(xright,length=ncolours)
  ybottoms= seq(ybottom,ytop-1/ncolours,length=ncolours)
  ytops= ybottoms+1/ncolours
  for (i in 1:ncolours){
    rect(xlefts[i],ybottoms[i],xrights[i],ytops[i],col=tempcol[i],border=NA)
  }
  if (labels){
    text((x=xleft+xright)/2, y=ybottom, var.min.label,adj=c(0.5,0),col=text.col.legend,font=2,cex=0.8)
    text((x=xleft+xright)/2, y=ytop, var.max.label,adj=c(0.5,1),col=text.col.legend,font=2,cex=0.8)
  }
}

#' Draws climate stripes given a time vector and environmental (usually temperature) vector
#'
#' @param time.vector the time series vector
#' @param temperature.vector a times series of any environmental variable (climate stripes have been developed for temperature) whose values correspond to the time vector
#' @param colour.vec a vector of colours to ramp between (see colorRampPalette, "colors")
#' @param title a title for the colour stripes plot if you want one
#' @param time.scale show a temporal axis. Default TRUE
#' @param legend puts a legend for the colour gradient on the top right of the plot with the lowest and highest values shown. Default TRUE
#' @param text.col.legend colour of the legend text
#' @param na.colour colour to display for na in the time series
#' @param n.categories.legend the number of colour categories you want to show in the legend, default=500 (large numbers smooth it). Careful trying to make only a few discrete categories, you can get some peculiar looking legends.
#' @param legend.xpos the left and right x coordinates of the legend bar (same units as your time axis)
#' @param ... additional arguments that plot will accept, see par
#' @description Climate stripes are a simple way of showing how temperature (or any other time series) has changed over time. They are usually
#'       drawn for a temperature time series with blue being the coldest years and red being the warmest. They offer a relatively uncluttered
#'       depiction of a temperature over time that can be grasped almost immediately and are good at showing climate change from long time series.
#' @details This plot will always use both end of the colour series provided. So if your colours were blue and red and you had a two years times series
#'       then one stripe will be blue and the other red. i.e. the plots are meant to show changes not absolutes. This is a good reason why a legend
#'       might be excluded. They are usually not for communication to scienific audiences unless in as a quick slide in a presentation so consider
#'       not cluttering up the image with a legend and perhaps not even an axis.
#'
#'       Missing points in the time series should be NA for the variable. They are depicted as white spaces on the climate stripes plot. You will not
#'       get an error with missing points in the time series but it will show the stipes of the preceeding time series point to be wider. It is also
#'       deceptive to not include missing data.
#' @seealso plot par rect colour.gradient.legend.f
#' @references
#'       https://www.climate-lab-book.ac.uk/2018/warming-stripes/
#' @export
climate.col.stripes.f= function(time.vector,temperature.vector, colour.vec=c("blue","red"), title="", time.scale=T, legend=T, text.col.legend="yellow", na.colour="white", n.categories.legend=500, legend.xpos=c(NA,NA), ...){

  #temperature.vector= temperature.vector[-length(temperature.vector)]
  #time.start= time.vector[-length(time.vector)]
  #time.end= time.vector[-1]

  time.start= time.vector
  time.end= c(time.vector[-1],time.vector[length(time.vector)]+1)

  # dummy variables to setup the plotting space
  x.dummy= c(time.vector[1], time.vector[length(time.vector)]+length(time.vector)*0.04)
  y.dummy= c(0,1)
  #par(mar=c(2,0.5,2,5))
  plot(x.dummy,y.dummy,axes=F,xlab="",ylab="",,type="n", ...)

  # bin the y variable and assign a colour to bins according to the bin values
  bins= hist(temperature.vector,breaks=15,plot=F)
  bin.vals= as.numeric(cut(temperature.vector, bins$breaks))
  cols=colorRampPalette(colors= colour.vec)(length(bins$breaks))
  tempcol= cols[as.numeric(bin.vals)]
  # NA years are assigned a colour of your choosing (function argument)
  tempcol[is.na(temperature.vector)]= na.colour
  chosencols<<-tempcol
  rect(time.start,0,time.end,1,col=tempcol,border=NA)
  if(time.scale) axis(1,at=time.vector,tick=F,line=-1)
  title(title,cex.main=.8)

  # put on a legend. If the x positions are not specified defaults are used. They may not be suitable in all cases
  if(legend){
    if(any(!is.na(legend.xpos))){
      colour.gradient.legend.f(xleft=legend.xpos[1],
        ybottom=.5,
        xright=legend.xpos[2],
        ytop=1,
        var.min.label=round(min(temperature.vector,na.rm=T),1),
        var.max.label=round(max(temperature.vector,na.rm=T),1),
        colour.vec=colour.vec,labels=T,text.col.legend=text.col.legend,
        ncolours=n.categories.legend)
    }
    if(any(is.na(legend.xpos))){
    colour.gradient.legend.f(xleft=max(time.vector)+length(time.vector)*0.02,
      ybottom=.5,
      xright=max(time.vector)+length(time.vector)*0.07,
      ytop=1,
      var.min.label=round(min(temperature.vector,na.rm=T),1),
      var.max.label=round(max(temperature.vector,na.rm=T),1),
      colour.vec=colour.vec,labels=T,text.col.legend=text.col.legend,
      ncolours=n.categories.legend)
    }
  }
}


#' Superimpose the data series and a smooth gam (spline) trend line on the climate stripe plot
#'
#' @param time.vector the time series vector
#' @param temperature.vector a times series of any environmental variable (climate stripes have been developed for temperature) whose values correspond to the time vector
#' @param data.colour colour of the data line to superimpose
#' @param spline fit a spline (gam) and superimpose in addition to the data
#' @param spline.colour colour of the spline line to superimpose
#' @param ... additional arguments to the trend line that "lines" will accept, see par
#' @description Superimpose data and a gam smooth (spline) on the climate stripes plot. It can be visually more striking and can be more science friendly while still conveying the main colour temperature message of the climate stripes plot
#' @details Superimposes data after rescaling from 0 to 1, i.e. the lowest point in the series will be at the bottom of the graph and the highest at the top. The
#'       gam is calculated using mgcv default for gam
#' @seealso lines par mgcv::gam smooth.spline
#' @export
superimpose.data.f= function(time.vector, temperature.vector, data.colour="yellow", spline=T,
  spline.colour="white", ...){
  y.data= rescale(temperature.vector,c(0,1))
  time.mid=time.vector+0.5
  lines(time.mid, y.data, col=data.colour,lwd=2)
  if (spline){
    gf= gam(y.data~ s(time.mid))
    newdata= data.frame(time.mid=seq(min(time.mid),max(time.mid),length=length(time.mid)*10))
    lines(newdata$time.mid,predict(gf, newdata=newdata), col=spline.colour, ...)
  }
}
