running <- function(vec,floor_status){
  going_up <- c()
  going_down <- c()
  current_time <- vec[1]
  if (vec[2]- floor_status >0 || (vec[2] == floor_status && vec[4] == 1)){
    going_up <- c(going_up,vec[2])
    direct <- 1
  }else{
    going_down <- c(going_down,vec[2])
    direct <- -1
  }
  if (vec[4] == 1){
    going_up <- c(going_up,vec[3])
  }else{
    going_down <- c(going_down,vec[3])
  }
  to_do <- list(going_up = going_up, going_down = going_down, floor_status = floor_status, current_time = current_time, direct = direct)
  return(to_do)
}

operation <- function(floor_status,going_up,going_down,current_time,direct,pending){
  if (direct == 1){
    diffe <- going_up - floor_status
    if (any(diffe == 0)){
      if (is.na(going_down[1]) == F && is.null(going_down) == F){
        if (length(going_up) == 1 && going_up[1] == max(going_down)){
          current_time <- current_time - 1
        }
      }
      floor_status <- floor_status
      going_up <- going_up[-which(going_up == floor_status)]
      current_time <- current_time + 1
    }else if(is.na(going_up[1]) == TRUE || is.null(going_up) == TRUE){
      if ((is.na(going_down[1]) == TRUE || is.null(going_down) == TRUE) && (is.na(pending[1]) == TRUE || is.null(pending) == TRUE)){
        return(c(floor_status,current_time))
      }else if (is.na(going_down[1]) == F && is.null(going_down) == F){
        if(max(going_down) > floor_status){
          floor_status <- floor_status + 1
          current_time <- current_time + 1
        }else{
          direct <- -1
          going_up <- pending
          pending <- c()
        }
      }else{
        direct <- -1
        going_up <- pending
        pending <- c()
      }
    }else{
      floor_status <- floor_status + 1
      current_time <- current_time + 1
    }
  }else if (direct == -1){
    diffe <- going_down - floor_status
    if (any(diffe == 0)){
      if (is.na(going_up[1]) == F && is.null(going_up) == F){
        if (length(going_down) == 1 && going_down[1] == min(going_up)){
          current_time <- current_time - 1
        }
      }
      floor_status <- floor_status
      going_down <- going_down[-which(going_down == floor_status)]
      current_time <- current_time +1 
    }else if(is.na(going_down[1]) == TRUE || is.null(going_down) == TRUE){
      if ((is.na(going_up[1]) == TRUE || is.null(going_up) == TRUE) && (is.na(pending[1]) == TRUE || is.null(pending) == TRUE)){
        return(c(floor_status,current_time))
      }else if(is.na(going_up[1]) == F && is.null(going_up) == F){ 
        if(min(going_up) < floor_status){
          floor_status <- floor_status - 1
          current_time <- current_time + 1
        }else{
          direct <- 1
          going_down <- pending
          pending <- c()
        }
      }
      else{
        direct <- 1
        going_down <- pending
        pending <- c()
      }
    }else{
      floor_status <- floor_status - 1
      current_time <- current_time + 1
    }
  }
  status <- list(going_up = going_up, going_down = going_down, floor_status = floor_status, current_time = current_time, direct = direct, pending = pending)
  return(status)
}

elevator <- function(Requests){
  floor_status <- 1
  pending <- c()
  going_up <- c()
  going_down <- c()
  if (nrow(Requests) == 1 || is.null(nrow(Requests))){
    directs <- sign(Requests[3]-Requests[2])
    Requests <- c(Requests,directs)
    to_do <- running(Requests,floor_status)
  }else{
    Requests <- Requests[order(Requests[,1],Requests[,2],Requests[,3]),]
    num_Request <- nrow(Requests)
    directs <- sign(Requests[,3] - Requests[,2])
    Requests <- matrix(c(Requests,directs),num_Request)
    to_do <- running(Requests[1,],floor_status)
  }
  going_up <- sort(to_do[[1]])
  going_down <- sort(to_do[[2]])
  current_time <- to_do[[4]]
  direct <- to_do[[5]]
  if (nrow(Requests) == 1 || is.null(nrow(Requests)) ){
  }else{
    k <- 2
    for (i in Requests[2:num_Request]){
      while (i > current_time) {
        status <- operation(floor_status,going_up,going_down,current_time,direct,pending)
        if (is.numeric(status) == FALSE){
          going_up <- status[[1]]
          going_down <- status[[2]]
          floor_status <- status[[3]]
          current_time <- status[[4]]
          direct <- status[[5]]
          pending <- status[[6]]
        }else{
          new_status <- running(Requests[k,],status[1])
          going_up <- new_status[[1]]
          going_down <- new_status[[2]]
          floor_status <- new_status[[3]]
          current_time <- new_status[[4]]
          direct <- new_status[[5]]
          pending <- c()
        }
      }
      if (Requests[k,2] > floor_status && direct == 1 && Requests[k,4] == 1){
        going_up <- c(going_up,Requests[k,2],Requests[k,3])
        unique(going_up)
      }else if(direct == 1 && Requests[k,4] == -1){
        going_down <- c(going_down, Requests[k,2],Requests[k,3])
        unique(going_down)
      }else if(direct == -1 && Requests[k,4] == 1){
        going_up <- c(going_up,Requests[k,2],Requests[k,3])
        unique(going_up)
      }else if(Requests[k,2] < (floor_status + 0.001) && direct == 1 && Requests[k,4] == 1){
        pending <- c(pending,Requests[k,2],Requests[k,3])
        unique(pending)
      }else if(Requests[k,2] < floor_status && direct == -1 && Requests[k,4] == -1){
        going_down <- c(going_down, Requests[k,2],Requests[k,3])
        unique(going_down)
      }else if(Requests[k,2] >= floor_status && direct == -1 && Requests[k,4] == -1){
        pending <- c(pending,Requests[k,2],Requests[k,3])
        unique(pending)
      }
      k <- k + 1
    }
  }
  while((is.na(going_down[1]) == F && is.null(going_down) == F) || (is.na(going_up[1]) == F && is.null(going_up) == F) || (is.na(pending[1]) == F && is.null(pending) == F)){
    status <- operation(floor_status,going_up,going_down,current_time,direct,pending)
    going_up <- status[[1]]
    going_down <- status[[2]]
    floor_status <- status[[3]]
    current_time <- status[[4]]
    direct <- status[[5]]
    pending <- status[[6]]
  }
  return(current_time)
}