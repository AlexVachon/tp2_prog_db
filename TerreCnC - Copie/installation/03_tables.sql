
/****************************************************************************
    NOUVELLES TABLES

****************************************************************************/
PROMPT Création de la table Utilisateurs
CREATE TABLE Utilisateurs (
    UtilisateurID NUMBER PRIMARY KEY,
    Nom VARCHAR2(50),
    Prenom VARCHAR2(50),
    Email VARCHAR2(100),
    MotDePasse VARCHAR2(100)
);

COMMENT ON TABLE Utilisateurs IS 'Table contenant les informations des utilisateurs (clients)';
--

PROMPT Création de la table Annonces
CREATE TABLE Annonces (
    AnnonceID NUMBER PRIMARY KEY,
    AuteurID NUMBER,
    Titre VARCHAR2(100),
    Description VARCHAR2(500),
    PrixParNuit NUMBER,
    Localisation VARCHAR2(200),
    DateCreation DATE
);

COMMENT ON TABLE Annonces IS 'Table contenant les annonces de logements publiées par les utilisateurs';
--

PROMPT Création de la table Réservations
CREATE TABLE Reservations (
    ReservationID NUMBER PRIMARY KEY,
    UtilisateurID NUMBER,
    AnnonceID NUMBER,
    DateDebut DATE,
    DateFin DATE,
    Statut VARCHAR2(50),
    MontantTotal NUMBER
);

COMMENT ON TABLE Reservations IS 'Table contenant les réservations effectuées par les utilisateurs';

--
PROMPT Création de la table Commentaires
CREATE TABLE Commentaires (
    CommentaireID NUMBER PRIMARY KEY,
    UtilisateurID NUMBER,
    AnnonceID NUMBER,
    Note NUMBER,
    Commentaire VARCHAR2(500),
    DateCommentaire DATE
);

COMMENT ON TABLE Commentaires IS 'Table contenant les commentaires laissés par les utilisateurs sur les annonces';

--
PROMPT Création de la table Photos
CREATE TABLE Photos (
    PhotoID NUMBER PRIMARY KEY,
    AnnonceID NUMBER,
    URLPhoto VARCHAR2(200),
    Description VARCHAR2(500)
);

COMMENT ON TABLE Photos IS 'Table contenant les photos associées aux annonces de logements';

--
PROMPT Création de la table Messages
CREATE TABLE Messages (
    MessageID NUMBER PRIMARY KEY,
    ExpediteurUtilisateurID NUMBER,
    DestinataireUtilisateurID NUMBER,
    Contenu VARCHAR2(1000),
    DateEnvoi DATE
);

COMMENT ON TABLE Messages IS 'Table contenant les messages échangés entre utilisateurs';

--
PROMPT Création de la table Utilisateurs_Annonces
CREATE TABLE Utilisateurs_Annonces (
    UtilisateurID NUMBER,
    AnnonceID NUMBER,
    PRIMARY KEY (UtilisateurID, AnnonceID)
);

-- Contraintes de clé étrangère
ALTER TABLE Annonces ADD CONSTRAINT fk_utilisateur FOREIGN KEY (UtilisateurID) REFERENCES Utilisateurs(UtilisateurID);
ALTER TABLE Reservations ADD CONSTRAINT fk_utilisateur_reservation FOREIGN KEY (UtilisateurID) REFERENCES Utilisateurs(UtilisateurID);
ALTER TABLE Reservations ADD CONSTRAINT fk_annonce_reservation FOREIGN KEY (AnnonceID) REFERENCES Annonces(AnnonceID);
ALTER TABLE Commentaires ADD CONSTRAINT fk_utilisateur_commentaire FOREIGN KEY (UtilisateurID) REFERENCES Utilisateurs(UtilisateurID);
ALTER TABLE Commentaires ADD CONSTRAINT fk_annonce_commentaire FOREIGN KEY (AnnonceID) REFERENCES Annonces(AnnonceID);
ALTER TABLE Photos ADD CONSTRAINT fk_annonce_photo FOREIGN KEY (AnnonceID) REFERENCES Annonces(AnnonceID);
ALTER TABLE Messages ADD CONSTRAINT fk_expediteur FOREIGN KEY (ExpediteurUtilisateurID) REFERENCES Utilisateurs(UtilisateurID);
ALTER TABLE Messages ADD CONSTRAINT fk_destinataire FOREIGN KEY (DestinataireUtilisateurID) REFERENCES Utilisateurs(UtilisateurID);
ALTER TABLE Utilisateurs_Annonces ADD CONSTRAINT fk_utilisateur_annonce FOREIGN KEY (UtilisateurID) REFERENCES Utilisateurs(UtilisateurID);
ALTER TABLE Utilisateurs_Annonces ADD CONSTRAINT fk_annonce_utilisateur FOREIGN KEY (AnnonceID) REFERENCES Annonces(AnnonceID);

-- Script terminé
PROMPT Les tables et les contraintes ont été créées avec succès.
