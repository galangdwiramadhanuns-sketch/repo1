library(DBI)
library(odbc)

odbcListDrivers()
?dbConnect

dbConnect(odbc(),
          driver = "MySQL ODBC 8.0 ANSI Driver",
          server = "127.0.0.1",
          uid = "root",
          pwd = "21gal09lang06MySQL",
          port = 3306
          )

con1 = dbConnect(odbc(),
                 driver = "MySQL ODBC 8.0 ANSI Driver",
                 server = "127.0.0.1",
                 uid = "root",
                 pwd = "21gal09lang06MySQL",
                 port = 3306
                )

con2 = dbConnect(odbc(),
                 driver = "MySQL ODBC 8.0 ANSI Driver",
                 database = "klinik",
                 server = "127.0.0.1",
                 uid = "root",
                 pwd = "21gal09lang06MySQL",
                 port = 3306
)

?dbListTables
dbListTables(con2)
dbDisconnect(con1)
dbReadTable(con2, "obat")
dbGetQuery(con2, "SELECT stok FROM obat")
dbGetQuery(con2, "DESC obat")
df1 = dbGetQuery(con2, "SELECT * FROM obat") 
View(df1)
summary(df1)
mean(df1$stok)
