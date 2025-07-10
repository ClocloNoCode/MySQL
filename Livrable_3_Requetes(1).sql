/*

Livrable 3 - Requetes SQL

S2.04: Exploitation d’une base de données

NOMS Prénoms : MILLE Raphael, Mathéo BIET, Clovis BOURRE
Groupe: C2

*/


-- Jointure Interne
-- Pour les compteurs ayant un quartier, afficher le libellé et le nom du quartier
SELECT libelle, nomQuartier
FROM Compteur
JOIN Quartier ON leQuartier = code;

-- 52 Tuples
/* 5 premiers tuples:
Bonduelle vers Nord	Centre Ville
Calvaire vers Est	Centre Ville
Pont Audibert vers Sud	Centre Ville
Stalingrad vers est	Malakoff - Saint-Donatien
Bd Malakoff vers Gare Sud	Malakoff - Saint-Donatien
*/

-- Auto Jointure
-- Afficher les quartiers (le nom) qui ont la même longueur de piste

SELECT Q1.nomQuartier, Q2.nomQuartier
FROM Quartier Q1, Quartier Q2
WHERE Q1.code != Q2.code
AND Q1.longueurPiste = Q2.longueurPiste;

-- Aucun Tuple

-- Jointure Externe n°1
-- Pour chaque compteur (nomQuartier), afficher le nombre de comptages effectués (éventuellement 0)

SELECT idCompteur, COUNT(Comptage.leCompteur) AS nombreComptages
FROM Compteur
LEFT JOIN Comptage ON Compteur.idCompteur = Comptage.leCompteur
GROUP BY idCompteur;

-- 58 Tuples
/* 5 premiers tuples:
89	0
664	1117
665	1117
666	1117
667	1117
*/

-- Jointure Externe n°2
-- Pour chaque quartier, afficher le nombre de compteurs (éventuellement 0)

SELECT Quartier.nomQuartier, COUNT(Compteur.idCompteur) AS nombreCompteurs
FROM Quartier
LEFT JOIN Compteur ON Quartier.code = Compteur.leQuartier
GROUP BY Quartier.nomQuartier;

-- 18 Tuples
/* 5 premiers tuples:
Bellevue - Chantenay - Sainte Anne	0
Blordière	0
Breil - Barberie	0
Centre Ville	22
Château de Rezé	0
Dervallières - Zola	1
*/

-- Sous-requête n°1 (IN)
-- Quels sont les différents compteurs (libelle) des quatiers de Nantes

SELECT libelle
FROM Compteur
WHERE leQuartier IN ( 
    SELECT code
    FROM Quartier
    WHERE UPPER(nomQuartier) LIKE "%NANTES%"
);

-- 10 Tuples
/* 5 premiers tuples:
Pont de Pirmil vers Sud
Guy Mollet vers Nord
Guy Mollet vers Sud
De Gaulle vers sud
Entrée pont Audibert vers Nord
*/

-- Sous-requête n°2 (NOT IN)
-- Quels sont les jours des vacances de 2022
SELECT DISTINCT date
FROM Date
WHERE date BETWEEN '2022-01-01' AND '2022-12-31'
AND date NOT IN (
    SELECT date
    FROM Date
    WHERE vacances = 'Hors Vacances'
);

-- 123 Tuples
/* 5 premiers tuples:
2022-01-01
2022-01-02
2022-02-05
2022-02-06
2022-02-07
*/

-- Sous-requête n°3 (EXISTS)
-- Les quartiers qui ont une/des probabilitée(s) d'anomalie(s) faible
SELECT nomQuartier
FROM Quartier 
WHERE EXISTS (
	SELECT *
	FROM Compteur 
   	JOIN  Comptage ON idCompteur = leCompteur
    WHERE leQuartier = code AND UPPER(probabiliteAnomalie) = 'FAIBLE'
);

-- 9 Tuples
/* 5 premiers tuples:
Centre Ville
Dervallières - Zola
Hauts Pavés - Saint Félix
Malakoff - Saint-Donatien
Ile de Nantes
*/

-- Sous-requête n°4 (NOT EXISTS)
-- Les quartiers qui n'ont pas de compteur avec plus de 1000 vélos

SELECT nomQuartier
FROM Quartier
WHERE NOT EXISTS (
    SELECT *
    FROM Compteur
    JOIN Comptage ON idCompteur = leCompteur
    WHERE leQuartier = code
    AND nbVelo > 1000
);

-- 12 Tuples
/* 5 premiers tuples:
Bellevue - Chantenay - Sainte Anne
Breil - Barberie
Nantes Nord
Nantes Erdre
Doulon - Bottière
*/

-- Fonction de groupe sans regroupement n°1 (SUM)
-- Afficher le nombre total de vélos comptés entre le 1er janvier 2020 et le 24 janvier 2023

SELECT SUM(nbVelo)
FROM Comptage
JOIN Date ON laDate = date
WHERE date >= "01/01/2020" AND date <= "24/01/2023"

-- 35192026

-- Fonction de groupe sans regroupement n°2 (AVG)
-- Quel est le nombre de vélos moyen comptés par jour lorsque la température moyenne est supérieure à 20°C
SELECT AVG(nbVelo)
FROM Comptage
JOIN Date ON laDate = date
WHERE tempMoyenne > 20;

-- 748.772907900888

-- Regroupement avec fonction de groupe n°1
-- Afficher le nombre total de vélos comptés par jour de la semaine
SELECT jourSemaine, SUM(nbVelo) AS totalVelos
FROM Comptage
JOIN Date ON laDate = date
GROUP BY jourSemaine;

-- 7 Tuples
/* 5 premiers tuples:
1	5436906
2	6204235
3	5888499
4	6117228
5	5515587
*/

-- Regroupement avec fonction de groupe n°2
-- Afficher le nombre de probabilité d'anomalies forte par quartier s'il y en a

SELECT nomQuartier, COUNT(*) AS nbAnomaliesFortes
FROM Quartier
LEFT JOIN Compteur ON code = leQuartier
LEFT JOIN Comptage ON idCompteur = leCompteur
WHERE UPPER(probabiliteAnomalie) = 'FORTE'
GROUP BY nomQuartier;

-- 9 Tuples
/* 5 premiers tuples:
Centre Ville	505
Dervallières - Zola	114
Hauts Pavés - Saint Félix	44
Ile de Nantes	102
Malakoff - Saint-Donatien	799
*/

-- Regroupement et restriction n°1
-- La moyenne de vélos par compteur pour les compteurs ayant compté plus de 800 vélos en moyenne
SELECT leCompteur, AVG(nbVelo) AS moyenneVelo
FROM Comptage
GROUP BY leCompteur
HAVING AVG(nbVelo) > 800;

-- 11 Tuples
/* 5 premiers tuples:
667	1753.42435094002
742	961.993733213966
743	876.626678603402
785	2075.39928379588
786	2052.55505819158
*/

-- Regroupement et restriction n°2
-- Afficher les quartiers ayant eu un total de plus de 500 000 vélos comptés, ordonner par ordre décroissant de vélos comptés
SELECT nomQuartier, SUM(nbVelo) AS totalVelo
FROM Quartier
JOIN Compteur ON code = leQuartier
JOIN Comptage ON idCompteur = leCompteur
GROUP BY nomQuartier
HAVING SUM(nbVelo) > 500000
ORDER BY totalVelo DESC;

-- 7 Tuples
/* 5 premiers tuples:
Centre Ville	20084080
Ile de Nantes	6106186
Malakoff - Saint-Donatien	2618402
Nantes Sud	2524352
Hauts Pavés - Saint Félix	2163205
*/

-- Division n°1 (Division normale)
-- Afficher les compteurs (libelle) qui ont des comptages pour chaque jour des Vacances d'été
SELECT DISTINCT libelle
FROM Compteur
WHERE NOT EXISTS (
    SELECT date
    FROM Date
    WHERE vacances = 'Vacances d''été'
    EXCEPT
    SELECT DISTINCT laDate
    FROM Comptage
    WHERE leCompteur = Compteur.idCompteur
);

-- 41 Tuples
/* 5 premiers tuples:
Bonduelle vers Nord
Calvaire vers Est
Pont Audibert vers Sud
Stalingrad vers est
Bd Malakoff vers Gare Sud
*/

-- Division n°2 (Division exacte)
-- Quels les compteurs (libelle) qui ont uniquement des comptages pour chaque jour des Vacances d'été
SELECT DISTINCT libelle
FROM Compteur
WHERE NOT EXISTS (
    SELECT date
    FROM Date
    WHERE vacances = 'Vacances d''été'
    EXCEPT
    SELECT DISTINCT laDate
    FROM Comptage
    WHERE leCompteur = Compteur.idCompteur
)
AND NOT EXISTS (
    SELECT DISTINCT laDate
    FROM Comptage
    WHERE leCompteur = Compteur.idCompteur
    EXCEPT
    SELECT date
    FROM Date
    WHERE vacances = 'Vacances d''été'
);

-- 0 Tuples

-- Vue pour gérer des contraintes n°1
-- Vérifier si chaque quartier a au moins un compteur
CREATE OR REPLACE VIEW vue_QuartierSansCompteur
AS
SELECT code, nomQuartier
FROM Quartier
WHERE NOT EXISTS (
    SELECT *
    FROM Compteur
    WHERE leQuartier = code
);
SELECT * FROM vue_QuartierSansCompteur;

-- 8 Tuples
/* 5 premiers tuples:
2	Bellevue - Chantenay - Sainte Anne
7	Breil - Barberie
9	Nantes Erdre
14301	Trentemoult
14302	Hôtel de Ville
*/

-- Vue pour gérer des contraintes n°2
-- Vérifier si un compteur n'a aucun comptage
CREATE OR REPLACE VIEW vue_CompteurSansComptage
AS
SELECT idCompteur, libelle
FROM Compteur
WHERE NOT EXISTS (
    SELECT *
    FROM Comptage
    WHERE leCompteur = idCompteur
);
SELECT * FROM vue_CompteurSansComptage;

-- 8 Tuples
/* 5 premiers tuples:
699	Coteaux vers Est
700	Promenade de Bellevue vers Ouest
89	Coteaux vers Ouest
1031	VN751A Vers St Leger les Vignes
907	Stade vers Est
*/

-- Vue pour gérer des informations dérivables n°1
-- La date du dernier comptage 
CREATE OR REPLACE VIEW vue_DernierComptage
AS
SELECT MAX(laDate) AS dateDernierComptage
FROM Comptage;
SELECT * FROM vue_DernierComptage;

-- 1 Tuple
/* Contenu :
2023-01-24
*/

-- Vue pour gérer des informations dérivables n°2
-- Pour chaque quartier ayant au moins une mesure, afficher le minimum, le maximum et la moyenne du nombre de vélos comptés
CREATE OR REPLACE VIEW vue_StatistiquesQuartier
AS
SELECT nomQuartier, MIN(nbVelo) AS nbVeloMin, MAX(nbVelo) AS nbVeloMax, AVG(nbVelo) AS nbVeloMoy
FROM Quartier
JOIN Compteur ON code = leQuartier
JOIN Comptage ON idCompteur = leCompteur
GROUP BY nomQuartier;
SELECT * FROM vue_StatistiquesQuartier;

-- 9 Tuples
/* 5 premiers tuples:
Centre Ville	0	40465	817.555971668159
Dervallières - Zola	0	2588	761.945193171608
Hauts Pavés - Saint Félix	0	1405	484.155102954342
Ile de Nantes	0	4012	911.099074903014
Malakoff - Saint-Donatien	0	32924	260.45976325475
*/



