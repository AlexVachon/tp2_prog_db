-- Suppression des contraintes
ALTER TABLE Messages DROP CONSTRAINT fk_destinataire;
ALTER TABLE Messages DROP CONSTRAINT fk_expediteur;
ALTER TABLE Photos DROP CONSTRAINT fk_annonce_photo;
ALTER TABLE Commentaires DROP CONSTRAINT fk_annonce_commentaire;
ALTER TABLE Commentaires DROP CONSTRAINT fk_utilisateur_commentaire;
ALTER TABLE Reservations DROP CONSTRAINT fk_annonce_reservation;
ALTER TABLE Reservations DROP CONSTRAINT fk_utilisateur_reservation;
ALTER TABLE Annonces DROP CONSTRAINT fk_utilisateur;
ALTER TABLE Utilisateurs_Annonces DROP CONSTRAINT fk_utilisateur_annonce;
ALTER TABLE Utilisateurs_Annonces DROP CONSTRAINT fk_annonce_utilisateur;

-- Suppression des tables
DROP TABLE Messages;
DROP TABLE Photos;
DROP TABLE Commentaires;
DROP TABLE Reservations;
DROP TABLE Annonces;
DROP TABLE Utilisateurs;
DROP TABLE Utilisateurs_Annonces;