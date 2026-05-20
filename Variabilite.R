


#### Variabilité #####


install.packages(c("sp", "sf", "gstat", "ggplot2", "dplyr",
                   "viridis"))

library(sp)        # Classes spatiales (SpatialPointsDataFrame)
library(gstat)     # Variogramme et krigeage
library(ggplot2)   # Graphiques
library(dplyr)     # Manipulation des données
library(viridis)   # Palettes de couleurs perceptuellement uniformes


donnes = read.table('data_jacques.txt', header = T, blank.lines.skip = T)



plot(density(donnes$Z))
polygon(density(donnes$Z), col='goldenrod')



donnees_sp = donnes

coordinates(donnees_sp) <- ~ X + Y


plot(donnees_sp)



vario_exp = variogram(Z~1, data=donnees_sp)

vario_exp_c = variogram(Z~1, data=donnees_sp, cloud=T)
plot(vario_exp_c)

vario_exp


plot(vario_exp)
plot(vario_exp, main = "Variogramme expérimental de Z",
     pch = 19, col = "darkblue", xlab = 'distance (m)')



modele_sph = vgm(psill = 4, model='Sph', range = 5000, nugget = 3)
modele_exp = vgm(psill = 4, model='Exp', range = 5000, nugget = 3)
modele_gau = vgm(psill = 4, model='Gau', range = 5000, nugget = 3)


fit_sph = fit.variogram(vario_exp, modele_sph)
fit_exp = fit.variogram(vario_exp, modele_exp)
fit_gau = fit.variogram(vario_exp, modele_gau)


# Comparaison des SCR
data.frame(
  Modele = c("Sphérique", "Exponentiel", "Gaussien"),
  SCR    = c(attr(fit_sph, "SSErr"),
             attr(fit_exp, "SSErr"),
             attr(fit_gau, "SSErr"))
)


plot(vario_exp, fit_sph, main = 'Sphérique')
plot(vario_exp, fit_exp, main = 'Exponentiel')
plot(vario_exp, fit_gau, main = 'Gaussien')



x_seq = seq(min(donnes$X), max(donnes$X), by = 250 )
y_seq = seq(min(donnes$Y), max(donnes$Y), by = 250 )

grille = expand.grid(X = x_seq, Y = y_seq)

plot(grille, pch='.')

coordinates(grille) <- ~ X + Y

gridded(grille) = TRUE

plot(grille, pch='.', col = 'blue')
plot(donnees_sp, col = 'red', add=T)

krige_res = krige(formula = Z~1,
                  locations = donnees_sp,
                  newdata = grille,
                  model=fit_exp)


spplot(krige_res, 'var1.pred')

spplot(krige_res, 'var1.var')


image(krige_res['var1.pred'], col=terrain.colors(5))

library(automap)

k_automap = autoKrige(Z~1, donnees_sp)

plot(k_automap)




