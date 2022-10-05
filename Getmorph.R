library(httr)
library(stringr)
library(tools)

proxy_url <- "127.0.0.1"
proxy_port <- 7890
post_url <- "https://api.facemorph.me/api/encodeimage/"
get_url <- "https://api.facemorph.me/api/morphframe/"
savepath <- "D:/study/R4DS/facemorphing/Output/"
root <- "D:/study/R4DS/facemorphing/Input"
filename1 <- "A1.tif"
filename2 <- "B1.tif"
my_frame_num <- 80
my_num_frames <- 100


exit <- function() {
  invokeRestart("abort") 
}

sanity_check <- function(){
  response_status <- GET("https://api.facemorph.me/api/status",use_proxy(proxy_url, port = proxy_port))$status
  if(response_status!=200){
    print("facemorph API is not accessible! Please check proxy or server status.")
    exit()
  }
}

upload_file_get_guid <- function(file){
  response <- POST(
    post_url, 
    body = list(
      tryalign = TRUE, 
      usrimg = upload_file(file)
    ),
    encode = "multipart",
    use_proxy(proxy_url, port = proxy_port)
  )
  guid <- content(response)$guid
  return(guid) 
}

morph_frame_from_guid <- function(my_from_guid, my_to_guid, my_frame_num,my_num_frames=100){
  response <- GET(get_url, query = list(
    from_guid = my_from_guid,
    to_guid = my_to_guid,
    num_frames = my_num_frames,
    frame_num = my_frame_num,
    linear="true"),
    use_proxy(proxy_url, port = proxy_port))
  return(response$content)
}

sanity_check()
guid1 <- upload_file_get_guid(str_c(root,"/",filename1))
guid2 <- upload_file_get_guid(str_c(root,"/",filename2))
response_content <- morph_frame_from_guid(guid1,guid2,my_frame_num,my_num_frames)
save_file_name <- str_c(savepath,file_path_sans_ext(filename1),"_to_",file_path_sans_ext(filename2),"_",as.character(my_frame_num),".jpg")
writeBin(response_content, save_file_name)
