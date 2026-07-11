MyKajy

Application Flutter de gestion de finances personnelles — propre, rapide, 100% offline.

Fonctionnalités

 — choix de langue (6 langues), thème (Clair, Sombre, Océan, Rose), création de profil avec avatar emoji
 — Dashboard complet: solde actuel, graphique donut par catégorie, transactions récentes
 — Gestion des transactions: ajout, suppression, catégories
 — 100% offline changement locale avec Hive, aucun serveur requis
 — choix de devises: €, $, Ar, £, ₣

Stack technique
Flutter 3.x / Framework UI 
GetX / State management & navigation 
Hive + Hive Flutter / Changement locale
fl_chart / pour les graphiques

Architecture

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── routes/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── onboarding/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── transactions/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart
```

Architecture **Clean Architecture** — séparation stricte domain / data / presentation.


## 📸 Screenshots


| Onboarding | Thèmes | Dashboard |
|---|---|---|
| ![](#) | ![](#) | ![](#) |
