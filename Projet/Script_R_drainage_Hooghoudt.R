# =====================================================================
# Projet Gestion de l'Eau - Dimensionnement du réseau de drainage
# Script d'amorçage R - Formule de Hooghoudt
# =====================================================================
# Objectif : calculer l'espacement L (m) des drains pour chaque zone du
#            champ, à partir des K_sat krigés et d'un coefficient q tiré
#            de la pluviométrie.
#
# Hypothèses :
#   - Drains imposés à z_drain = 1 m de profondeur
#   - Couche imperméable à 3 m sous la surface (D = 2 m sous les drains)
#   - Périmètre humide drain u = 0,2 m
#
# Critères de profondeur de nappe (conventions du projet) :
#   - Strict   (Fraise / Pomme de terre) : nappe >= 0,7 m sous la surface
#                                          -> h = z_drain - 0,7 = 0,3 m
#   - Tolérant (Tomate / Maïs)           : nappe >= 0,5 m sous la surface
#                                          -> h = z_drain - 0,5 = 0,5 m
# =====================================================================

library(readxl)
library(dplyr)
library(zoo)

# ---- 1. Lecture des Ksat krigés par zone -----------------------------
# A remplacer par les MOYENNES GEOMETRIQUES issues de votre krigeage
# (sortie de Script_R_amorcage.R / Rapport_Initial.Rmd)
Ksat_geom <- tibble(
  Zone       = c("Zone_A", "Zone_B", "Zone_C"),
  Ks_cm_j    = c(127.0,    25.0,     6.0),   # à actualiser après krigeage
  Surface_ha = c(1.5,      6.0,      2.5)
)

# ---- 2. Calcul du coefficient de drainage de pointe q ----------------
# Approche : q = P_max,5j / 5  (mm/j) à partir des pluies max sur
# 5 jours glissants
clim  <- read_excel("Donnees_Projet_GE.xlsx", sheet = "03_Climat")
P     <- clim$Pluie_mm
Pmax5 <- max(zoo::rollsum(P, k = 5, fill = 0, align = "right"))
cat(sprintf("Pluie maximale sur 5 jours : %.1f mm\n", Pmax5))

q_mmj <- Pmax5 / 5                   # coefficient de drainage (mm/j)
q     <- q_mmj / 1000                # conversion en m/j
cat(sprintf("Coefficient de drainage retenu : q = %.1f mm/j = %.5f m/j\n\n",
            q_mmj, q))

# ---- 3. Formule de Hooghoudt simplifiée (initialisation d = D) -------
# L^2 = 4 K h (2 d + h) / q
hooghoudt_L <- function(K_mj, h, d, q) {
  sqrt(4 * K_mj * h * (2 * d + h) / q)
}

# Hypothèses géotechniques (cf. feuille 06_Parametres_drainage)
z_drain <- 1.0     # m, profondeur d'installation des drains
D       <- 2.0     # m, épaisseur sous les drains jusqu'à l'imperméable
u       <- 0.2     # m, périmètre humide du drain
alpha_v <- 1.15    # coefficient van Beers

# ---- 4. Critères de profondeur de nappe ------------------------------
criteres <- tibble(
  Critere  = c("Strict (Fraise / PdT) - nappe >= 0,7 m",
               "Tolerant (Tomate / Mais) - nappe >= 0,5 m"),
  WT_cible = c(0.7, 0.5),                       # m, sous la surface
  h        = z_drain - c(0.7, 0.5)              # m, au-dessus des drains
)
print(criteres)

# ---- 5. Calcul de L pour 3 zones x 2 critères (initialisation) -------
res <- expand.grid(Zone    = Ksat_geom$Zone,
                   Critere = criteres$Critere,
                   stringsAsFactors = FALSE) %>%
  left_join(Ksat_geom, by = "Zone") %>%
  left_join(criteres,  by = "Critere") %>%
  mutate(K_mj   = Ks_cm_j / 100,
         L_init = hooghoudt_L(K_mj, h, D, q))

cat("\n=== Espacements L (m) - première estimation (d ~ D) ===\n")
print(res %>% select(Zone, Critere, Ks_cm_j, h, L_init) %>%
        mutate(L_init = round(L_init, 1)))

# ---- 6. Itération sur d (profondeur équivalente de Hooghoudt) --------
# Formule de van Beers : d = D / (1 + (D/L) * (8/pi * ln(D/u) - alpha))
hooghoudt_d <- function(L, D, u = 0.2, alpha = 1.15) {
  D / (1 + (D / L) * (8 / pi * log(D / u) - alpha))
}

res$L_iter <- res$L_init
for (i in 1:5) {
  res$d_eq   <- hooghoudt_d(res$L_iter, D, u, alpha_v)
  res$L_iter <- hooghoudt_L(res$K_mj, res$h, res$d_eq, q)
}
res$L_iter <- round(res$L_iter, 1)
res$d_eq   <- round(res$d_eq, 2)

cat("\n=== Résultats après itération sur d (van Beers) ===\n")
print(res %>% select(Zone, Critere, Ks_cm_j, h, d_eq, L_iter))

# ---- 7. Linéaire total de drains par zone ----------------------------
# Pour une parcelle rectangulaire, le linéaire (m/ha) ~ 10 000 / L (m)
res$lineaire_m_par_ha <- round(10000 / res$L_iter, 0)
res$drains_par_zone   <- ceiling(res$Surface_ha * res$lineaire_m_par_ha)

cat("\n=== Linéaire de drains à installer ===\n")
print(res %>% select(Zone, Critere, Surface_ha, L_iter,
                     lineaire_m_par_ha, drains_par_zone))

# ---- 8. Export -------------------------------------------------------
write.csv(res, "drainage_Hooghoudt_resultats.csv", row.names = FALSE)
cat("\nFichier exporté : drainage_Hooghoudt_resultats.csv\n")

# ---- 9. Sensibilité de L à K (+/- 30 %) ------------------------------
cat("\n=== Sensibilité de L à K (+/- 30 %) -- critère tolérant ---\n")
crit_use <- "Tolerant (Tomate / Mais) - nappe >= 0,5 m"
for (z in Ksat_geom$Zone) {
  K     <- Ksat_geom$Ks_cm_j[Ksat_geom$Zone == z] / 100
  Lmoy  <- hooghoudt_L(K,        0.5, D, q)
  Lbas  <- hooghoudt_L(K * 0.7,  0.5, D, q)
  Lhaut <- hooghoudt_L(K * 1.3,  0.5, D, q)
  cat(sprintf("  %s : L = %.1f m (intervalle %.1f - %.1f m)\n",
              z, Lmoy, Lbas, Lhaut))
}

# ---- 10. Sensibilité de L à q (+/- 50 %) -----------------------------
cat("\n=== Sensibilité de L à q (+/- 50 %) -- critère tolérant ---\n")
for (z in Ksat_geom$Zone) {
  K     <- Ksat_geom$Ks_cm_j[Ksat_geom$Zone == z] / 100
  Lmoy  <- hooghoudt_L(K, 0.5, D, q)
  Lbas  <- hooghoudt_L(K, 0.5, D, q * 1.5)   # q +50 % -> L diminue
  Lhaut <- hooghoudt_L(K, 0.5, D, q * 0.5)   # q -50 % -> L augmente
  cat(sprintf("  %s : L = %.1f m (intervalle %.1f - %.1f m)\n",
              z, Lmoy, Lbas, Lhaut))
}
