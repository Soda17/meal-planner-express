-- =========================================================
-- Meal Planner Express - Script d'initialisation PostgreSQL
-- =========================================================

-- On supprime la table si elle existe déjà (pratique en dev)
DROP TABLE IF EXISTS recettes;

CREATE TABLE recettes (
    id                SERIAL PRIMARY KEY,
    nom               VARCHAR(150) NOT NULL,
    categorie         VARCHAR(50)  NOT NULL,      -- ex: 'Viande', 'Poisson', 'Végétarien'
    origine           VARCHAR(100) NOT NULL,     -- ex: 'Sénégal', 'France'
    difficulte        VARCHAR(50)  NOT NULL,      -- ex: 'Facile', 'Moyen', 'Difficile'
    temps_preparation INTEGER      NOT NULL,       -- en minutes
    calories          INTEGER      NOT NULL DEFAULT 0,
    portions          INTEGER      NOT NULL DEFAULT 4 CHECK (portions > 0),
    cout_estime       NUMERIC(5,2) NOT NULL CHECK (cout_estime > 0), -- Coût estimé en Euros (€)
    image             TEXT         NOT NULL,
    tags              JSONB        NOT NULL DEFAULT '[]'::jsonb,
    ingredients       JSONB        NOT NULL DEFAULT '[]'::jsonb,
    instructions      TEXT         NOT NULL,
    created_at        TIMESTAMP    DEFAULT NOW()
);

-- Jeu de données de test : Les recettes du Sénégal
INSERT INTO recettes (
    nom, categorie, origine, difficulte, temps_preparation, 
    calories, portions, cout_estime, image, tags, ingredients, instructions
) VALUES 
( 
    'Poulet Yassa Impérial', 
    'Viande', 
    'Sénégal', 
    'Moyen', 
    105, 
    650, 
    4, 
    14.50, 
    'images/yassa.jpg',
    '["Africain", "Traditionnel", "Citronné", "Roff Maison"]'::jsonb,
    '[
        {"nom": "Poulet entier ou cuisses", "quantite": 1500, "unite": "g"},
        {"nom": "Oignons", "quantite": 850, "unite": "g"},
        {"nom": "Citron vert", "quantite": 1, "unite": "pièce"},
        {"nom": "Citrons jaunes", "quantite": 2, "unite": "pièces"},
        {"nom": "Piment frais", "quantite": 1, "unite": "pièce"},
        {"nom": "Feuille de laurier", "quantite": 1, "unite": "pièce"},
        {"nom": "Huile de cuisson", "quantite": 125, "unite": "ml"},
        {"nom": "Huile d''olive", "quantite": 2, "unite": "c.à.s"},
        {"nom": "Eau", "quantite": 200, "unite": "ml"},
        {"nom": "Gousses d''ail", "quantite": 6, "unite": "pièces"},
        {"nom": "Poivron rouge", "quantite": 1, "unite": "pièce"},
        {"nom": "Piments végétariens", "quantite": 2, "unite": "pièces"},
        {"nom": "Coriandre fraîche", "quantite": 1, "unite": "poignée"},
        {"nom": "Moutarde de Dijon", "quantite": 1, "unite": "c.à.s"},
        {"nom": "Sel et poivre", "quantite": 1, "unite": "pincée"}
    ]'::jsonb,
    '1. Laver le poulet à l''eau, le frotter avec un demi-citron vert et le rincer.
2. Préparer la marinade (Roff) : hacher l''ail, l''oignon cébette, la coriandre, le poivron et le piment végétarien. Réserver 1/3 de ce mélange pour la sauce.
3. Aux 2/3 restants, ajouter le jus des 2 citrons, du sel, du poivre et 2 c.à.s d''huile d''olive.
4. Inciser le poulet et le farcir avec ce Roff. Badigeonner le reste sur la viande et laisser mariner 2 heures au frais.
5. Badigeonner le poulet d''une c.à.s de moutarde et faire griller au four à 220°C pendant 40 minutes (retourner à mi-cuisson).
6. Pour la sauce : émincer les oignons, les faire suer dans l''huile avec le laurier dans une cocotte jusqu''à coloration caramel.
7. Ajouter le 1/3 de marinade réservé, le jus du citron restant, l''eau et le piment frais entier. Mijoter 15 minutes à feu doux.
8. Plonger le poulet grillé dans la sauce, mélanger et laisser mijoter 10 minutes supplémentaires. Servir chaud avec du riz blanc.'
),
(
    'Thiéboudienne (Riz au poisson)', 
    'Poisson', 
    'Sénégal', 
    'Difficile', 
    110, 
    720, 
    6, 
    22.50, 
    'images/thieboudieune.png', 
    '["Africain", "Traditionnel", "Poisson", "Riz Rouge"]'::jsonb,
    '[
        {"nom": "Riz", "quantite": 1000, "unite": "g"},
        {"nom": "Poisson (thiof ou mérou)", "quantite": 1500, "unite": "g"},
        {"nom": "Poivrons (rouge et vert)", "quantite": 2, "unite": "pièces"},
        {"nom": "Tomates cerises", "quantite": 200, "unite": "g"},
        {"nom": "Concentré de tomate", "quantite": 4, "unite": "c.à.s"},
        {"nom": "Oignons", "quantite": 3, "unite": "pièces"},
        {"nom": "Aubergine", "quantite": 1, "unite": "pièce"},
        {"nom": "Chou", "quantite": 1, "unite": "pièce"},
        {"nom": "Carottes", "quantite": 3, "unite": "pièces"},
        {"nom": "Manioc", "quantite": 1, "unite": "pièce"},
        {"nom": "Gombos", "quantite": 5, "unite": "pièces"},
        {"nom": "Piments frais", "quantite": 2, "unite": "pièces"},
        {"nom": "Piments secs", "quantite": 3, "unite": "pièces"},
        {"nom": "Botte de persil", "quantite": 1, "unite": "pièce"},
        {"nom": "Gousses d''ail", "quantite": 5, "unite": "pièces"},
        {"nom": "Guedj (poisson séché)", "quantite": 1, "unite": "pièce"},
        {"nom": "Yet (mollusque)", "quantite": 1, "unite": "pièce"},
        {"nom": "Huile de cuisson", "quantite": 20, "unite": "cl"},
        {"nom": "Sel", "quantite": 1, "unite": "pincée"}
    ]'::jsonb,
    '1. Réussir le rissolé ("rossi") : Couper l''oignon et la moitié du poivron en dés et un piment en 2. Écraser les tomates cerises, ajouter le concentré de tomate et diluer avec 3 c.à.s d''eau. Chauffer 20 cl d''huile dans une marmite, ajouter l''oignon, le poivron, le piment coupé, le yett et le mélange de tomate. Saler. Laisser rissoler jusqu''à obtenir une couleur rouge foncé sans brûler. Ajouter 1,5L d''eau quand l''huile remonte, puis ajouter les légumes (carottes, aubergine, chou, manioc, gombos, piment).
2. Préparer le Roof (la farce) : Piler le persil avec 2 ou 3 piments, 3 gousses d''ail et du sel. Faire un trou dans la chair du poisson propre et farcir de roof. Ajouter les poissons un à un dans le bouillon de la marmite (sans les frire).
3. Préparer le nokoss (l''assaisonnement) : Hacher 1 oignon, 1 poivron, 1 petit piment sec et du sel. Incorporer une partie du nokoss à la préparation, couvrir partiellement et laisser mijoter doucement 1 heure.
4. Préparer le riz : Laver le riz 3 fois. Enlever les légumes et les poissons de la marmite et les réserver. Précuire le riz à la vapeur 15 minutes. Ajouter le reste du nokoss dans la marmite, rectifier le sel. Diminuer le bouillon par précaution puis incorporer le riz (le liquide doit juste recouvrir le riz). Couvrir, réduire le feu et laisser cuire en retournant le riz après 15 minutes, puis toutes les 10 minutes jusqu''à cuisson complète.'
),

(
    'Poulet Braisé à l''Attiéké', 
    'Viande', 
    'Côte d''Ivoire', 
    'Moyen', 
    75, 
    580, 
    4, 
    13.20, 
    'images/athieke.png', 
    '["Ivoirien", "Grillade", "Attiéké", "Street Food", "Sauce Oignons"]'::jsonb,
    '[
        {"nom": "Cuisses de poulet", "quantite": 4, "unite": "pièces"},
        {"nom": "Attiéké (semoule de manioc)", "quantite": 500, "unite": "g"},
        {"nom": "Oignons", "quantite": 3, "unite": "pièces"},
        {"nom": "Moutarde de Dijon", "quantite": 2, "unite": "c.à.s"},
        {"nom": "Jus de citron", "quantite": 3, "unite": "c.à.s"},
        {"nom": "Gousses d d''ail", "quantite": 4, "unite": "pièces"},
        {"nom": "Gingembre frais râpé", "quantite": 1, "unite": "c.à.s"},
        {"nom": "Huile d d''olive", "quantite": 4, "unite": "c.à.s"},
        {"nom": "Cube de bouillon végétal", "quantite": 1, "unite": "pièce"},
        {"nom": "Tomate", "quantite": 1, "unite": "pièce"},
        {"nom": "Concombre", "quantite": 0.5, "unite": "pièce"},
        {"nom": "Piment frais", "quantite": 1, "unite": "pièce"}
    ]'::jsonb,
    '1. Préparer la marinade : Mixer l''ail, le gingembre, le cube de bouillon, la moutarde, 1 cuillère à soupe de jus de citron et 2 cuillères à soupe d''huile d''olive. 
2. Faire de profondes incisions sur les cuisses de poulet, les badigeonner généreusement avec cette marinade et laisser reposer au frais pendant au moins 2 heures.
3. Préchauffer le four à 200°C. Enfourner le poulet pour 40 à 45 minutes en le retournant à mi-cuisson jusqu''à ce qu''il soit bien doré et croustillant.
4. Préparer la sauce express aux oignons : Émincer finement 2 oignons. Dans une poêle avec le reste de l''huile, faire suer les oignons à feu moyen avec une touche de moutarde et de jus de citron jusqu''à ce qu''ils soient tendres et légèrement caramélisés.
5. Préparer l''accompagnement frais : Couper en petits dés la tomate, le concombre et le dernier oignon.
6. Humidifier légèrement l''attiéké et le faire chauffer à la vapeur pendant 5 à 10 minutes.
7. Servir le poulet braisé chaud sur un lit d''attiéké, nappé de sauce aux oignons et accompagné des crudités fraîches et du piment.'
),

(
    'Pastels au Thon et Sauce Piquante', 
    'Poisson', 
    'Sénégal', 
    'Moyen', 
    60, 
    620, 
    4, 
    9.80, 
    'images/passtel.jpg', 
    '["Sénégalais", "Beignets", "Poisson", "Thon", "Chausson"]'::jsonb,
    '[
        {"nom": "Farine", "quantite": 500, "unite": "g"},
        {"nom": "Beurre fondu", "quantite": 100, "unite": "g"},
        {"nom": "Eau tiède", "quantite": 200, "unite": "ml"},
        {"nom": "Levure chimique", "quantite": 1, "unite": "sachet"},
        {"nom": "Thon en boîte entier", "quantite": 300, "unite": "g"},
        {"nom": "Oignons", "quantite": 3, "unite": "pièces"},
        {"nom": "Concentré de tomate", "quantite": 2, "unite": "c.à.s"},
        {"nom": "Gousses d d''ail", "quantite": 2, "unite": "pièces"},
        {"nom": "Huile de friture", "quantite": 50, "unite": "cl"},
        {"nom": "Piment en poudre", "quantite": 1, "unite": "c.à.c"},
        {"nom": "Sel et poivre", "quantite": 1, "unite": "pincée"}
    ]'::jsonb,
    '1. Préparer la pâte : Dans un grand récipient, mélanger la farine, la levure chimique et une pincée de sel. Sabler le mélange en ajoutant le beurre fondu, puis incorporer doucement l''eau tiède. Pétrir jusqu''à obtenir une pâte lisse, souple et homogène. Couvrir et laisser reposer 30 minutes.
2. Préparer la farce au thon : Émincer finement 2 oignons et écraser 1 gousse d''ail. Les faire suer dans une poêle avec un filet d''huile. Ajouter le thon égoutté et émietté, saler, poivrer et ajouter une touche de piment. Laisser cuire 5 minutes en remuant, puis réserver.
3. Préparer la sauce d''accompagnement : Faire revenir le dernier oignon et la gousse d''ail restants. Ajouter le concentré de tomate dilué dans un petit verre d''eau. Saler, poivrer, ajouter le reste de piment et laisser mijoter à feu doux 10 minutes.
4. Façonner les pastels : Étaler la pâte finement sur un plan de travail fariné. Découper des cercles. Déposer une cuillère de farce au centre de chaque cercle, replier en chausson et souder les bords à la fourchette.
5. Cuisson : Chauffer l''huile de friture et y plonger les pastels jusqu''à ce qu''ils soient bien dorés. Servir avec la sauce tomate piquante.'
),

(
    'Hachis Parmentier au Confit de Canard', 
    'Viande', 
    'France', 
    'Facile', 
    60, 
    750, 
    4, 
    18.50, 
    'images/harchis.png', 
    '["Français", "Terroir", "Gratin", "Canard", "Réconfortant"]'::jsonb,
    '[
        {"nom": "Cuisses de canard confites", "quantite": 4, "unite": "pièces"},
        {"nom": "Pommes de terre à purée", "quantite": 1000, "unite": "g"},
        {"nom": "Oignons", "quantite": 2, "unite": "pièces"},
        {"nom": "Gousses d d''ail", "quantite": 2, "unite": "pièces"},
        {"nom": "Lait entier", "quantite": 200, "unite": "ml"},
        {"nom": "Beurre", "quantite": 50, "unite": "g"},
        {"nom": "Fromage râpé (Emmental)", "quantite": 100, "unite": "g"},
        {"nom": "Noix de muscade", "quantite": 1, "unite": "pincée"},
        {"nom": "Persil frais", "quantite": 0.5, "unite": "bouquet"},
        {"nom": "Sel et poivre", "quantite": 1, "unite": "pincée"}
    ]'::jsonb,
    '1.Éplucher les pommes de terre et les cuire dans un grand volume d'eau salée pendant environ 25 minutes. Les égoutter puis les écraser en purée avec le beurre, le lait et une pincée de muscade.
2.Retirer la peau et les os des cuisses de canard confites, puis effilocher la chair à l'aide d'une fourchette.
3.Faire revenir les oignons et l'ail dans un peu de graisse de canard. Ajouter le canard effiloché, le persil, poivrer (et saler uniquement si nécessaire), puis cuire 3 à 5 minutes.
4.Répartir la préparation au canard dans le fond d'un plat à gratin, puis recouvrir uniformément de purée.
5.Parsemer de fromage râpé et enfourner à 200 °C pendant 20 minutes, jusqu'à obtenir une croûte bien dorée.'
),

(
    'Tacos de Poulet Tinga au Chipotle', 
    'Viande', 
    'Mexique', 
    'Facile', 
    40, 
    510, 
    4, 
    12.00, 
     'images/tacospoulet.jpg', 
    '["Mexicain", "Épicé", "Street Food", "Poulet", "Avocat"]'::jsonb,
    '[
        {"nom": "Filet de poulet", "quantite": 600, "unite": "g"},
        {"nom": "Tortillas de maïs ou blé", "quantite": 12, "unite": "pièces"},
        {"nom": "Oignons", "quantite": 2, "unite": "pièces"},
        {"nom": "Tomates concassées", "quantite": 400, "unite": "g"},
        {"nom": "Piments chipotle en sauce", "quantite": 2, "unite": "pièces"},
        {"nom": "Gousses d d''ail", "quantite": 2, "unite": "pièces"},
        {"nom": "Avocat", "quantite": 2, "unite": "pièces"},
        {"nom": "Citron vert", "quantite": 2, "unite": "pièces"},
        {"nom": "Coriandre fraîche", "quantite": 0.5, "unite": "bouquet"},
        {"nom": "Huile d d''olive", "quantite": 2, "unite": "c.à.s"},
        {"nom": "Sel et poivre", "quantite": 1, "unite": "pincée"}
    ]'::jsonb,
    '1. Pocher le poulet 20 minutes à l''eau bouillante, laisser tiédir et effilocher à la main.
2. Sauce Tinga : mixer les tomates concassées, les piments chipotle, l''ail et la moitié d''un oignon.
3. Faire revenir le reste des oignons émincés dans l''huile d''olive. Ajouter la sauce mixée et mijoter 10 minutes.
4. Incorporer le poulet effiloché et laisser mijoter 5 minutes à feu doux.
5. Garnir les tortillas chaudes avec le poulet Tinga, l''avocat, la coriandre et un jet de jus de citron vert.'
),

(
    'Butter Chicken Indien Traditionnel', 
    'Viande', 
    'Inde', 
    'Moyen', 
    55, 
    680, 
    4, 
    15.00, 
    'images/butterchicken.jpg', 
    '["Indien", "Crémeux", "Épices", "Poulet", "En Sauce"]'::jsonb,
    '[
        {"nom": "Filet de poulet", "quantite": 700, "unite": "g"},
        {"nom": "Yaourt nature", "quantite": 150, "unite": "g"},
        {"nom": "Garam masala", "quantite": 2, "unite": "c.à.s"},
        {"nom": "Gingembre frais râpé", "quantite": 1, "unite": "c.à.s"},
        {"nom": "Gousses d d''ail", "quantite": 4, "unite": "pièces"},
        {"nom": "Concentré de tomate", "quantite": 3, "unite": "c.à.s"},
        {"nom": "Crème fraîche liquide", "quantite": 200, "unite": "ml"},
        {"nom": "Beurre", "quantite": 50, "unite": "g"},
        {"nom": "Oignons", "quantite": 1, "unite": "pièce"},
        {"nom": "Riz basmati", "quantite": 300, "unite": "g"}
    ]'::jsonb,
    '1.Couper le poulet en cubes et le faire mariner pendant 1 heure avec le yaourt, le garam masala, le cumin, le paprika, le gingembre râpé, l'ail haché et une pincée de sel.
2.Faire fondre une partie du beurre dans une poêle et faire dorer les morceaux de poulet. Réserver.
3.Dans la même poêle, faire revenir l'oignon finement émincé avec le reste du beurre jusqu'à ce qu'il soit fondant.
4.Ajouter l'ail, le gingembre, le concentré de tomate, la purée de tomates, le garam masala, le paprika, le curcuma et laisser cuire 3 à 4 minutes.
5.Incorporer la crème liquide et laisser mijoter quelques minutes.
6.Remettre le poulet dans la sauce et laisser cuire 10 à 15 minutes à feu doux.
7.Parsemer de coriandre fraîche et servir avec du riz basmati.'

),

(
    'Katsu Curry au Poulet Croustillant', 
    'Viande', 
    'Japon', 
    'Moyen', 
    45, 
    710, 
    4, 
    14.20, 
   'images/katsupoulet.jpg', 
    '["Japonais", "Croustillant", "Curry Douceur", "Riz", "Asiatique"]'::jsonb,
    '[
        {"nom": "Filet de poulet", "quantite": 4, "unite": "pièces"},
        {"nom": "Chapelure Panko", "quantite": 100, "unite": "g"},
        {"nom": "Farine", "quantite": 50, "unite": "g"},
        {"nom": "Oeuf", "quantite": 2, "unite": "pièces"},
        {"nom": "Oignons", "quantite": 1, "unite": "pièce"},
        {"nom": "Carottes", "quantite": 2, "unite": "pièces"},
        {"nom": "Pommes de terre", "quantite": 1, "unite": "pièce"},
        {"nom": "Poudre de curry doux", "quantite": 2, "unite": "c.à.s"},
        {"nom": "Bouillon de légumes", "quantite": 600, "unite": "ml"},
        {"nom": "Riz blanc", "quantite": 300, "unite": "g"}
    ]'::jsonb,
    '1.Faire revenir l'oignon dans un peu d'huile jusqu'à ce qu'il soit translucide.
2.Ajouter les carottes et les pommes de terre puis cuire quelques minutes.
3.Ajouter le curry japonais, un peu de sauce soja, le bouillon et laisser mijoter environ 20 minutes, jusqu'à ce que les légumes soient tendres.
4.Pendant ce temps, paner les filets de poulet en les passant dans la farine, l'œuf battu puis la chapelure Panko.
5.Faire frire les filets jusqu'à ce qu'ils soient bien dorés et croustillants.
6.Les égoutter puis les couper en tranches.
7.Servir le riz blanc, napper de sauce curry puis déposer les tranches de poulet croustillant sur le dessus.'
),

(
    'Pad Thaï aux Crevettes', 
    'Poisson', 
    'Thaïlande', 
    'Moyen', 
    30, 
    590, 
    2, 
    13.90,
    'images/crevettes.jpg', 
    '["Asiatique", "Nouilles", "Sauté", "Express"]'::jsonb,
    '[
        {"nom": "Nouilles de riz", "quantite": 150, "unite": "g"},
        {"nom": "Crevettes décortiquées", "quantite": 200, "unite": "g"},
        {"nom": "Œuf", "quantite": 1, "unite": "pièce"},
        {"nom": "Pousses de soja", "quantite": 100, "unite": "g"},
        {"nom": "Sauce pad thaï", "quantite": 4, "unite": "c.à.s"},
        {"nom": "Cacahuètes concassées", "quantite": 30, "unite": "g"}
    ]'::jsonb,
    '1.Faire tremper les nouilles de riz dans de l'eau tiède pendant 20 à 30 minutes, puis les égoutter.
2.Mélanger la sauce Pad Thaï avec la pâte de tamarin, la sauce de poisson, le sucre et un peu d'eau.
3.Chauffer un wok avec un peu d'huile puis faire revenir l'ail.
4.Ajouter les crevettes et cuire environ 2 minutes.
5.Pousser les crevettes sur le côté et brouiller l'œuf.
6.Ajouter les nouilles et la sauce Pad Thaï puis faire sauter 2 à 3 minutes.
7.Incorporer les pousses de soja et la ciboule.
8.Servir avec des cacahuètes concassées, un quartier de citron vert et du piment selon les goûts.'
),

(
    'Paella Valenciana aux Fruits de Mer', 
    'Poisson', 
    'Espagne', 
    'Difficile', 
    75, 
    710, 
    4, 
    22.00,
     'images/paella.jpg', 
    '["Espagnol", "Riz", "Fruits de mer", "Poêle"]'::jsonb,
    '[
        {"nom": "Riz à paella", "quantite": 300, "unite": "g"},
        {"nom": "Crevettes", "quantite": 8, "unite": "pièces"},
        {"nom": "Moules", "quantite": 200, "unite": "g"},
        {"nom": "Chorizo", "quantite": 80, "unite": "g"},
        {"nom": "Poivron rouge", "quantite": 1, "unite": "pièce"},
        {"nom": "Safran", "quantite": 1, "unite": "pincée"},
        {"nom": "Bouillon de poisson", "quantite": 750, "unite": "ml"}
    ]'::jsonb,
    '1.Faire revenir l'oignon, l'ail et le poivron dans l'huile d'olive.
2.Ajouter les tomates concassées et cuire quelques minutes.
3.Incorporer le riz rond et le faire nacrer pendant 2 minutes.
4.Verser le bouillon chaud parfumé au safran et au paprika.
5.Cuire 15 minutes sans remuer.
6.Ajouter les crevettes, les moules, les calamars (si utilisés) et les petits pois.
7.Poursuivre la cuisson pendant 8 à 10 minutes, jusqu'à ce que les fruits de mer soient cuits et que le riz ait absorbé le liquide.
8.Laisser reposer 5 minutes avant de servir avec des quartiers de citron.'
),

(
    'Cheeseburger Maison double Cheddar', 
    'Viande', 
    'États-Unis', 
    'Facile', 
    20, 
    780, 
    2, 
    9.50,
     'images/cheese.jpg',
    '["Américain", "Burger", "Express", "Fastfood"]'::jsonb,
    '[
        {"nom": "Pains burger", "quantite": 2, "unite": "pièces"},
        {"nom": "Steaks hachés de bœuf", "quantite": 2, "unite": "pièces"},
        {"nom": "Tranches de Cheddar", "quantite": 4, "unite": "tranches"},
        {"nom": "Cornichons", "quantite": 1, "unite": "pièce"},
        {"nom": "Oignon rouge", "quantite": 0.5, "unite": "pièce"}
    ]'::jsonb,
    '1.Former les steaks hachés et les assaisonner de sel et de poivre.
2.Toaster les pains burger avec un peu de beurre.
3.Saisir les steaks dans une poêle très chaude jusqu'à la cuisson désirée.
4.Déposer deux tranches de cheddar sur chaque steak et couvrir quelques instants pour les faire fondre.
5.Tartiner les pains de sauce burger, mayonnaise ou ketchup.
6.Ajouter la salade, les tomates, les cornichons et les oignons.
7.Déposer le steak au cheddar fondu puis refermer le burger.
8.Servir immédiatement avec des frites ou une salade.'
),

(
    'Fish and Chips Traditionnel', 
    'Poisson', 
    'Royaume-Uni', 
    'Moyen', 
    35, 
    820, 
    2, 
    11.20,
    'images/fish.jpg',
    '["Anglais", "Poisson", "Friture", "Croustillant"]'::jsonb,
    '[
        {"nom": "Filets de cabillaud", "quantite": 2, "unite": "pièces"},
        {"nom": "Pommes de terre à frites", "quantite": 600, "unite": "g"},
        {"nom": "Farine", "quantite": 150, "unite": "g"},
        {"nom": "Bière blonde fraîche", "quantite": 150, "unite": "ml"},
        {"nom": "Levure chimique", "quantite": 0.5, "unite": "sachet"}
    ]'::jsonb,
    '1. Préparer la pâte : farine, levure et bière glacée.
2. Précuire les frites à 160°C.
3. Enrober le poisson de pâte et frire à 180°C jusqu''à coloration dorée.
4. Replonger les frites à 190°C pour les rendre bien croustillantes.'
),

(
    'Bœuf Bourguignon à l''Ancienne', 
    'Viande', 
    'France', 
    'Difficile', 
    150, 
    710, 
    4, 
    21.50,
    'images/boeuf.jpg',
    '["Français", "Terroir", "Mijoté", "Vin rouge"]'::jsonb,
    '[
        {"nom": "Viande de bœuf à mijoter", "quantite": 800, "unite": "g"},
        {"nom": "Vin rouge de Bourgogne", "quantite": 500, "unite": "ml"},
        {"nom": "Lardons", "quantite": 100, "unite": "g"},
        {"nom": "Carottes", "quantite": 3, "unite": "pièces"},
        {"nom": "Champignons de Paris", "quantite": 200, "unite": "g"}
    ]'::jsonb,
    '1. Dorer les lardons et oignons. Saisir les morceaux de bœuf à feu vif.
2. Singer avec la farine, mouiller au vin rouge et bouillon.
3. Ajouter carottes, couvrir et mijoter à feu très doux 2 heures. Ajouter les champignons sautés en fin de cuisson.'
),

(
    'Quiche Lorraine Authentique', 
    'Viande', 
    'France', 
    'Facile', 
    45, 
    620, 
    4, 
    8.90,
    'images/quiche.jpg',
    '["Français", "Four", "Classique", "Express"]'::jsonb,
    '[
        {"nom": "Pâte brisée", "quantite": 1, "unite": "pièce"},
        {"nom": "Lardons fumés", "quantite": 200, "unite": "g"},
        {"nom": "Œufs", "quantite": 4, "unite": "pièces"},
        {"nom": "Crème fraîche épaisse", "quantite": 200, "unite": "g"},
        {"nom": "Lait", "quantite": 100, "unite": "ml"},
        {"nom": "Fromage râpé", "quantite": 100, "unite": "g"}
    ]'::jsonb,
    '1.Étaler la pâte brisée dans un moule et piquer le fond à la fourchette.
2.Faire revenir les lardons sans trop les colorer puis les répartir sur le fond de tarte.
3.Battre les œufs avec la crème fraîche, le lait, une pincée de muscade, du poivre et très peu de sel.
4.Verser l'appareil sur les lardons.
5.Enfourner à 180 °C pendant 35 à 40 minutes, jusqu'à ce que la quiche soit bien dorée.'
),

(
    'Moussaka Grecque aux Aubergines', 
    'Viande', 
    'Grèce', 
    'Difficile', 
    90, 
    680, 
    4, 
    16.50,
    'images/moussaka.jpg',
    '["Grec", "Gratin", "Aubergine", "Four"]'::jsonb,
    '[
        {"nom": "Aubergines", "quantite": 3, "unite": "pièces"},
        {"nom": "Agneau haché", "quantite": 400, "unite": "g"},
        {"nom": "Tomates concassées", "quantite": 400, "unite": "g"},
        {"nom": "Béchamel", "quantite": 400, "unite": "ml"}
    ]'::jsonb,
    '1. Griller les tranches d''aubergines au four.
2. Faire mijoter la viande hachée avec les tomates et oignons.
3. Alterner couches d''aubergines et viande, recouvrir de béchamel et cuire 45 min à 180°C.'
),

(
    'Shawarma au Poulet Libanais', 
    'Viande', 
    'Liban', 
    'Moyen', 
    40, 
    570, 
    3, 
    11.00,
    'images/shawarma.jpg',
    '["Libanais", "Épicé", "Sandwich", "Express"]'::jsonb,
    '[
        {"nom": "Filet de poulet", "quantite": 500, "unite": "g"},
        {"nom": "Pains libanais (Pitas)", "quantite": 3, "unite": "pièces"},
        {"nom": "Yaourt nature", "quantite": 1, "unite": "pièce"},
        {"nom": "Jus de citron", "quantite": 2, "unite": "c.à.s"},
        {"nom": "Épices Shawarma", "quantite": 1, "unite": "c.à.s"},
        {"nom": "Ail", "quantite": 2, "unite": "gousses"}
    ]'::jsonb,
    '1. Mariner le poulet avec jus de citron, ail et épices shawarma 1h.
2. Saisir à feu vif à la poêle 8-10 minutes.
3. Garnir les pitas chaudes avec sauce yaourt et poulet croustillant.'
),

(
    'Tajine de Poulet au Citron Confit et Olives', 
    'Viande', 
    'Maroc', 
    'Moyen', 
    65, 
    580, 
    3, 
    13.50, 
    'images/tajine.jpg',
    '["Maghrébin", "Tajine", "Citronné", "Olives"]'::jsonb,
    '[
        {"nom": "Cuisses de poulet", "quantite": 3, "unite": "pièces"},
        {"nom": "Oignons", "quantite": 2, "unite": "pièces"},
        {"nom": "Citron confit", "quantite": 1, "unite": "pièce"},
        {"nom": "Olives vertes", "quantite": 80, "unite": "g"},
        {"nom": "Gingembre et Curcuma", "quantite": 1, "unite": "c.à.c"}
    ]'::jsonb,
    '1. Mariner le poulet avec l''ail et les épices. Dorer le poulet dans le tajine.
2. Suer les oignons, remettre le poulet, ajouter le citron confit et l''eau.
3. Mijoter 40 min à feu doux. Ajouter les olives 10 min avant de servir.'
),

(
    'Pizza Margherita à la Mozzarella di Bufala', 
    'Végétarien', 
    'Cuisine italienne', 
    'Facile', 
    30, 
    680, 
    2, 
    6.50, 
    'images/pizza.jpg',
    '["Italien", "Classique", "Four", "Fromage"]'::jsonb,
    '[
        {"nom": "Pâte à pizza", "quantite": 1, "unite": "pièce"},
        {"nom": "Sauce tomate", "quantite": 200, "unite": "g"},
        {"nom": "Mozzarella fraîche", "quantite": 125, "unite": "g"},
        {"nom": "Basilic frais", "quantite": 1, "unite": "bouquet"}
    ]'::jsonb,
    '1. Étaler la pâte sur plaque. Napper de sauce tomate.
2. Disposer la mozzarella coupée en tranches.
3. Cuire 10-12 min à 240°C. Parsemer de basilic frais à la sortie.'
),

(
    'Lasagnes Traditionnelles Bolognaise', 
    'Viande', 
    'Cuisine italienne', 
    'Moyen', 
    75, 
    750, 
    4, 
    14.80, 
    'images/lasagne.jpg',
    '["Italien", "Gratin", "Four", "Pâtes", "Bolognaise"]'::jsonb,
    '[
        {"nom": "Plaques de lasagne", "quantite": 12, "unite": "pièces"},
        {"nom": "Bœuf haché", "quantite": 400, "unite": "g"},
        {"nom": "Sauce tomate", "quantite": 500, "unite": "g"},
        {"nom": "Sauce Béchamel", "quantite": 500, "unite": "ml"},
        {"nom": "Fromage râpé", "quantite": 100, "unite": "g"}
    ]'::jsonb,
    '1.Faire revenir les oignons, le céleri et les carottes.
2.Ajouter le bœuf haché puis le concentré de tomate et les tomates.
3.Laisser mijoter 1 h 30 à 2 heures.
4.Préparer la béchamel.
5.Alterner :
béchamel
pâtes
bolognaise
Parsemer de parmesan.
Cuire 35 à 40 minutes.
),

(
    'Spaghetti Carbonara au Pecorino', 
    'Viande', 
    'Cuisine italienne', 
    'Facile', 
    25, 
    690, 
    2, 
    8.20, 
    'images/spaghetti.jpg',
    '["Italien", "Pâtes", "Express", "Traditionnel"]'::jsonb,
    '[
        {"nom": "Spaghetti", "quantite": 250, "unite": "g"},
        {"nom": "Guanciale ou Pancetta", "quantite": 120, "unite": "g"},
        {"nom": "Jaunes d d''œuf", "quantite": 3, "unite": "pièces"},
        {"nom": "Pecorino Romano", "quantite": 50, "unite": "g"}
    ]'::jsonb,
    '1. Cuire les spaghetti. Dorer le guanciale à la poêle.
2. Battre les jaunes avec le pecorino et le poivre.
3. Mélanger le tout hors du feu avec un peu d''eau de cuisson pour créer la sauce crémeuse.'
),

(
    'Sushi Maki Saumon Vinaigré', 
    'Poisson', 
    'Japon', 
    'Moyen', 
    45, 
    420, 
    2, 
    12.50, 
     'images/sushi.jpg',
    '["Japonais", "Riz", "Poisson cru", "Sain"]'::jsonb,
    '[
        {"nom": "Riz à sushi", "quantite": 200, "unite": "g"},
        {"nom": "Feuilles d d''algue Nori", "quantite": 3, "unite": "pièces"},
        {"nom": "Pavé de saumon frais", "quantite": 150, "unite": "g"},
        {"nom": "Vinaigre de riz", "quantite": 3, "unite": "c.à.s"}
    ]'::jsonb,
    '1.Cuire et assaisonner le riz à sushi avec le vinaigre de riz, le sucre et le sel.
2.Étaler une fine couche de riz sur la feuille de nori en laissant environ 2 cm libres en haut.
3.Déposer les lanières de saumon au centre.
4.Rouler fermement à l'aide d'une natte en bambou.
5.Humidifier le bord libre du nori pour sceller le rouleau.
6.Découper en 6 à 8 morceaux avec un couteau humide.'
),

(
    'Ramen au Poulet et Œuf Mollet', 
    'Viande', 
    'Japon', 
    'Difficile', 
    90, 
    610, 
    2, 
    11.40, 
    'images/ramen.jpg',
    '["Japonais", "Soupe", "Nouilles", "Réconfortant"]'::jsonb,
    '[
        {"nom": "Nouilles de Ramen", "quantite": 180, "unite": "g"},
        {"nom": "Filet de poulet", "quantite": 250, "unite": "g"},
        {"nom": "Bouillon de volaille", "quantite": 1, "unite": "litre"},
        {"nom": "Sauce soja", "quantite": 3, "unite": "c.à.s"},
        {"nom": "Œufs", "quantite": 2, "unite": "pièces"}
    ]'::jsonb,
    '1. Cuire les œufs 6 minutes. Faire frémir le bouillon avec le gingembre et la sauce soja.
2. Saisir le poulet et le trancher.
3. Verser le bouillon sur les nouilles et dresser avec le poulet et l''œuf mollet.'
),

(
    'Tacos au Bœuf Haché Épicé', 
    'Viande', 
    'Mexique', 
    'Facile', 
    30, 
    540, 
    3, 
    9.80, 
    'images/tacosboeuf.jpg',
    '["Mexicain", "Express", "Épicé", "Street Food"]'::jsonb,
    '[
        {"nom": "Tortillas de maïs", "quantite": 6, "unite": "pièces"},
        {"nom": "Bœuf haché", "quantite": 300, "unite": "g"},
        {"nom": "Oignon", "quantite": 1, "unite": "pièce"},
        {"nom": "Tomate", "quantite": 1, "unite": "pièce"},
        {"nom": "Épices à tacos", "quantite": 1, "unite": "c.à.s"}
    ]'::jsonb,
    '1. Cuire le bœuf haché avec l''oignon et les épices à tacos 8 minutes.
2. Chauffer les tortillas.
3. Garnir avec la viande épicée, les dés de tomates fraîches et la coriandre.'
),

(
    'Burritos au Poulet et Haricots Rouges', 
    'Viande', 
    'Mexique', 
    'Moyen', 
    40, 
    720, 
    2, 
    11.50, 
    'images/burritos.jpg',
    '["Mexicain", "Complet", "Riz", "Haricots"]'::jsonb,
    '[
        {"nom": "Grandes tortillas de blé", "quantite": 2, "unite": "pièces"},
        {"nom": "Filet de poulet", "quantite": 250, "unite": "g"},
        {"nom": "Riz blanc cuit", "quantite": 150, "unite": "g"},
        {"nom": "Haricots rouges cuits", "quantite": 100, "unite": "g"},
        {"nom": "Fromage râpé", "quantite": 60, "unite": "g"}
    ]'::jsonb,
    '1.Faire revenir le poulet émincé avec l'oignon et les épices (cumin, paprika, chili) jusqu'à cuisson complète.
2.Mélanger le riz cuit avec les haricots rouges, un peu de salsa et de coriandre.
3.Garnir les tortillas avec le mélange riz-haricots, le poulet et le fromage râpé.
4.Ajouter éventuellement de la salade ou de l'avocat.
5.Rabattre les côtés et rouler fermement.
6.Faire griller quelques minutes à la poêle pour une tortilla légèrement croustillante.'
),

(
    'Couscous Royal Agneau et Merguez', 
    'Viande', 
    'Cuisine marocaine', 
    'Difficile', 
    120, 
    850, 
    4, 
    24.00, 
    'images/couscous.jpg',
    '["Maghrébin", "Traditionnel", "Agneau", "Légumes"]'::jsonb,
    '[
        {"nom": "Semoule de couscous", "quantite": 400, "unite": "g"},
        {"nom": "Morceaux d d''agneau", "quantite": 500, "unite": "g"},
        {"nom": "Merguez", "quantite": 4, "unite": "pièces"},
        {"nom": "Carottes et Courgettes", "quantite": 4, "unite": "pièces"},
        {"nom": "Pois chiches", "quantite": 150, "unite": "g"}
    ]'::jsonb,
    '1. Cuire l''agneau dans le bouillon du couscoussier avec les légumes et les épices.
2. Travailler la semoule à la vapeur.
3. Griller les merguez à part et dresser la semoule avec les viandes et légumes.'
),
(
    'Thiébou Yapp (Riz à la Viande)', 
    'Viande', 
    'Sénégal', 
    'Difficile', 
    95, -- 35 min de préparation + 60 min de cuisson
    760, 
    6, 
    19.50, 
    'images/thiebouyapp.jpg',
    '["Sénégalais", "Traditionnel", "Viande", "Riz Brun", "Nokoss"]',
    '[
        {"nom": "Riz (brisé deux fois)", "quantite": 1000, "unite": "g"},
        {"nom": "Viande de boeuf ou mouton", "quantite": 1000, "unite": "g"},
        {"nom": "Oignons", "quantite": 4, "unite": "pièces"},
        {"nom": "Huile de cuisson", "quantite": 15, "unite": "cl"},
        {"nom": "Gousses d d''ail", "quantite": 4, "unite": "pièces"},
        {"nom": "Poivron vert", "quantite": 1, "unite": "pièce"},
        {"nom": "Piment frais", "quantite": 1, "unite": "pièce"},
        {"nom": "Piment sec", "quantite": 1, "unite": "pièce"},
        {"nom": "Poivre noir en grains", "quantite": 1, "unite": "caf"},
        {"nom": "Mustard", "quantite": 1, "unite": "c.à.s"},
        {"nom": "Guedj (poisson séché)", "quantite": 1, "unite": "pièce"},
        {"nom": "Sel", "quantite": 1, "unite": "pincée"}
    ]'::jsonb,
    '1. Couper la viande en morceaux réguliers. Dans une grande marmite, chauffer l''huile et faire dorer intensément la viande pour donner de la couleur au futur riz. Saler légèrement.
2. Ajouter 2 oignons émincés dans la marmite et les faire caraméliser doucement avec la viande.
3. Préparer le Nokoss : Piler l''ail, les 2 oignons restants, le poivron vert, le piment sec, les grains de poivre et du sel. 
4. Ajouter la moitié du nokoss et le guedj lavé dans la marmite. Remuer pendant 3 minutes, puis couvrir avec 1,5 litre d''eau. Porter à ébullition, réduire le feu et laisser mijoter 45 minutes jusqu''à ce que la viande soit bien tendre.
5. Laver le riz 3 fois et le cuire à la vapeur au couscoussier pendant 15 minutes.
6. Retirer la viande de la marmite et la réserver. Ajouter le reste du nokoss et la moutarde dans le bouillon, rectifier le sel. 
7. Verser le riz précuit dans le bouillon (le liquide doit arriver à ras du riz). Ajouter le piment frais entier sur le dessus. Couvrir hermétiquement et laisser cuire à feu très doux pendant 25 minutes en retournant à mi-cuisson. Servir le riz brun surmonté de la viande tendre.'
),

(
    'Dégat de Vermicelles au Poulet Braisé', 
    'Viande', 
    'Sénégal', 
    'Moyen', 
    80, 
    690, 
    4, 
    16.00, 
    'images/vermicelle.jpg',
    '["Sénégalais", "Fête", "Poulet", "Vermicelles", "Sauce Oignons"]',
    '[
        {"nom": "Vermicelles (Cheveux d d''ange)", "quantite": 500, "unite": "g"},
        {"nom": "Filet de poulet ou cuisses", "quantite": 800, "unite": "g"},
        {"nom": "Oignons", "quantite": 5, "unite": "pièces"},
        {"nom": "Moutarde de Dijon", "quantite": 3, "unite": "c.à.s"},
        {"nom": "Jus de citron", "quantite": 2, "unite": "c.à.s"},
        {"nom": "Gousses d d''ail", "quantite": 4, "unite": "pièces"},
        {"nom": "Raisins secs", "quantite": 50, "unite": "g"},
        {"nom": "Beurre", "quantite": 30, "unite": "g"},
        {"nom": "Huile de cuisson", "quantite": 4, "unite": "c.à.s"},
        {"nom": "Sel et poivre", "quantite": 1, "unite": "pincée"}
    ]'::jsonb,
    '1. Mariner le poulet avec la moitié de l''ail écrasé, 1 cuillère à soupe de moutarde, du sel et du poivre. Laisser reposer, puis faire dorer et cuire au four à 200°C pendant 35 minutes.
2. Mettre les raisins secs dans un bol d''eau tiède pour les réhydrater.
3. Préparer la sauce : Émincer finement les 5 oignons. Dans une casserole avec l''huile, faire suer les oignons à feu doux. Ajouter le reste d''ail, 2 cuillères à soupe de moutarde, le jus de citron, du sel et du poivre. Laisser confire lentement 20 minutes jusqu''à caramélisation. Ajouter les raisins secs égouttés en fin de cuisson.
4. Cuisson des vermicelles : Enduire les vermicelles crus d''une cuillère à soupe d''huile. Les placer dans le haut d''un couscoussier et cuire à la vapeur pendant 15 minutes.
5. Retirer les vermicelles, les asperger d''un petit demi-verre d''eau salée, mélanger et remettre à la vapeur pour 10 minutes supplémentaires.
6. Hors du feu, incorporer le beurre dans les vermicelles chauds pour bien séparer les fils.
7. Servir les vermicelles légers nappés de la sauce aux oignons douce-amère et surmontés des morceaux de poulet braisé croustillants.'
),

(
    'Gratin de Macaroni Gourmand au Poulet', 
    'Viande', 
    'International', 
    'Facile', 
    35, 
    620, 
    4, 
    11.50, 
    'images/gratin.jpg',
    '["Pâtes", "Gratin", "Fromage", "Poulet", "Enfants"]',
    '[
        {"nom": "Macaroni", "quantite": 400, "unite": "g"},
        {"nom": "Filet de poulet", "quantite": 400, "unite": "g"},
        {"nom": "Crème fraîche liquide", "quantite": 300, "unite": "ml"},
        {"nom": "Fromage râpé", "quantite": 150, "unite": "g"},
        {"nom": "Oignons", "quantite": 1, "unite": "pièce"},
        {"nom": "Beurre", "quantite": 20, "unite": "g"},
        {"nom": "Noix de muscade", "quantite": 1, "unite": "pincée"},
        {"nom": "Sel et poivre", "quantite": 1, "unite": "pincée"}
    ]'::jsonb,
    '1. Cuire les macaroni dans un grand volume d''eau bouillante salée en suivant les instructions du paquet (garder al dente). Égoutter.
2. Découper les filets de poulet en petits dés et émincer l''oignon. 
3. Dans une poêle, faire fondre le beurre et faire revenir l''oignon pendant 3 minutes, puis ajouter les dés de poulet. Faire dorer pendant 5 à 7 minutes. Saler et poivrer.
4. Préchauffer le four à 210°C.
5. Dans un grand saladier, mélanger les macaroni cuits, le poulet poêlé avec ses oignons, la crème fraîche liquide, la moitié du fromage râpé et une pincée de noix de muscade.
6. Verser la préparation dans un plat à gratin, égaliser la surface et parsemer avec le reste de fromage râpé.
7. Enfourner pour 12 à 15 minutes jusqu''à l''obtention d''une croûte fromagère bien dorée.'
),

(
    'Crêpes Salées Jambon-Fromage Express', 
    'Viande', 
    'France', 
    'Facile', 
    30, 
    490, 
    3, 
    7.50, 
    'images/crepe.jpg',
    '["Français", "Express", "Crêpes", "Jambon", "Économique"]',
    '[
        {"nom": "Farine", "quantite": 250, "unite": "g"},
        {"nom": "Oeuf", "quantite": 3, "unite": "pièces"},
        {"nom": "Lait", "quantite": 500, "unite": "ml"},
        {"nom": "Jambon de dinde", "quantite": 6, "unite": "tranches"},
        {"nom": "Fromage râpé", "quantite": 150, "unite": "g"},
        {"nom": "Beurre", "quantite": 30, "unite": "g"},
        {"nom": "Sel", "quantite": 1, "unite": "pincée"}
    ]'::jsonb,
    '1.Mélanger la farine, les œufs, le sel et le lait progressivement jusqu'à obtenir une pâte homogène. Ajouter le beurre fondu.
2.Laisser reposer la pâte 30 minutes (10 minutes minimum).
3.Cuire les crêpes dans une poêle légèrement beurrée.
4.Garnir chaque crêpe avec le jambon et le fromage.
5.Plier puis chauffer jusqu'à ce que le fromage soit fondu.
'
),

(
    'Poké Bowl Saumon Avocat',
    'Poisson',
    'Hawaï',
    'Facile',
    25,
    560,
    2,
    13.50,
    'images/poke-bowl.jpg',
    '["Healthy", "Saumon", "Bowl", "Riz", "Avocat", "Cuisine Hawaïenne"]'::jsonb,
    '[
        {"nom":"Riz à sushi","quantite":200,"unite":"g"},
        {"nom":"Saumon frais","quantite":250,"unite":"g"},
        {"nom":"Avocat","quantite":1,"unite":"pièce"},
        {"nom":"Concombre","quantite":0.5,"unite":"pièce"},
        {"nom":"Carotte","quantite":1,"unite":"pièce"},
        {"nom":"Edamame","quantite":80,"unite":"g"},
        {"nom":"Oignon nouveau","quantite":2,"unite":"tiges"},
        {"nom":"Graines de sésame","quantite":1,"unite":"c. à soupe"},
        {"nom":"Algues nori","quantite":1,"unite":"feuille"},
        {"nom":"Sauce soja","quantite":2,"unite":"c. à soupe"},
        {"nom":"Huile de sésame","quantite":1,"unite":"c. à café"},
        {"nom":"Jus de citron vert","quantite":1,"unite":"c. à soupe"}
    ]'::jsonb,
    1. Cuire le riz à sushi selon les instructions du paquet, puis le laisser refroidir légèrement.
2. Couper le saumon frais en cubes réguliers et le mélanger avec la sauce soja, l'huile de sésame et le jus de citron vert. Laisser mariner pendant 10 minutes.
3. Éplucher et couper l'avocat en lamelles, le concombre en fines rondelles et râper la carotte.
4. Cuire les edamames quelques minutes dans de l'eau bouillante salée, puis les égoutter.
5. Répartir le riz dans deux grands bols.
6. Disposer harmonieusement le saumon mariné, l'avocat, le concombre, la carotte et les edamames sur le riz.
7. Parsemer de graines de sésame, d'oignon nouveau finement émincé et de morceaux d'algue nori.
8. Servir immédiatement avec un supplément de sauce soja selon les goûts.
),




