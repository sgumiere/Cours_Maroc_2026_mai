# Cours — Gestion de l'eau agricole

**Maroc, Mai 2026 (deux semaines)**
**Intervenant :** Silvio Gumiere, Ph.D. — Université Laval (Québec, Canada)
**Contact :** sjgum@ulaval.ca

Ce dépôt contient l'ensemble du matériel pédagogique du cours :
présentations, données, codes R, exercices corrigés et lectures
de référence. Le cours s'étale sur **deux semaines** et couvre
l'irrigation de précision, la physique des sols, l'analyse hydrique
des sols, la géostatistique appliquée et la télédétection optique
pour l'agriculture.

> **Dépôt vivant** — ce matériel est **complété au fur et à mesure
> que le cours avance**. De nouveaux fichiers (exercices, jeux de
> données, scripts, diaporamas) sont ajoutés chaque jour. Pensez à
> faire un *pull* / une synchronisation Dropbox quotidienne pour
> disposer de la version la plus à jour.

---

## Objectifs pédagogiques

À l'issue du cours, les participants seront capables de :

- caractériser le comportement hydrique d'un sol agricole (rétention,
  conductivité, RU/RFU) ;
- mesurer et interpréter l'humidité du sol par méthodes gravimétrique,
  neutronique, TDR et capacitive ;
- ajuster un modèle de rétention de van Genuchten sur des données
  expérimentales et simuler un transfert d'eau 1D dans Hydrus-1D ;
- traiter des données spatiales et effectuer une interpolation par
  krigeage sous R (`gstat`) ;
- calculer des indices de végétation (NDVI, NDRE…) à partir d'images
  Sentinel-2 et les utiliser pour piloter une irrigation de précision.

---

## Pré-requis logiciels

Tous les TP sont réalisés sous **R / RStudio**. Installer également :

- **R** ≥ 4.3 et **RStudio** ([CRAN](https://cran.r-project.org/),
  [RStudio Desktop](https://posit.co/download/rstudio-desktop/))
- Paquets R utilisés : `rmarkdown`, `knitr`, `nls`, `gstat`, `sp`, `sf`,
  `terra`, `raster`, `ggplot2`, `dplyr`
- **Hydrus-1D 4.17** (binaire Windows fourni dans `jour_2_3/`)
- Un compte **Copernicus / Sentinel Hub** pour le téléchargement
  d'images Sentinel-2 (jour 5)

Installation des paquets R en une commande :

```r
install.packages(c("rmarkdown", "knitr", "gstat", "sp", "sf",
                   "terra", "raster", "ggplot2", "dplyr"))
```

---

## Plan du cours et structure du dépôt

### Jour 1 — Introduction, irrigation de précision, initiation R

Dossier : `jour_1/`

| Fichier | Description |
|---|---|
| `0.Silvio_Gumiere_Domaines_Recherche_ULaval.pptx` | Présentation de l'intervenant et de l'équipe ULaval |
| `1.irrigation_precision_complete.pptx` | Cours magistral — Irrigation de précision |
| `2.initiation_R_RStudio.pptx` | Prise en main de R et RStudio |
| `3.Rekika2014_Irrigation_Histosols.pptx` | Étude de cas — Oignon, céleri et épinard sur histosols |
| `4.Gumiere2014_Cartographie_Canneberge.pptx` | Étude de cas — Cartographie pour la canneberge |
| `Agronomy Journal - 2014 - Rekika...pdf` | Article de référence (Rekika *et al.*, 2014) |
| `meteo_test.txt` | Jeu de données météo pour les premiers exercices R |

### Jours 2 et 3 — Physique du sol et bilan hydrique

Dossier : `jour_2_3/`

| Fichier | Description |
|---|---|
| `1.intro_Irrigation.pptx` | Rappels — pourquoi irriguer, où, quand, combien |
| `2.Soil Physics I.pptx` | Physique du sol I — texture, structure, porosité |
| `2.1.soil_moisture_determination.pptx` | Méthodes de mesure de l'humidité (gravimétrie, neutron, TDR, capacitive) |
| `3.Soil Physics II.pptx` | Physique du sol II — rétention, conductivité, van Genuchten |
| `Physique_hydrodynamique_sol.pdf` | Polycopié de référence |
| `Hydrus1D_4.17.0140 (1).exe.zip` | Installateur Hydrus-1D (Windows) |
| `exercices_cours_2_partie_1.Rmd` / `.html` | Exercices — Réserve en eau, van Genuchten, RU/RFU, hystérèse |
| `exercices_cours_2_partie_1_slides.Rmd` / `.html` | Diaporama ioslides — énoncés et données seuls |
| `exercices_cours_2_partie_2.Rmd` / `.html` | Exercices — partie 2 |
| `exercices_cours_2_partie_3.Rmd` / `.html` | Exercices — partie 3 |

### Jour 4 — Bilan hydrique et pilotage de l'irrigation

Dossier : `jour_4/`

| Fichier | Description |
|---|---|
| `exercices_cours_3_partie_1.Rmd` / `.html` | Exercices — bilan hydrique et pilotage |

### Jour 5 — Géostatistique et télédétection

Dossier : `jour_5/`

| Fichier | Description |
|---|---|
| `tp_gstat_meuse.Rmd` / `.md` / `.html` | TP de krigeage avec `gstat` sur le jeu de données *Meuse* |
| `sentinel2_indices_R.pptx` | Indices de végétation à partir de Sentinel-2 |
| `sentinel2_quebec.R` | Script R — téléchargement et calcul d'indices Sentinel-2 (cas du Québec) |

### Documents à la racine

| Fichier | Description |
|---|---|
| `cours_2_Silvio (1).pdf` | Notes manuscrites annotées du cours 2 |
| `gstat.pdf` | Documentation de référence du paquet `gstat` |
| `data_jacques.txt` | Jeu de données partagé pour les TP transversaux |

---

## Comment utiliser ce matériel

1. **Avant le cours**, installer R, RStudio et les paquets listés
   ci-dessus.
2. **Pour chaque journée**, ouvrir d'abord les `.pptx` correspondant
   aux concepts théoriques, puis lancer le `.Rmd` d'exercices
   associé dans RStudio.
3. **Compiler un `.Rmd`** en HTML avec :

    ```r
    rmarkdown::render("exercices_cours_2_partie_1.Rmd")
    ```

   ou directement depuis le bouton **Knit** de RStudio.
4. Les `.html` déjà compilés permettent une **consultation rapide**
   sans relancer R.

---

## Conventions du dépôt

- Les fichiers commencent par un **chiffre** indiquant l'ordre de
  présentation (`0.`, `1.`, `2.`, …).
- Les exercices suivent la nomenclature
  `exercices_cours_<N>_partie_<P>.Rmd`.
- Les jeux de données sont en `.txt` ou `.csv`, encodés en UTF-8.
- Les diaporamas R Markdown se terminent par `_slides.Rmd` et sont au
  format **ioslides** (HTML).

---

## Licence et citation

Matériel pédagogique fourni à des fins de formation. Pour toute
réutilisation dans une autre formation, merci de citer :

> Gumiere, S. (2026). *Cours de gestion de l'eau agricole — Maroc,
> mai 2026.* Université Laval, Québec, Canada.

---

## Remerciements

Merci aux participants marocains, à l'équipe organisatrice locale et
au laboratoire d'hydrologie agricole de l'Université Laval pour la
préparation du matériel.
