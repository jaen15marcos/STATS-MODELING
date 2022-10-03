library("readxl")
pwt100 <- read_excel("/Users/lourdescortes/Desktop/Marcos Libros/Job Search/Projects/pwt100.xlsx", 3)
library(dplyr)
#getind data from wanted countries
my_range = 1:length(pwt100$country)
data_pwt100 <- tibble()
for (i in my_range){
  if (pwt100$country[i] %in% c("United States", "Brazil", "Mexico", "Colombia", "Argentina", "Canada", "Peru", "Venezuela", "Chile", "Ecuador",
                               "Guatemala",
                               "Bolivia",
                               "Haiti",
                               "Dominican Republic",
                               "Cuba",
                               "Honduras",
                               "Nicaragua",
                               "Paraguay",
                               "El Salvador",
                               "Costa Rica",
                               "Panama",
                               "Uruguay",
                               "Jamaica",
                               "Trinidad and Tobago",
                               "Guyana",
                               "Suriname",
                               "Bahamas",
                               "Belize",
                               "Barbados",
                               "Saint Lucia",
                               "Grenada",
                               "Saint Vincent and the Grenadines",
                               "Antigua and Barbuda",
                               "Dominica",
                               "Saint Kitts and Nevis")){
    data_pwt100 <- rbind(data_pwt100,pwt100[(i),])
  }
}
data_pwt100 <- data_pwt100[ -c(33:39)]
#deliting unwanted col
#write.csv(Your DataFrame,"Path to export the DataFrame\\File Name.csv", row.names = FALSE)
data_pwt100[is.na.data.frame(data_pwt100 )] <- 0
write.csv(data_pwt100,"/Users/lourdescortes/Desktop/Marcos Libros/Job Search/Projects/pwt100_use.csv", row.names = FALSE)