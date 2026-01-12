# Find R path and write to file
r_info <- list(
    R_HOME = Sys.getenv("R_HOME"),
    R_path = file.path(R.home("bin"), "Rscript.exe"),
    R_version = R.version.string
)

# Write to workspace
info_file <- "c:/Code/trade_updated/data_exploration/output/r_info.txt"
writeLines(c(
    paste("R_HOME:", r_info$R_HOME),
    paste("R_path:", r_info$R_path),
    paste("R_version:", r_info$R_version)
), info_file)

message("R info written to: ", info_file)
print(r_info)
