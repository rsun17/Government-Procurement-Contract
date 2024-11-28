df <- read.csv("C:/Users/flora/Dropbox/RA- Flora Gu/Data/03-prepare data - type & merge.csv")
names(df)[names(df) == "open"] <- "y"
names(df)[names(df) == "logdistance"] <- "x"

x<-df$x
y<-df$y

require(rdrobust)
## Loading required package: rdrobust
## Warning: package 'rdrobust' was built under R version 4.3.1
require(ggplot2)
## Loading required package: ggplot2


linear_fit<-rdplot(y,x, p=1)


quadratic_fit<-rdplot(y,x, p=2)


linear_data<-linear_fit$vars_poly
linear_data$group<-ifelse(linear_data$rdplot_x<0,1,
                          ifelse(linear_data$rdplot_x>0,2,NA))
linear_data<-na.omit(linear_data)

quadratic_data<-quadratic_fit$vars_poly
quadratic_data$group<-ifelse(quadratic_data$rdplot_x<0,1,
                             ifelse(quadratic_data$rdplot_x>0,2,NA))
quadratic_data<-na.omit(quadratic_data)

ggplot()+
  geom_point(data=df, aes(x=x, y=y), color="grey", alpha=0.1)+
  geom_line(data=linear_data,
            aes(x=rdplot_x, y=rdplot_y, group=factor(group), linetype="linear",
                color="linear"))+
  geom_line(data=quadratic_data,
            aes(x=rdplot_x, y=rdplot_y, group=factor(group),
                linetype="quadratic",color="quadratic"))+
  scale_color_manual("Fit", values=c("linear"="maroon", "quadratic"="seagreen"))+
  scale_linetype_manual("Fit", values=c("linear"=2, "quadratic"=1))+
  geom_vline(aes(xintercept=0))+
  theme_minimal()
