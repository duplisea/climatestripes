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
colour.gradient.legend.f <- function(xleft, ybottom, xright, ytop, colour.vec = c("blue", "red"),
                                     ncolours = 500, labels = TRUE, var.min.label, var.max.label,
                                     text.col.legend) {
  tempcol <- colorRampPalette(colors = colour.vec)(ncolours)
  xlefts <- rep(xleft, length.out = ncolours)
  xrights <- rep(xright, length.out = ncolours)
  ybottoms <- seq(ybottom, ytop - 1 / ncolours, length.out = ncolours)
  ytops <- ybottoms + 1 / ncolours
  for (i in 1:ncolours) {
    rect(xlefts[i], ybottoms[i], xrights[i], ytops[i], col = tempcol[i], border = NA)
  }
  if (labels) {
    text((xleft + xright) / 2, y = ybottom, var.min.label, adj = c(0.5, 0),
         col = text.col.legend, font = 2, cex = 0.8)
    text((xleft + xright) / 2, y = ytop, var.max.label, adj = c(0.5, 1),
         col = text.col.legend, font = 2, cex = 0.8)
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
#' @importFrom graphics rect axis title text hist plot
#' @export
climate.col.stripes.f <- function(time.vector, temperature.vector, colour.vec = c("blue", "red"),
                                  title = "", time.scale = TRUE, legend = TRUE,
                                  text.col.legend = "yellow", na.colour = "white",
                                  n.categories.legend = 500, legend.xpos = c(NA, NA), ...) {

  time.start <- time.vector
  time.end <- c(time.vector[-1], time.vector[length(time.vector)] + 1)

  # dummy variables to setup the plotting space
  x.dummy <- c(time.vector[1], time.vector[length(time.vector)] + length(time.vector) * 0.04)
  y.dummy <- c(0, 1)
  plot(x.dummy, y.dummy, axes = FALSE, xlab = "", ylab = "", type = "n", ...)

  # bin the y variable and assign a colour to bins according to the bin values
  bins <- hist(temperature.vector, breaks = 15, plot = FALSE)
  bin.vals <- as.numeric(cut(temperature.vector, bins$breaks))
  cols <- colorRampPalette(colors = colour.vec)(length(bins$breaks))
  tempcol <- cols[as.numeric(bin.vals)]
  # NA years are assigned a colour of your choosing (function argument)
  tempcol[is.na(temperature.vector)] <- na.colour
  rect(time.start, 0, time.end, 1, col = tempcol, border = NA)
  if (time.scale) axis(1, at = time.vector, tick = FALSE, line = -1)
  title(title, cex.main = 0.8)

  # put on a legend. If the x positions are not specified defaults are used. They may not be suitable in all cases
  if (legend) {
    if (any(!is.na(legend.xpos))) {
      colour.gradient.legend.f(
        xleft = legend.xpos[1],
        ybottom = 0.5,
        xright = legend.xpos[2],
        ytop = 1,
        var.min.label = round(min(temperature.vector, na.rm = TRUE), 1),
        var.max.label = round(max(temperature.vector, na.rm = TRUE), 1),
        colour.vec = colour.vec, labels = TRUE, text.col.legend = text.col.legend,
        ncolours = n.categories.legend
      )
    }
    if (any(is.na(legend.xpos))) {
      colour.gradient.legend.f(
        xleft = max(time.vector) + length(time.vector) * 0.02,
        ybottom = 0.5,
        xright = max(time.vector) + length(time.vector) * 0.07,
        ytop = 1,
        var.min.label = round(min(temperature.vector, na.rm = TRUE), 1),
        var.max.label = round(max(temperature.vector, na.rm = TRUE), 1),
        colour.vec = colour.vec, labels = TRUE, text.col.legend = text.col.legend,
        ncolours = n.categories.legend
      )
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
#' @importFrom scales rescale
#' @importFrom mgcv gam
#' @importFrom graphics lines
#' @importFrom stats predict
#' @export
superimpose.data.f <- function(time.vector, temperature.vector, data.colour = "yellow",
                               spline = TRUE, spline.colour = "white", ...) {
  y.data <- scales::rescale(temperature.vector, to = c(0, 1))
  time.mid <- time.vector + 0.5
  lines(time.mid, y.data, col = data.colour, lwd = 2)
  if (spline) {
    gf <- gam(y.data ~ s(time.mid))
    newdata <- data.frame(time.mid = seq(min(time.mid), max(time.mid), length.out = length(time.mid) * 10))
    lines(newdata$time.mid, predict(gf, newdata = newdata), col = spline.colour, ...)
  }
}













#' Draws climate rings given a time vector and environmental (usually temperature) vector
#'
#' @param time.vector the time series vector
#' @param temperature.vector a time series of any environmental variable whose values correspond
#'   to the time vector
#' @param colour.vec a vector of colours to ramp between (see colorRampPalette). Also used for
#'   the legend colour gradient regardless of whether \code{stripe.cols} is supplied
#' @param stripe.cols a vector of pre-computed colours, one per time step, as returned invisibly
#'   by \code{climate.col.stripes.f}. If supplied these are used directly for ring colours so
#'   that the rings and stripes share an identical colour mapping
#' @param title a title for the plot. Default ""
#' @param legend puts a gradient legend on the plot. Default TRUE
#' @param text.col.legend colour of the legend text. Default "yellow"
#' @param na.colour colour to display for NA values in the time series. Default "white"
#' @param nv number of vertices used to draw each circle (higher = smoother). Default 1000
#' @param legend.pos a length-4 vector giving c(xleft, ybottom, xright, ytop) for the colour
#'   gradient legend in plot coordinates. Default c(6.0, -4, 8.5, 4)
#' @param ... additional arguments passed to \code{plot}
#' @description Climate rings are a circular variant of climate stripes. The most recent year is
#'   the outermost ring and the oldest year is at the centre, so the progression from cool (old,
#'   inner) to warm (recent, outer) reads naturally from inside to outside, like a warming tree.
#' @details Rings are drawn from the most recent year (largest radius, outermost) inward to the
#'   oldest year (smallest radius, innermost). Each ring is a filled circle so it covers the
#'   centre of everything drawn before it. Drawing from outside in means the oldest year ends up
#'   as the visible centre dot. Radii are evenly spaced by index.
#' @seealso climate.col.stripes.f plotrix::draw.circle
#' @importFrom plotrix draw.circle
#' @importFrom graphics plot axis title hist rect text
#' @importFrom grDevices colorRampPalette as.raster
#' @importFrom scales rescale
#' @references
#'   https://www.climate-lab-book.ac.uk/2018/warming-stripes/
#' @export
climate.col.rings.f <- function(time.vector, temperature.vector,
                                colour.vec = c("navyblue", "lightblue", "red", "darkred"),
                                stripe.cols = NULL,
                                title = "",
                                legend = TRUE,
                                text.col.legend = "yellow",
                                na.colour = "white",
                                nv = 1000,
                                legend.pos = c(6.0, -4, 8.5, 4),
                                ...) {

  n <- length(time.vector)

  # tempcol[1] = colour for oldest year (should be blue/cool)
  # tempcol[n] = colour for newest year (should be red/warm)
  if (!is.null(stripe.cols)) {
    tempcol <- stripe.cols
  } else {
    bins     <- hist(temperature.vector, breaks = 15, plot = FALSE)
    bin.vals <- as.numeric(cut(temperature.vector, bins$breaks))
    cols     <- colorRampPalette(colors = colour.vec)(length(bins$breaks))
    tempcol  <- cols[as.numeric(bin.vals)]
    tempcol[is.na(temperature.vector)] <- na.colour
  }

  # radii[1] = smallest = oldest year at centre
  # radii[n] = largest  = newest year at outside
  radii <- scales::rescale(seq_len(n), to = c(0.1, 5))

  plot(0, 0, xlim = c(-10, 10), ylim = c(-10, 10),
       axes = FALSE, type = "n", xlab = "", ylab = "", asp = 1, ...)
  title(title, cex.main = 0.8)

  # draw outermost (newest, largest) ring first, then work inward
  # each successive smaller circle covers the centre of the previous
  # so oldest year ends up as the visible centre
  for (i in n:1) {
    plotrix::draw.circle(0, 0, radius = radii[i],
                         col = tempcol[i], lty = 0, nv = nv)
  }

  # year axis on the left
  # oldest year (small radius) near bottom of axis, newest (large radius) near top
  label.idx  <- floor(seq(1, n, length.out = 5))
  axis.radii <- radii[label.idx]
  axis.years <- time.vector[label.idx]
  axis(side = 2, at = axis.radii, labels = axis.years,
       pos = -5.5, las = 1, cex.axis = 0.7, tick = TRUE)

  # legend using rasterImage for a guaranteed solid colour block
  if (legend) {
    lx1 <- legend.pos[1]
    ly1 <- legend.pos[2]
    lx2 <- legend.pos[3]
    ly2 <- legend.pos[4]
    pal     <- colorRampPalette(colour.vec)(256)
    # rasterImage row 1 = top of image so reverse so cold is at bottom, warm at top
    pal.mat <- matrix(rev(pal), nrow = 256, ncol = 1)
    ras     <- grDevices::as.raster(pal.mat)
    graphics::rasterImage(ras, lx1, ly1, lx2, ly2, interpolate = TRUE)
    # box around legend
    graphics::rect(lx1, ly1, lx2, ly2, border = text.col.legend, lwd = 0.5)
    # labels
    graphics::text((lx1 + lx2) / 2, ly1,
                   round(min(temperature.vector, na.rm = TRUE), 1),
                   adj = c(0.5, 1.3), col = text.col.legend, font = 2, cex = 0.8)
    graphics::text((lx1 + lx2) / 2, ly2,
                   round(max(temperature.vector, na.rm = TRUE), 1),
                   adj = c(0.5, -0.3), col = text.col.legend, font = 2, cex = 0.8)
  }

  invisible(tempcol)
}


#' Superimpose a breakpoint circle on a climate rings plot
#'
#' @param time.vector the time series vector, must be the same as used in
#'   \code{climate.col.rings.f}
#' @param temperature.vector a time series of any environmental variable, must be the same as
#'   used in \code{climate.col.rings.f}
#' @param border.colour colour of the breakpoint circle border. Default "yellow"
#' @param lty line type for the breakpoint circle border. Default 2 (dashed)
#' @param lwd line width for the breakpoint circle border. Default 5
#' @param nv number of vertices used to draw the circle. Default 1000
#' @description Fits a segmented (piecewise) linear regression to the temperature time series
#'   and superimposes a dashed circle on the climate rings plot at the radius corresponding to
#'   the estimated breakpoint year. The breakpoint year is returned invisibly and printed to
#'   the console.
#' @details The radius scale matches that used internally by \code{climate.col.rings.f}: time
#'   index rescaled to 0.1--5 so that the newest year has the largest radius.
#' @seealso climate.col.rings.f segmented::segmented plotrix::draw.circle
#' @importFrom plotrix draw.circle
#' @importFrom scales rescale
#' @importFrom segmented segmented
#' @importFrom stats lm
#' @export
rings.breakpoint.f <- function(time.vector, temperature.vector,
                               border.colour = "yellow",
                               lty = 2, lwd = 5, nv = 1000) {

  n     <- length(time.vector)
  radii <- scales::rescale(seq_len(n), to = c(0.1, 5))
  tmp   <- scales::rescale(temperature.vector, to = c(1, 10))

  cs.lm  <- stats::lm(tmp ~ radii)
  cs.seg <- segmented::segmented(cs.lm)
  bp.radius <- cs.seg$psi[, 2]

  bp.idx  <- which.min(abs(radii - bp.radius))
  bp.year <- time.vector[bp.idx]
  message("Estimated breakpoint year: ", bp.year)

  plotrix::draw.circle(0, 0,
                       radius = radii[bp.idx],
                       border = border.colour,
                       lty    = lty,
                       lwd    = lwd,
                       nv     = nv)

  invisible(bp.year)
}
