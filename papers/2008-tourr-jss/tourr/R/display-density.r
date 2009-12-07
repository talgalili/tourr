#' 1d distribution tour path animation.
#'
#' Animate a 1d tour path with a density plot or histogram.
#'
#' @param data matrix, or data frame containing numeric columns
#' @param tour_path tour path generator, defaults to the grand tour
#' @param method display method, histogram or density plot
#' @param center should 1d projection be centered to have mean zero (default: TRUE).
#'   This pins the centre of distribution to the same place, and makes it
#'   easier to focus on the shape of the distribution.
#' @param ... other arguments passed on to \code{\link{animate}}
#' @seealso \code{\link{animate}} for options that apply to all animations
#' @keywords hplot
#' @aliases display_dist animate_dist
#' @usage display_dist(data, method="density", center = TRUE, ...)
#'        animate_dist(data, tour_path = grand_tour(1), ...)
#' @examples
#' animate_dist(flea[, 1:6])
#'
#' # When the distribution is not centred, it tends to wander around in a 
#' # distracting manner
#' animate_dist(flea[, 1:6], center = FALSE)
#'
#' # Alternatively, you can display the distribution with a histogram
#' animate_dist(flea[, 1:6], method = "hist")
display_dist <- function(data, method="density", center = TRUE, ...)
{
  method <- match.arg(method, c("histogram", "density", "ash"))
  labels <- rng <- limit <- NULL
  init <- function(data) {
    if (is.null(limit)) {
      first_eigen <- sqrt(eigen(var(data))$values[1])
      limit <<- 3 * first_eigen
    }
    rng <<- c(-limit, limit)    
    labels <<- abbreviate(colnames(data), 2)
#    range <<- c(-2, 2)
  }
  
  # Display 
  render_frame <- function() {
    par(pty="m",mar=c(4,4,1,1))
    plot(
      x = NA, y = NA, xlim = rng, ylim = c(-1.1, 3*limit), xaxs="i", yaxs="i",
      xlab = "Data Projection", ylab = "Density", yaxt = "n"
    )
    axis(2, seq(0, 4, by = 1))
  }
  render_transition <- function() {
    rect(-limit, -1.1, limit, 4, col="#FFFFFFE6", border=NA)
  }
  render_data <- function(data, proj, geodesic) {
    abline(h = seq(0.5, 3.5, by=0.5), col="grey80")
    lines(c(0,0), c(-1,0), col="grey80")
    lines(c(-1,-1), c(-1,0), col="grey80")
    lines(c(1,1), c(-1,0), col="grey80")

    x <- data%*%proj
    if (center) x <- scale(x, center = TRUE, scale = FALSE)
    
    # Render projection data
    if (method == "histogram") {
      bins <- hist(x, breaks = seq(-limit, limit, 0.2), plot = FALSE)
      with(bins, rect(mids - 0.1, 0, mids + 0.1, density,
          col="black", border="white"))
    } else if (method == "density") {
      polygon(density(x), lwd = 2, col="black")
    } else if (method == "ash") {
      library(ash)
      capture.output(ash <- ash1(bin1(x, rng)))
      lines(ash)
    }
    abline(h = 0)
    box(col="grey70")
    
    # Render tour axes
    for (i in 1:length(proj)) {
      x <- i / length(proj)
      lines(c(0, proj[i]), c(-x, -x), col="black", lwd=3)
      text(1, -x, labels[i], pos=4)
    }
  }

  list(
    init = init,
    render_frame = render_frame,
    render_transition = render_transition,
    render_data = render_data,
    render_target = nul
  )
}


# not being documented.  already aliased somewhere else
animate_dist <- function(data, tour_path = grand_tour(1), ...) {
  animate(
    data = data, tour_path = tour_path,
    display = display_dist(data,...), 
    ...
  )
}

