-- Insertion des données dans la table Utilisateurs
INSERT INTO Utilisateurs (UtilisateurID, Nom, Prenom, Email, MotDePasse) VALUES 
(1, 'Tremblay', 'Jean', 'jean@example.com', 'motdepasse1');

INSERT INTO Utilisateurs (UtilisateurID, Nom, Prenom, Email, MotDePasse) VALUES 
(2, 'Gagnon', 'Marie', 'marie@example.com', 'motdepasse2');

INSERT INTO Utilisateurs (UtilisateurID, Nom, Prenom, Email, MotDePasse) VALUES 
(3, 'Roy', 'Pierre', 'pierre@example.com', 'motdepasse3');

INSERT INTO Utilisateurs (UtilisateurID, Nom, Prenom, Email, MotDePasse) VALUES 
(4, 'Fortin', 'Sylvie', 'sylvie@example.com', 'motdepasse4');

INSERT INTO Utilisateurs (UtilisateurID, Nom, Prenom, Email, MotDePasse) VALUES 
(5, 'Lavoie', 'Robert', 'robert@example.com', 'motdepasse5');

INSERT INTO Utilisateurs (UtilisateurID, Nom, Prenom, Email, MotDePasse) VALUES 
(6, 'Pelletier', 'Isabelle', 'isabelle@example.com', 'motdepasse6');

INSERT INTO Utilisateurs (UtilisateurID, Nom, Prenom, Email, MotDePasse) VALUES 
(7, 'Bergeron', 'Michel', 'michel@example.com', 'motdepasse7');

INSERT INTO Utilisateurs (UtilisateurID, Nom, Prenom, Email, MotDePasse) VALUES 
(8, 'Gauthier', 'Sophie', 'sophie@example.com', 'motdepasse8');

INSERT INTO Utilisateurs (UtilisateurID, Nom, Prenom, Email, MotDePasse) VALUES 
(9, 'Lefebvre', 'Jacques', 'jacques@example.com', 'motdepasse9');

-- Insertion des données dans la table Annonces
INSERT INTO Annonces (AnnonceID, UtilisateurID, Titre, Description, PrixParNuit, Localisation, DateCreation) VALUES 
(1, 1, 'Charmant appartement près du Vieux-Québec', 'Appartement lumineux avec vue sur la ville, à quelques pas des principales attractions touristiques.', 100, 'Vieux-Québec, Québec', TO_DATE('2024-03-17', 'YYYY-MM-DD'));

INSERT INTO Annonces (AnnonceID, UtilisateurID, Titre, Description, PrixParNuit, Localisation, DateCreation) VALUES 
(2, 2, 'Maison de caractère avec jardin en plein cœur de la ville', 'Maison spacieuse et confortable idéale pour les familles, à proximité des parcs et des commerces.', 150, 'Saint-Roch, Québec', TO_DATE('2024-03-17', 'YYYY-MM-DD'));

INSERT INTO Annonces (AnnonceID, UtilisateurID, Titre, Description, PrixParNuit, Localisation, DateCreation) VALUES 
(3, 3, 'Studio moderne avec terrasse privée', 'Studio entièrement équipé dans un quartier calme mais proche de toutes les commodités.', 80, 'Limoilou, Québec', TO_DATE('2024-03-17', 'YYYY-MM-DD'));

INSERT INTO Annonces (AnnonceID, UtilisateurID, Titre, Description, PrixParNuit, Localisation, DateCreation) VALUES 
(4, 4, 'Condo de luxe avec vue imprenable sur le fleuve', 'Condo haut de gamme avec toutes les commodités modernes et une vue panoramique sur le fleuve Saint-Laurent.', 200, 'Levis, Québec', TO_DATE('2024-03-18', 'YYYY-MM-DD'));

INSERT INTO Annonces (AnnonceID, UtilisateurID, Titre, Description, PrixParNuit, Localisation, DateCreation) VALUES 
(5, 5, 'Appartement cosy au cœur du centre-ville', 'Appartement rénové avec goût, à proximité des restaurants et des boutiques du centre-ville.', 120, 'Sainte-Foy, Québec', TO_DATE('2024-03-18', 'YYYY-MM-DD'));

INSERT INTO Annonces (AnnonceID, UtilisateurID, Titre, Description, PrixParNuit, Localisation, DateCreation) VALUES 
(6, 6, 'Maison chaleureuse avec jardin et piscine', 'Maison idéale pour les vacances en famille, avec un grand jardin et une piscine privée.', 180, 'Beauport, Québec', TO_DATE('2024-03-18', 'YYYY-MM-DD'));

INSERT INTO Annonces (AnnonceID, UtilisateurID, Titre, Description, PrixParNuit, Localisation, DateCreation) VALUES 
(7, 7, 'Studio en plein cœur du quartier historique', 'Studio confortable à proximité des sites historiques et des restaurants.', 90, 'Vieux-Port, Québec', TO_DATE('2024-03-19', 'YYYY-MM-DD'));

INSERT INTO Annonces (AnnonceID, UtilisateurID, Titre, Description, PrixParNuit, Localisation, DateCreation) VALUES 
(8, 8, 'Appartement moderne avec vue sur la rivière', 'Appartement élégant avec balcon offrant une vue panoramique sur la rivière Saint-Charles.', 130, 'Saint-Roch, Québec', TO_DATE('2024-03-19', 'YYYY-MM-DD'));

INSERT INTO Annonces (AnnonceID, UtilisateurID, Titre, Description, PrixParNuit, Localisation, DateCreation) VALUES 
(9, 9, 'Chalet rustique au bord du lac', 'Chalet pittoresque niché au bord d''un lac tranquille, idéal pour une escapade relaxante en nature.', 160, 'Lac-Beauport, Québec', TO_DATE('2024-03-20', 'YYYY-MM-DD'));

-- Insertion des données dans la table Reservations
INSERT INTO Reservations (ReservationID, UtilisateurID, AnnonceID, DateDebut, DateFin, Statut, MontantTotal) VALUES 
(1, 2, 1, TO_DATE('2024-04-01', 'YYYY-MM-DD'), TO_DATE('2024-04-05', 'YYYY-MM-DD'), 'confirmée', 400);

INSERT INTO Reservations (ReservationID, UtilisateurID, AnnonceID, DateDebut, DateFin, Statut, MontantTotal) VALUES 
(2, 3, 2, TO_DATE('2024-04-10', 'YYYY-MM-DD'), TO_DATE('2024-04-15', 'YYYY-MM-DD'), 'confirmée', 750);

INSERT INTO Reservations (ReservationID, UtilisateurID, AnnonceID, DateDebut, DateFin, Statut, MontantTotal) VALUES 
(3, 1, 3, TO_DATE('2024-05-01', 'YYYY-MM-DD'), TO_DATE('2024-05-05', 'YYYY-MM-DD'), 'en attente', 320);

INSERT INTO Reservations (ReservationID, UtilisateurID, AnnonceID, DateDebut, DateFin, Statut, MontantTotal) VALUES 
(4, 4, 4, TO_DATE('2024-05-15', 'YYYY-MM-DD'), TO_DATE('2024-05-20', 'YYYY-MM-DD'), 'confirmée', 1000);

INSERT INTO Reservations (ReservationID, UtilisateurID, AnnonceID, DateDebut, DateFin, Statut, MontantTotal) VALUES 
(5, 5, 5, TO_DATE('2024-06-01', 'YYYY-MM-DD'), TO_DATE('2024-06-05', 'YYYY-MM-DD'), 'confirmée', 600);

INSERT INTO Reservations (ReservationID, UtilisateurID, AnnonceID, DateDebut, DateFin, Statut, MontantTotal) VALUES 
(6, 6, 6, TO_DATE('2024-06-10', 'YYYY-MM-DD'), TO_DATE('2024-06-15', 'YYYY-MM-DD'), 'confirmée', 900);

INSERT INTO Reservations (ReservationID, UtilisateurID, AnnonceID, DateDebut, DateFin, Statut, MontantTotal) VALUES 
(7, 7, 7, TO_DATE('2024-07-01', 'YYYY-MM-DD'), TO_DATE('2024-07-05', 'YYYY-MM-DD'), 'en attente', 450);

INSERT INTO Reservations (ReservationID, UtilisateurID, AnnonceID, DateDebut, DateFin, Statut, MontantTotal) VALUES 
(8, 8, 8, TO_DATE('2024-07-10', 'YYYY-MM-DD'), TO_DATE('2024-07-15', 'YYYY-MM-DD'), 'confirmée', 650);

INSERT INTO Reservations (ReservationID, UtilisateurID, AnnonceID, DateDebut, DateFin, Statut, MontantTotal) VALUES 
(9, 9, 9, TO_DATE('2024-08-01', 'YYYY-MM-DD'), TO_DATE('2024-08-05', 'YYYY-MM-DD'), 'en attente', 800);

-- Insertion des données dans la table Commentaires
INSERT INTO Commentaires (CommentaireID, UtilisateurID, AnnonceID, Note, Commentaire, DateCommentaire) VALUES 
(1, 2, 1, 5, 'Super séjour, l''appartement est parfaitement situé et très confortable.', TO_DATE('2024-04-06', 'YYYY-MM-DD'));

INSERT INTO Commentaires (CommentaireID, UtilisateurID, AnnonceID, Note, Commentaire, DateCommentaire) VALUES 
(2, 3, 2, 4, 'Belle maison avec un jardin agréable, proche de tout.', TO_DATE('2024-04-07', 'YYYY-MM-DD'));

INSERT INTO Commentaires (CommentaireID, UtilisateurID, AnnonceID, Note, Commentaire, DateCommentaire) VALUES 
(3, 4, 3, 4, 'Studio moderne et bien équipé, propriétaire accueillant.', TO_DATE('2024-04-08', 'YYYY-MM-DD'));

INSERT INTO Commentaires (CommentaireID, UtilisateurID, AnnonceID, Note, Commentaire, DateCommentaire) VALUES 
(4, 5, 4, 5, 'Condo luxueux avec une vue à couper le souffle.', TO_DATE('2024-05-21', 'YYYY-MM-DD'));

INSERT INTO Commentaires (CommentaireID, UtilisateurID, AnnonceID, Note, Commentaire, DateCommentaire) VALUES 
(5, 6, 5, 4, 'Appartement confortable et bien situé, propriétaire réactif.', TO_DATE('2024-06-06', 'YYYY-MM-DD'));

INSERT INTO Commentaires (CommentaireID, UtilisateurID, AnnonceID, Note, Commentaire, DateCommentaire) VALUES 
(6, 7, 6, 5, 'Maison parfaite pour des vacances en famille, jardin très agréable.', TO_DATE('2024-06-16', 'YYYY-MM-DD'));

INSERT INTO Commentaires (CommentaireID, UtilisateurID, AnnonceID, Note, Commentaire, DateCommentaire) VALUES 
(7, 8, 7, 3, 'Studio correct mais bruyant, emplacement pratique.', TO_DATE('2024-07-06', 'YYYY-MM-DD'));

INSERT INTO Commentaires (CommentaireID, UtilisateurID, AnnonceID, Note, Commentaire, DateCommentaire) VALUES 
(8, 9, 8, 4, 'Appartement moderne avec une belle vue, séjour agréable.', TO_DATE('2024-07-16', 'YYYY-MM-DD'));

INSERT INTO Commentaires (CommentaireID, UtilisateurID, AnnonceID, Note, Commentaire, DateCommentaire) VALUES 
(9, 1, 9, 5, 'Chalet charmant au bord du lac, endroit paisible et relaxant.', TO_DATE('2024-08-06', 'YYYY-MM-DD'));

-- Insertion des données dans la table Photos
INSERT INTO Photos (PhotoID, AnnonceID, URLPhoto, Description) VALUES 
(1, 1, 'photo1.jpg', 'Vue depuis la fenêtre du salon');

INSERT INTO Photos (PhotoID, AnnonceID, URLPhoto, Description) VALUES 
(2, 1, 'photo2.jpg', 'Chambre principale');

INSERT INTO Photos (PhotoID, AnnonceID, URLPhoto, Description) VALUES 
(3, 2, 'photo3.jpg', 'Jardin de la maison');

INSERT INTO Photos (PhotoID, AnnonceID, URLPhoto, Description) VALUES 
(4, 2, 'photo4.jpg', 'Vue depuis la terrasse');

INSERT INTO Photos (PhotoID, AnnonceID, URLPhoto, Description) VALUES 
(5, 3, 'photo5.jpg', 'Coin cuisine du studio');

INSERT INTO Photos (PhotoID, AnnonceID, URLPhoto, Description) VALUES 
(6, 3, 'photo6.jpg', 'Salle de bain');

INSERT INTO Photos (PhotoID, AnnonceID, URLPhoto, Description) VALUES 
(7, 4, 'photo7.jpg', 'Salon du condo');

INSERT INTO Photos (PhotoID, AnnonceID, URLPhoto, Description) VALUES 
(8, 4, 'photo8.jpg', 'Chambre à coucher');

INSERT INTO Photos (PhotoID, AnnonceID, URLPhoto, Description) VALUES 
(9, 5, 'photo9.jpg', 'Vue depuis le balcon');

-- Insertion des données dans la table Messages
INSERT INTO Messages (MessageID, ExpediteurUtilisateurID, DestinataireUtilisateurID, Contenu, DateEnvoi) VALUES 
(1, 2, 1, 'Bonjour Jean, intéressé par votre appartement. Modalités de location à discuter ?', TO_DATE('2024-04-15', 'YYYY-MM-DD'));

INSERT INTO Messages (MessageID, ExpediteurUtilisateurID, DestinataireUtilisateurID, Contenu, DateEnvoi) VALUES 
(2, 1, 2, 'Bonjour Marie, ravi que l''appartement vous intéresse. Nous pouvons discuter des détails dès maintenant.', TO_DATE('2024-04-15', 'YYYY-MM-DD'));

INSERT INTO Messages (MessageID, ExpediteurUtilisateurID, DestinataireUtilisateurID, Contenu, DateEnvoi) VALUES 
(3, 3, 1, 'Bonjour Jean, j''ai vu votre annonce pour le studio. Est-il disponible la semaine prochaine ?', TO_DATE('2024-04-16', 'YYYY-MM-DD'));

INSERT INTO Messages (MessageID, ExpediteurUtilisateurID, DestinataireUtilisateurID, Contenu, DateEnvoi) VALUES 
(4, 1, 3, 'Bonjour Pierre, oui le studio est disponible. Vous pouvez réserver dès maintenant.', TO_DATE('2024-04-16', 'YYYY-MM-DD'));

INSERT INTO Messages (MessageID, ExpediteurUtilisateurID, DestinataireUtilisateurID, Contenu, DateEnvoi) VALUES 
(5, 4, 2, 'Bonjour Marie, votre maison semble parfaite pour nos prochaines vacances en famille.', TO_DATE('2024-04-17', 'YYYY-MM-DD'));

INSERT INTO Messages (MessageID, ExpediteurUtilisateurID, DestinataireUtilisateurID, Contenu, DateEnvoi) VALUES 
(6, 2, 4, 'Bonjour Sylvie, merci pour l''intérêt. Nous serions heureux de vous accueillir.', TO_DATE('2024-04-17', 'YYYY-MM-DD'));

INSERT INTO Messages (MessageID, ExpediteurUtilisateurID, DestinataireUtilisateurID, Contenu, DateEnvoi) VALUES 
(7, 5, 3, 'Bonjour Pierre, votre studio semble bien équipé. Nous souhaiterions le louer pour une semaine.', TO_DATE('2024-04-18', 'YYYY-MM-DD'));

INSERT INTO Messages (MessageID, ExpediteurUtilisateurID, DestinataireUtilisateurID, Contenu, DateEnvoi) VALUES 
(8, 3, 5, 'Bonjour Robert, je suis content que ça vous plaise. Vous pouvez réserver dès maintenant.', TO_DATE('2024-04-18', 'YYYY-MM-DD'));

INSERT INTO Messages (MessageID, ExpediteurUtilisateurID, DestinataireUtilisateurID, Contenu, DateEnvoi) VALUES 
(9, 6, 4, 'Bonjour Sylvie, nous avons été séduits par votre condo. Nous aimerions le réserver pour nos prochaines vacances.', TO_DATE('2024-04-19', 'YYYY-MM-DD'));

-- Insertion des données dans la table Utilisateurs_Annonces
INSERT INTO Utilisateurs_Annonces (UtilisateurID, AnnonceID) VALUES (1, 1);
INSERT INTO Utilisateurs_Annonces (UtilisateurID, AnnonceID) VALUES (2, 1);
INSERT INTO Utilisateurs_Annonces (UtilisateurID, AnnonceID) VALUES (2, 2);
INSERT INTO Utilisateurs_Annonces (UtilisateurID, AnnonceID) VALUES (3, 2);
INSERT INTO Utilisateurs_Annonces (UtilisateurID, AnnonceID) VALUES (4, 3);
INSERT INTO Utilisateurs_Annonces (UtilisateurID, AnnonceID) VALUES (5, 3);
INSERT INTO Utilisateurs_Annonces (UtilisateurID, AnnonceID) VALUES (3, 1);
INSERT INTO Utilisateurs_Annonces (UtilisateurID, AnnonceID) VALUES (4, 1);
INSERT INTO Utilisateurs_Annonces (UtilisateurID, AnnonceID) VALUES (5, 2);
INSERT INTO Utilisateurs_Annonces (UtilisateurID, AnnonceID) VALUES (6, 2);
INSERT INTO Utilisateurs_Annonces (UtilisateurID, AnnonceID) VALUES (4, 2);
INSERT INTO Utilisateurs_Annonces (UtilisateurID, AnnonceID) VALUES (5, 1);

COMMIT;